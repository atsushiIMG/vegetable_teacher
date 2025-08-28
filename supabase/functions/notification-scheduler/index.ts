import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

interface ScheduleTask {
  day: number
  type: string
  description: string
}

interface VegetableSchedule {
  tasks: ScheduleTask[]
  watering_base_interval: number
  fertilizer_interval: number
}

interface UserVegetable {
  id: string
  user_id: string
  vegetable_id: string
  planted_date: string
  plant_type: 'seed' | 'seedling'
  location: 'pot' | 'field'
  schedule_adjustments: any
  vegetable: {
    name: string
    schedule: VegetableSchedule
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 現在栽培中の野菜をすべて取得
    const { data: userVegetables, error } = await supabase
      .from('user_vegetables')
      .select(`
        id,
        user_id,
        vegetable_id,
        planted_date,
        plant_type,
        location,
        schedule_adjustments,
        vegetable:vegetables(name, schedule)
      `)
      .eq('status', 'growing')

    if (error) {
      throw error
    }

    // JST（日本標準時）で現在日時を取得
    const now = new Date()
    // UTCでなければエラーにする（将来他のタイムゾーンで動かす場合の安全策）
    if (now.getTimezoneOffset() !== 0) {
      throw new Error('このバッチはUTCタイムゾーンで実行する必要があります。')
    }
    // JST時刻を計算
    const jstOffsetMs = 9 * 60 * 60 * 1000 // JSTはUTC+9時間
    const today = new Date(now.getTime() + jstOffsetMs)
    const notifications = []

    for (const userVeg of (userVegetables as any[])) {
      const plantedDate = new Date(userVeg.planted_date)
      const daysSincePlanted = Math.floor((today.getTime() - plantedDate.getTime()) / (1000 * 60 * 60 * 24))
      
      // plant_typeに応じて適切なスケジュールを取得
      const scheduleData = userVeg.vegetable.schedule as any
      const plantTypeKey = userVeg.plant_type === 'seed' ? 'seed_schedule' : 'seedling_schedule'
      const schedule = scheduleData[plantTypeKey] as VegetableSchedule
      
      if (!schedule || !schedule.tasks) {
        continue
      }
      
      // 作業タスクの通知をチェック
      for (const task of schedule.tasks) {
        // 通知日かチェック
        if (daysSincePlanted === task.day) {
          notifications.push({
            user_vegetable_id: userVeg.id,
            user_id: userVeg.user_id,
            task_type: task.type,
            description: `${userVeg.vegetable.name}の${task.type}の時間です`,
            scheduled_date: today.toISOString().split('T')[0]
          })
        }
      }

      // 水やり通知をチェック
      const baseWateringInterval = schedule.watering_base_interval
      const seasonMultiplier = getSeasonMultiplier(today)
      
      // 最終的な水やり間隔を計算（季節係数のみ）
      let finalWateringInterval = Math.round(baseWateringInterval * seasonMultiplier)
      
      // 最小間隔を1日、最大間隔を14日に制限
      finalWateringInterval = Math.max(finalWateringInterval, 1)
      finalWateringInterval = Math.min(finalWateringInterval, 14)

      if (daysSincePlanted > 0 && daysSincePlanted % finalWateringInterval === 0) {
        // シンプルな重複チェックのみ
        const hasNotificationToday = await checkTodayWateringNotification(supabase, userVeg.id, today)
        
        if (!hasNotificationToday) {
          notifications.push({
            user_vegetable_id: userVeg.id,
            user_id: userVeg.user_id,
            task_type: '水やり',
            description: `${userVeg.vegetable.name}の水やりの時間です。土の状態を確認してください。`,
            scheduled_date: today.toISOString().split('T')[0]
          })
        }
      }

      // 追肥通知をチェック
      if (schedule.fertilizer_interval && daysSincePlanted > 0 && daysSincePlanted % schedule.fertilizer_interval === 0) {
        notifications.push({
          user_vegetable_id: userVeg.id,
          user_id: userVeg.user_id,
          task_type: '追肥',
          description: `${userVeg.vegetable.name}の追肥の時間です`,  // description追加
          scheduled_date: today.toISOString().split('T')[0]
        })
      }
    }

    // 通知を保存
    if (notifications.length > 0) {
      const { error: insertError } = await supabase
        .from('notifications')
        .insert(notifications)

      if (insertError) {
        console.error('Failed to insert notifications:', insertError)
        throw insertError
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        notifications_created: notifications.length,
        notifications: notifications
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Notification scheduler error:', error)
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

// 季節係数を取得（夏は頻繁、冬は控えめ）
function getSeasonMultiplier(date: Date): number {
  const month = date.getMonth() + 1 // 1-12

  if (month >= 6 && month <= 8) {
    // 夏（6-8月）: より頻繁に
    return 0.7
  } else if (month >= 12 || month <= 2) {
    // 冬（12-2月）: 控えめに
    return 1.5
  } else {
    // 春・秋: 基準通り
    return 1.0
  }
}

// 今日の水やり通知が既に存在するかチェック（シンプル版）
async function checkTodayWateringNotification(
  supabase: any, 
  userVegetableId: string, 
  today: Date
): Promise<boolean> {
  try {
    const todayString = today.toISOString().split('T')[0]
    
    const { data: existingNotifications, error } = await supabase
      .from('notifications')
      .select('id')
      .eq('user_vegetable_id', userVegetableId)
      .eq('task_type', '水やり')
      .eq('scheduled_date', todayString)
      .limit(1)
    
    if (error) {
      console.error('Error checking today notifications:', error)
      return false // エラーの場合は重複なしとみなす
    }
    
    return existingNotifications && existingNotifications.length > 0
    
  } catch (error) {
    console.error('Error in checkTodayWateringNotification:', error)
    return false
  }
}