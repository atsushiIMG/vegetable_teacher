import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

interface PendingNotification {
  id: string
  user_id: string
  user_vegetable_id: string
  task_type: string
  description: string
  vegetable_name: string
  scheduled_date: string
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // JST（日本標準時）で現在日時を取得
    const now = new Date()
    // UTCでなければエラーにする（将来他のタイムゾーンで動かす場合の安全策）
    if (now.getTimezoneOffset() !== 0) {
      throw new Error('このバッチはUTCタイムゾーンで実行する必要があります。')
    }
    // JST時刻を計算
    const jstOffsetMs = 9 * 60 * 60 * 1000 // JSTはUTC+9時間
    const today = new Date(now.getTime() + jstOffsetMs)

    // データベースに通知を直接挿入（リアルタイム通知を発火）
    const { data: notifications, error } = await supabase
      .from('notifications')
      .select(`
        *,
        user_vegetables!inner(
          user_id,
          vegetable:vegetables(name)
        )
      `)
      .is('sent_at', null)
      .eq('scheduled_date', today.toISOString().split('T')[0])

    if (error) {
      throw error
    }

    const results = []
    const currentHour = today.getHours() // 現在の時間（0-23）

    for (const notification of (notifications as any[])) {
      try {
        // 通知設定をチェック
        const { data: profile, error: profileError } = await supabase
          .from('user_profiles')
          .select('notification_settings')
          .eq('id', notification.user_vegetables.user_id)
          .single()

        if (profileError) {
          continue
        }

        // 水やり通知が有効かチェック
        const wateringEnabled = profile?.notification_settings?.watering_reminders
        if (!wateringEnabled) {
          continue
        }

        // ユーザーの通知時間をチェック
        const notificationTime = profile?.notification_settings?.notification_time
        
        if (!notificationTime) {
          // デフォルト時間（朝7時）を使用
          if (currentHour !== 7) {
            continue
          }
        } else {
          // 通知時間をパース（例: "07:30" → 7）
          const userHour = parseInt(notificationTime.split(':')[0])
          if (currentHour !== userHour) {
            continue
          }
        }

        // 野菜名を取得
        const vegetableName = notification.user_vegetables?.vegetable?.name || '野菜'

        // 通知データにvegetable_nameを追加
        const updatedNotification = {
          ...notification,
          vegetable_name: vegetableName
        }

        // Supabaseのリアルタイム機能を使って通知を配信
        // sent_atを更新することで、クライアント側でリアルタイム通知が発火される
        const { error: updateError } = await supabase
          .from('notifications')
          .update({ 
            sent_at: new Date().toISOString(),
            vegetable_name: vegetableName
          })
          .eq('id', notification.id)

        if (updateError) {
          console.error(`Failed to update notification ${notification.id}:`, updateError)
          throw updateError
        }

        results.push({
          notification_id: notification.id,
          status: 'sent_via_realtime',
          vegetable_name: vegetableName
        })

      } catch (error) {
        console.error(`Error processing notification ${notification.id}:`, error)
        results.push({
          notification_id: notification.id,
          status: 'error',
          error: error.message
        })
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        processed: notifications.length,
        results: results
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Push notification sender error:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        details: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})