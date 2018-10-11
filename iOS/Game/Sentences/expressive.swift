//
//  dailyTwo.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on 9/25/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

import Foundation

// MARK: - 情緒表達 1
let expressive = [
"""
#表達
本当に嬉しい|真開心
やった！|做完啦
いい感じですね|感覺不錯耶
すごい|真厲害
結構です|不需要
感動しました|覺得感動了
楽しみしている|正在期待
素晴らしい！|絕佳
よかったね|太好了
すごく面白かったですよ|真的很有趣喔
今日は楽しかったです|今天很開心
幸せだ|感到幸福
優しい人ですね|是個好/和善人耶
助かりました|幫了大忙
助かった|幫了大忙
私に任せて|交給我吧
光栄です|這是我的榮幸
かわいい|可愛
大丈夫です|沒關係
わたし、気になります！|我很在意/好奇
楽しみだなぁ
""",
// MARK: - 情緒表達 2
"""
#表達
悲しいです|感到悲傷
痛い|痛
怖い！|好可怕
辛い！|好辛苦
びっくりした|大吃一驚
信じられない|不敢相信
嫌だ！|討厭
もう我慢できない|已經忍不住了
すごく悔しいです|非常的後悔
寂しいです|好寂寞
顔を見ないで、恥ずかしいです|別看我、好害羞
もういい！|夠了
馬鹿にするな！|別當我是笨蛋
想像できない|想像不到
困って仕方がない|被困住沒法子了
つまらない|無聊
私のせいです|是我的錯
構いません|沒關係
頭が痛いです|頭在痛
体が少したるいです|身體有些疲倦
どうしよう|怎麼辦？
""",
// MARK: - 邀約/拒絕
"""
#表達
晩ご飯一緒にどう|一起吃晚餐如何
村上くんのライン聞いてもいい？|可以問一下村上君的Line嗎
ライン教えて！|給我Line
お腹すいたね。ご飯食べにいかない？|肚子餓了，去吃飯好不好
ごめん、私はちょっと用事がある|抱歉，我有點事
一緒に映画を観に行かない？|一起去看電影好嗎？
いついい？|什麼時候方便？
水曜日と金曜日はダメだったわね|週三和週五不行
木曜日はどうですか|週四如何？
いいよ、何時ですか|好啊，幾點呢？
午後七時に会いましょう|約晚上七點碰面吧
動物園に行こう！|去動物園
どこで会いますか|要在哪碰面呢？
原宿駅前出会おう|原宿車站前碰面吧
2時頃駅前の喫茶店にしないか|要不、兩點時車站前的咖啡店？
しゃ、そうしよう|那、就那樣吧
そんな深い意味じゃないんだ。友達として|沒有什麼複雜的意思啦。只是做為朋友
私も行きたいです|我也想去
新宿駅の南口の改札はどうですか|新宿車站南口的剪票口如何？
たぶん10分くらい遅れると思う|我想大概會遲到個十分鐘

""",
"""
#表達
もう一個なんでしょうか
教えてもらっていいですか
これをちょっと教えていただいたいと思うんですけど
じゃあ、ちょっといろいろ教えてください
じゃあ、作る方からお願いいいですか
とういう感じで行きますか
じゃあ、次のテーマをお願いします
もう一度お願いします|請你再說一次
もう一回いいですか？|再說一次好嗎
それって、どういう意味ですか？|那個、是什麼意思
もう一度言ってくれませんか？|能再跟我說一次嗎
今なんと言いましたか？|剛剛你說了什麼
今聞き取れませんでした。|剛剛沒聽清楚
すみません、なんと言いましたか？|不好意思，你說了什麼
もう少しゆっくり話してくれませんか？|能說慢一點嗎
もう少し大きな声で話してくれませんか？|能大聲一點嗎
すみませんが、もう一度言ってくれませんか？|不好意思、能再跟我說一次嗎？
""",
// MARK: - 延伸話題　google 相槌
"""
#表達
私もです。|我也...
それはつらかったでしょう。|那真的很辛苦對吧
うんうん|嗯嗯
私もそう思います|我也這樣認為
よくわかります|我懂、我懂
さずか、田中さん|不愧是田中先生
いいね！|真棒
いいですね|真棒
まさか！|怎麼會...
ですよね！|就是說啊
すごいね！|真厲害
その後は、どうするのか|那個之後，做了什麼？
そのとおりです|如你所說的
なるほどね|原來如此
いいんじゃない|沒什麼不好的
似合うと思うよ|我覺得很適合喔
それでも、大変ですね|就算那樣，也是很不得了耶
たしかに|的確
本当におっしゃる通り。|真的如你所說
うそでしょ。|不會吧！
本当に？|真的嗎？
それは楽しそうですね。|那個看起來很開心耶
それはつらかったでしょう。|那很辛苦吧
負けました
なんか、これが怪しいです
これはダメですね
大正解です
いいと思います
最高ですね
やっぱりいいですよね
"""
]
