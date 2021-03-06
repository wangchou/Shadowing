//
//  travel.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/25/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

// MARK: - 關東旅遊

let travel = [
    """
    #旅遊 #海關 #飯店 #計程車
    滞在期間はどれくらいですか？|會在日本待多久呢？[海關]
    一週間です|一週。[海關]
    チェックインお願いします。|我要 Check-in [飯店]
    承知いたしました。お名前をお伺いします。|我知道了，您的姓名是？ [飯店]
    名前は山田一郎です|我的名字是山田一郎 [飯店]
    荷物を預かっていただけますか? |能寄放行李嗎？[飯店]
    Wi-Fiはありますか。|有 Wifi 嗎？[飯店]
    そのバスはいつ出発しますか？|這個巴士什麼時候出發？[問時間]
    そのお店は何時に開きますか？|這家店幾點會開門？[問時間]
    タクシーはいますか？|有計程車嗎？[計程車]
    空港までいくらですか？|到機場要多少錢？[計程車]
    池袋駅までお願いします|我要到池袋車站。[計程車]
    すみません、浅草駅はどこですか？|不好意思、淺草車站在哪裡？
    すみません、観光案内所はどこですか？|不好意思、旅遊中心在哪裡？
    すみません、お手洗いはどこですか？|不好意思、廁所在哪裡？
    なぜこれはここに建設されたのですか？|蓋這個建築的目的是什麼？
    夜の外出は危険ですか？|晚上外出會危險嗎？
    この料理はなんですか？|這道料理是什麼？
    英語を話せる方はいらっしゃいますか？|有會說英文的人嗎？
    写真を撮ってもらえませんか。|可以幫我拍張照嗎？
    """,
    """
    #旅遊 #關東
    上野公園はどこですか？|上野公園在哪裡？
    代々木公園で1日を過ごした|一整天都待在代代木公園。
    素敵な場所です。|這是美好的場所。
    江ノ島を観光しよう|去江之島觀光吧。
    海、行きたいなぁ|真想去海邊啊～
    友達と海に行きました|和朋友去了海邊。
    花火がきれいだった|那時煙火真美
    今温泉に行きたいです。|現在想去溫泉。
    初めて浴衣を着た|是第一次穿上浴衣
    彼女は浴衣が似合っている|她穿上浴衣後、看起來很搭
    今度、下北沢に行くんですよ|這次要去下北澤喔
    私は渋谷で買い物をする|我的話，要去澀谷買東西。
    ディズニーの最寄り駅を教えて下さい|請告訴我離迪士尼樂園最近的車站。
    スカイツリーより東京タワーが好き|比起晴空塔、更喜歡東京鐵塔
    ここは銀座の6丁目です|這是銀座六丁目
    彼は新宿駅で道に迷った|他在新宿車站迷路了
    """,

    // MARK: - 関西旅遊 / 全日本

    """
    #旅遊 #關西
    京都の夏は暑いです|京都的夏天很熱。
    京都に行くなら、どこがいいですか|如果去京都，哪裡比較好？
    鴨川沿いには遊歩道があります|沿著鴨川有散步道
    富士山はとてもきれいだ|富士山非常的美麗
    私たちは大阪城に行きます|我們要去大阪城
    奈良公園には鹿がたくさんいる|奈良公園裡有很多鹿
    桜は今が満開です。|現在櫻花正盛開著。
    横浜の食べ歩きと言えば中華街|說到在橫濱邊走邊吃，就是中華街吧
    北海道で家族の思い出を残そう|在北海道留下家族的回憶吧
    お花畑に行きたい|想去花田～
    やっぱり魚介類食べてみたい|果然想吃看看海鮮
    九州の大都市といえば福岡だ|說到九州的大都市，就會想到福岡
    甲子園に行きたい|想去甲子園
    お寺と神社はどう違うんですか|寺廟和神社哪裡不一樣啊？
    """,

    // MARK: - 餐廳用餐

    """
    #旅遊 #用餐
    いらっしゃいませ|歡迎光臨
    二人です|兩個人
    一人です|一個人
    禁煙席をお願いします|我們要坐禁煙區
    すみません|不好意思/對不起 (對上 or 外人使用)
    メニューをお願いします|請給我菜單
    注文をお願いします|我要點餐
    何になさいますか。|請問要點什麼？
    オススメはなんですか？|有什麼推薦的嗎？
    なにがいいかな...|點什麼好呢... (自言自語)
    これ、お願いします|我要點這個 (手指菜)
    醤油ラーメンを二つください。|我要點兩碗醬油拉麵
    私もそれにします|我也一樣點那個
    パスタがまだ来ていないのですが|義大利麵還沒送來...
    お水をいただけますか？|可以給我水嗎？
    お会計お願いします。|我要結帳。
    別々に、できますか？|能分開結帳嗎？
    ごちそうさまでした|謝謝招待。
    """,
    /// 購物
    """
    #旅遊 #買東西
    これいくらですか。|這個多少錢？
    20000円お願いします。|兩萬圓。
    この本は3000円です。|這本書要三千圓。
    あの店は物が安い。|這家店的東西便宜。
    もっと安いのはありますか。|能再更便宜一點嗎？
    もう少し安いのはありますか。|能再更便宜一點點嗎？
    もっと安い部屋はありますか。|有更便宜的房間嗎？
    それはとても高い！|那個太貴了。
    いくらほしい？|要幾個呢？
    ごめん、お釣りが無い。|抱歉、沒有零錢了。
    カード使えますか？|可以用信用卡嗎？
    この近くコンビニがありますか。|附近有便利商店嗎？
    紙袋をいただけますか。|能給我一個紙袋嗎？
    返金して欲しい。|我想要退費。
    払い戻しをお願いします。|請幫我退費。
    値段には消費税を含みますか。|價格有包含消費稅嗎？
    これを試着してもいいですか？|這個可以試穿嗎？
    これの小さいサイズはありますか？|這個有小一點的 Size 嗎？
    """,
]
