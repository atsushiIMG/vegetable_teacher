-- 9種類の野菜初期データ
-- 各野菜の栽培スケジュールと基本情報

-- 1. トマト
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'トマト',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "深さ1cm程度に種をまく。発芽温度は20-25℃"},
            {"day": 14, "type": "間引き", "description": "本葉が出たら元気な苗を1本残して間引く"},
            {"day": 30, "type": "支柱立て", "description": "高さ120-150cmの支柱を立てる"},
            {"day": 45, "type": "追肥", "description": "液体肥料を薄めて与える"},
            {"day": 75, "type": "追肥", "description": "2回目の追肥を行う"},
            {"day": 90, "type": "収穫", "description": "赤く熟したものから順次収穫"}
        ],
        "watering_base_interval": 2,
        "fertilizer_interval": 30
    }',
    '日当たりの良い場所で育てる。水やりは土の表面が乾いたらたっぷりと。脇芽は摘み取る。',
    '尻腐れ病（カルシウム不足）、疫病（過湿）、アブラムシ'
);

-- 2. きゅうり
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'きゅうり',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "深さ1-2cm程度に種をまく"},
            {"day": 14, "type": "間引き", "description": "本葉2-3枚で間引く"},
            {"day": 25, "type": "支柱立て", "description": "つるが伸びる前に支柱を立てる"},
            {"day": 40, "type": "追肥", "description": "液体肥料を与える"},
            {"day": 65, "type": "収穫", "description": "15-20cmになったら収穫"}
        ],
        "watering_base_interval": 1,
        "fertilizer_interval": 20
    }',
    '水を好むので毎日の水やりが必要。ネットやフェンスに這わせると育てやすい。',
    'うどんこ病、べと病、アブラムシ、ハダニ'
);

-- 3. ナス
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'ナス',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "温かい場所で種まき"},
            {"day": 21, "type": "間引き", "description": "本葉3-4枚で間引く"},
            {"day": 35, "type": "支柱立て", "description": "3本仕立てにして支柱を立てる"},
            {"day": 50, "type": "追肥", "description": "最初の追肥を行う"},
            {"day": 80, "type": "収穫", "description": "つやのある実を収穫"}
        ],
        "watering_base_interval": 2,
        "fertilizer_interval": 25
    }',
    '高温を好む。水切れに注意。一番果は早めに収穫して株を充実させる。',
    'アブラムシ、ハダニ、うどんこ病'
);

-- 4. オクラ
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'オクラ',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "一晩水に浸けてから種まき"},
            {"day": 14, "type": "間引き", "description": "本葉2-3枚で間引く"},
            {"day": 40, "type": "追肥", "description": "液体肥料を与える"},
            {"day": 60, "type": "収穫", "description": "長さ8-10cmで収穫"}
        ],
        "watering_base_interval": 2,
        "fertilizer_interval": 30
    }',
    '高温を好む。種は硬いので一晩水に浸けてから蒔く。毎日収穫する。',
    'アブラムシ、カメムシ、立枯病'
);

-- 5. バジル
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'バジル',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "薄く土をかぶせて種まき"},
            {"day": 10, "type": "間引き", "description": "本葉2-3枚で間引く"},
            {"day": 30, "type": "摘芯", "description": "花芽を摘んで葉を充実させる"},
            {"day": 45, "type": "収穫", "description": "葉を摘んで収穫"}
        ],
        "watering_base_interval": 1,
        "fertilizer_interval": 20
    }',
    '日当たりと水はけの良い場所で。花が咲く前に摘芯する。',
    'アブラムシ、ハダニ、立枯病'
);

-- 6. サニーレタス
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'サニーレタス',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "薄く土をかぶせて種まき"},
            {"day": 7, "type": "間引き", "description": "本葉1-2枚で間引く"},
            {"day": 30, "type": "収穫", "description": "外葉から順次収穫"}
        ],
        "watering_base_interval": 1,
        "fertilizer_interval": 15
    }',
    '涼しい場所で育てる。外葉から摘み取ると長期間収穫できる。',
    'アブラムシ、ヨトウムシ、軟腐病'
);

