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
      
      const adjustments = userVeg.schedule_adjustments || {}

      // 作業タスクの通知をチェック
      for (const task of schedule.tasks) {
        let taskDay = task.day
        
        // 種の場合は種まきスケジュール、苗の場合は植え付けスケジュールを使用
        // 既に適切なスケジュールを選択済みなので、追加調整は不要

        // 個別調整があれば適用
        const adjustmentKey = `${task.type}_adjustment`
        if (adjustments[adjustmentKey]) {
          taskDay += adjustments[adjustmentKey]
        }

        // 通知日かチェック
        if (daysSincePlanted === taskDay) {
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
      const wateringInterval = schedule.watering_base_interval
      const seasonMultiplier = getSeasonMultiplier(today)
      const adjustedWateringInterval = Math.round(wateringInterval * seasonMultiplier)
      
      // 個別調整があれば適用
      const wateringAdjustment = adjustments.watering_adjustment || 0
      const finalWateringInterval = adjustedWateringInterval + wateringAdjustment

      if (daysSincePlanted > 0 && daysSincePlanted % finalWateringInterval === 0) {
        notifications.push({
          user_vegetable_id: userVeg.id,
          user_id: userVeg.user_id,
          task_type: '水やり',
          description: `${userVeg.vegetable.name}の水やりの時間です`,
          scheduled_date: today.toISOString().split('T')[0]
        })
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