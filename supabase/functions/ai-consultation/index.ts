import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// 許可されたオリジンのホワイトリスト
const ALLOWED_ORIGINS = [
  'http://localhost:3000',
  'https://localhost:3000',
  'https://ssrfnkanoegmflgcvkpv.supabase.co',
  'https://vegetable-teacher.com', // 本番ドメイン（必要に応じて変更）
  // Flutterアプリからのリクエストも許可（アプリの場合はnull origin）
]

const getCorsHeaders = (origin: string | null) => {
  const allowedOrigin = origin && ALLOWED_ORIGINS.includes(origin) ? origin : 'null'
  
  return {
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Credentials': 'true',
  }
}

const MAX_RETRIES = 3
const BASE_DELAY = 2000 // 2秒

serve(async (req) => {
  const origin = req.headers.get('origin')
  const corsHeaders = getCorsHeaders(origin)
  
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // オリジン検証 - Flutterアプリは通常nullオリジンなので許可
  if (origin && !ALLOWED_ORIGINS.includes(origin)) {
    console.warn(`Blocked request from unauthorized origin: ${origin}`)
    return new Response(
      JSON.stringify({ error: 'Unauthorized origin' }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 403 
      }
    )
  }

  try {
    const { 
      vegetable_type, 
      message, 
      user_vegetable_id,
      planted_days,
      plant_type,
      location,
      current_stage,
      growing_tips,
      common_problems,
      chat_history
    } = await req.json()

    if (!vegetable_type || !message) {
      return new Response(
        JSON.stringify({ error: 'vegetable_type and message are required' }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      )
    }

    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      return new Response(
        JSON.stringify({ error: 'OpenAI API key not configured' }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500 
        }
      )
    }

    // 野菜栽培に特化した詳細プロンプト（Flutter側と同等の内容）
    const systemPrompt = `あなたは${vegetable_type}の栽培に詳しい家庭菜園の専門家です。初心者にも分かりやすく、親しみやすい口調でアドバイスをしてください。

== 現在の栽培状況 ==
野菜: ${vegetable_type}
${plant_type ? `植付タイプ: ${plant_type}` : ''}
${location ? `栽培場所: ${location}` : ''}
${planted_days ? `植えてからの日数: ${planted_days}日` : ''}
${current_stage ? `現在の段階: ${current_stage}` : ''}

== ${vegetable_type}の栽培ポイント ==
${growing_tips || '基本的な水やりと日当たり管理を心がけてください。'}

== よくある問題と対策 ==
${common_problems || '病害虫や成長不良が見られた場合は、環境条件を見直してください。'}

== 回答の指針 ==
1. ${vegetable_type}に特化した具体的で実践的なアドバイスを提供する
2. ${planted_days ? `現在の栽培段階（${planted_days}日目）に適した内容にする` : '適切な成長段階を考慮する'}
3. 初心者でも理解しやすい言葉を使う
4. 症状がある場合は、${vegetable_type}特有の原因と対処法を提示する
5. 安全性を重視し、農薬等の使用は慎重に案内する
6. 150文字以内で簡潔に回答する

口調：丁寧で親しみやすく、「〜ですね」「〜しましょう」など初心者に寄り添う表現を使用`

    // OpenAI APIをリトライ機構付きで呼び出し
    let aiResponse: string | null = null
    let lastError: Error | null = null

    for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
      try {
        const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${openaiApiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            model: 'gpt-4o-mini',
            messages: [
              { role: 'system', content: systemPrompt },
              // 過去の会話履歴を追加
              ...(chat_history || []).map((chat: any) => ({
                role: chat.is_user ? 'user' : 'assistant',
                content: chat.message
              })),
              // 現在のユーザーメッセージ
              { role: 'user', content: message }
            ],
            max_tokens: 1000,
            temperature: 0.7,
          }),
        })

        if (openaiResponse.ok) {
          const openaiData = await openaiResponse.json()
          aiResponse = openaiData.choices[0]?.message?.content

          if (aiResponse) {
            break // 成功した場合はループを抜ける
          } else {
            throw new Error('No response content from OpenAI')
          }
        } else if (openaiResponse.status === 429) {
          // レート制限エラーの場合
          const retryAfter = openaiResponse.headers.get('retry-after')
          const delay = retryAfter ? parseInt(retryAfter) * 1000 : BASE_DELAY * Math.pow(2, attempt)
          
          if (attempt < MAX_RETRIES - 1) {
            console.log(`Rate limited, retrying in ${delay}ms...`)
            await new Promise(resolve => setTimeout(resolve, delay))
            continue
          } else {
            throw new Error('Rate limited - maximum retries exceeded')
          }
        } else {
          const errorText = await openaiResponse.text()
          throw new Error(`OpenAI API error ${openaiResponse.status}: ${errorText}`)
        }
      } catch (e) {
        lastError = e instanceof Error ? e : new Error(String(e))
        console.error(`Attempt ${attempt + 1} failed:`, lastError.message)

        if (attempt < MAX_RETRIES - 1) {
          const delay = BASE_DELAY * Math.pow(2, attempt) // 指数バックオフ
          console.log(`Retrying in ${delay}ms...`)
          await new Promise(resolve => setTimeout(resolve, delay))
        }
      }
    }

    if (!aiResponse) {
      console.error('All retry attempts failed:', lastError?.message)
      return new Response(
        JSON.stringify({ 
          error: 'AI service temporarily unavailable',
          details: lastError?.message || 'Unknown error'
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500 
        }
      )
    }

    // Supabaseクライアントを初期化（相談履歴を保存する場合）
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 相談履歴をデータベースに保存
    if (user_vegetable_id) {
      const { error: dbError } = await supabase
        .from('consultations')
        .insert({
          user_vegetable_id,
          messages: [
            { role: 'user', content: message },
            { role: 'assistant', content: aiResponse }
          ]
        })

      if (dbError) {
        console.error('Database error:', dbError)
        // エラーが発生してもAIの回答は返す
      }
    }

    return new Response(
      JSON.stringify({
        response: aiResponse,
        vegetable_type,
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Function error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})