-- 7. 二十日大根
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    '二十日大根',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "深さ1cm程度に種をまく"},
            {"day": 7, "type": "間引き", "description": "本葉2-3枚で間引く"},
            {"day": 20, "type": "収穫", "description": "根が膨らんだら収穫"}
        ],
        "watering_base_interval": 1,
        "fertilizer_interval": 10
    }',
    '成長が早い。間引きをしっかり行う。根が地上に出たら収穫時期。',
    'アブラムシ、キスジノミハムシ、根こぶ病'
);

-- 8. ほうれん草
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'ほうれん草',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "深さ1cm程度に種をまく"},
            {"day": 14, "type": "間引き", "description": "本葉2-3枚で間引く"},
            {"day": 40, "type": "収穫", "description": "草丈15-20cmで収穫"}
        ],
        "watering_base_interval": 2,
        "fertilizer_interval": 20
    }',
    '涼しい気候を好む。酸性土壌を嫌うので石灰を混ぜる。',
    'アブラムシ、ヨトウムシ、べと病'
);

-- 9. 小カブ
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    '小カブ',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "深さ1cm程度に種をまく"},
            {"day": 10, "type": "間引き", "description": "本葉2-3枚で間引く"},
            {"day": 45, "type": "収穫", "description": "根が5cm程度になったら収穫"}
        ],
        "watering_base_interval": 1,
        "fertilizer_interval": 15
    }',
    '涼しい気候を好む。間引きをしっかり行う。葉も食べられる。',
    'アブラムシ、キスジノミハムシ、根こぶ病'
);

-- 10. ピーマン
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'ピーマン',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "温かい場所で種まき"},
            {"day": 21, "type": "間引き", "description": "本葉3-4枚で間引く"},
            {"day": 35, "type": "支柱立て", "description": "3本仕立てにして支柱を立てる"},
            {"day": 50, "type": "追肥", "description": "最初の追肥を行う"},
            {"day": 70, "type": "収穫", "description": "実が大きくなったら収穫"}
        ],
        "watering_base_interval": 2,
        "fertilizer_interval": 25
    }',
    '高温を好む。一番果は小さいうちに収穫して株を充実させる。',
    'アブラムシ、ハダニ、うどんこ病'
);

-- 11. しそ
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'しそ',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "薄く土をかぶせて種まき"},
            {"day": 10, "type": "間引き", "description": "本葉2-3枚で間引く"},
            {"day": 30, "type": "摘芯", "description": "花芽を摘んで葉を充実させる"},
            {"day": 40, "type": "収穫", "description": "葉を摘んで収穫"}
        ],
        "watering_base_interval": 1,
        "fertilizer_interval": 20
    }',
    '半日陰でも育つ。花が咲く前に摘芯する。こまめに収穫する。',
    'アブラムシ、ハダニ、立枯病'
);

-- 12. モロヘイヤ
INSERT INTO vegetables (id, name, schedule, growing_tips, common_problems) VALUES (
    gen_random_uuid(),
    'モロヘイヤ',
    '{
        "tasks": [
            {"day": 0, "type": "種まき", "description": "温かい場所で種まき"},
            {"day": 14, "type": "間引き", "description": "本葉2-3枚で間引く"},
            {"day": 30, "type": "摘芯", "description": "草丈20cmで摘芯して脇芽を出す"},
            {"day": 50, "type": "収穫", "description": "若い葉を摘んで収穫"}
        ],
        "watering_base_interval": 1,
        "fertilizer_interval": 25
    }',
    '高温を好む。摘芯して脇芽を伸ばすと長期間収穫できる。',
    'アブラムシ、ハダニ、立枯病'
);