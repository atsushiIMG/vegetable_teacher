// 定期実行でSupabaseリアルタイム通知を処理するcron関数
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    // 通知スケジュール関数を呼び出し
    const scheduleResponse = await fetch(
      `${Deno.env.get('SUPABASE_URL')}/functions/v1/notification-scheduler`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
          'Content-Type': 'application/json',
        },
      }
    )

    if (!scheduleResponse.ok) {
      throw new Error(`Schedule function failed: ${scheduleResponse.status}`)
    }

    const scheduleResult = await scheduleResponse.json()
    console.log('Schedule result:', scheduleResult)

    // Supabaseリアルタイム通知送信関数を呼び出し
    const pushResponse = await fetch(
      `${Deno.env.get('SUPABASE_URL')}/functions/v1/send-push-notifications`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
          'Content-Type': 'application/json',
        },
      }
    )

    if (!pushResponse.ok) {
      throw new Error(`Realtime notification function failed: ${pushResponse.status}`)
    }

    const pushResult = await pushResponse.json()
    console.log('Realtime notification result:', pushResult)

    return new Response(
      JSON.stringify({
        success: true,
        schedule_result: scheduleResult,
        push_result: pushResult,
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Notification cron error:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Cron job failed',
        details: error.message,
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})