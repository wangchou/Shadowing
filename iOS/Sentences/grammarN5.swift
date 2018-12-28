//
//  grammar.swift
//  sentencesVerifier
//
//  Created by Wangchou Lu on 12/24/30 H.
//  Copyright © 30 Heisei Lu, WangChou. All rights reserved.
//

let grammarN5 = [
"""
#N5 #文法
いしゃに なる|成為醫生
いしゃに なる つもりです。|打算成為醫生。
私は いしゃに なる つもりです。|我打算成為醫生。

山に のぼる|爬山
きょねん 山に のぼりました。|去年爬了山。
きょねん りょうしんと 山に のぼりました。|去年和雙親一起爬了山。

ニュースは しる|新聞啊、我知道。
ニュースは しっています。|新聞啊、我是知道的。
その ニュースは もう しっています。|那個新聞啊、我已經知道了。

雨が ふる|下雨
風が ふく|風吹
雨が ふったり かぜが ふいたり|一下下雨、一下風吹
きのうは 雨が ふったり かぜが ふいたり しました。|昨天一下下雨、一下風吹。

お母さんは 来ます。|媽媽會來
お母さんは どの 電車で 来ますか。|母親會搭哪輛電車來呢？
""",
"""
#N5 #文法
いそがしいです。|我很忙。
1月から 4月まで いそがしいです。|一月到四月很忙。
毎年 1月から 4月まで とても いそがしいです。|每年1月至4月非常繁忙。

ズボンは 長い|褲子很長
ズボンは 長かった|褲子很長。(過去式)
ズボンは みじかい|褲子很短
ズボンを みじかく します|把褲子變短
この ズボンは 長かったので、少し みじかく しました。|這褲子很長，所以我把它變短了。

とります|拍照
とりません|不拍照。
しゃしんは とりませんでした。|我沒有拍照。
しゃしんは すこししか とりませんでした。|我只拍了一點照片。

おわる|結束
しゅくだいが おわります。|做完宿題。
11時ごろ しゅくだいが おわりました。|在11點左右做完了的宿題。

じょうぶに なる|變結實
じょうぶに なりました|變結實了
からだが じょうぶに なりました。|身體變結實了。
""",
"""
#N5 #文法
あそぶ|遊玩
あそびません|不遊玩
きのうは あそびませんでした。|昨天沒遊玩。
きのうは だれとも あそびませんでした。|昨天和誰都沒遊玩。

買う|買
シャツを 買いました。|我買了一件襯衫。
シャツを 三まい 買いました。|我買了三件襯衫。

行く|去
行きます|去(禮貌)
どこかへ 行きます。|去某個地方。
田中さんは どこかへ 行きます。|田中先生去某個地方。
田中さんは ゆうべ どこかへ 行きました。|田中先生昨晚去了某個地方。

入る|放入
入って いる|被放入了
くだものが 入って います。|水果被放進去了。
れいぞうこに くだものが 入って います。|冰箱裡放有水果。
""",
"""
#N5 #文法
分かりません。|不知道。
いつか 分かりません。|不知道是什麼時候。
たんじょうび|生日
田中さんの たんじょうび|田中的生日
田中さんの たんじょうびは いつか 分かりません。|不知道田中的生日是什麼時候。

ギターを ひく|彈吉他
ギターを ひいて ください。|請彈吉他。
私の たんじょうび|我的生日
私の たんじょうびに ギターを ひいて ください。|請在我的生日時彈吉他。

駅のむこうに|在車站對面
びょういんが ある|有一家醫院
駅のむこうに びょういんが あります。|車站對面有一家醫院。

りょうりを つくります。|做料理。
にくと やさいで|用肉和青菜
このりょうりは にくと やさいで つくります。|這個料理將使用肉和蔬菜來製作。
""",
"""
#N5 #文法
ゆうびんきょくへ 行きます|去郵局。
ぎんこうへは 行きません|不去銀行
今日は ゆうびんきょくへ 行きますが、ぎんこうへは 行きません。|今天會去郵局，但不會去銀行。

30分 かかります。|需要30分鐘。
大学まで 30分 かかります。|到大學需要30分鐘。
大学まで 電車で 30分 かかります。|搭電車到大學需要30分鐘。

ほしいです。|想要。
ようふくが ほしいです。|想要洋裝。
あたらしい ようふくが ほしいです。|想要新的洋裝。

きのしたさんは いますか。|木下先生在嗎？
山本です|我是山本
もしもし、山本ですが きのしたさんは いますか。|你好，我是山本，請問木下先生在嗎？

300円です。|300日元。
たまごは 300円です。|雞蛋要300日元。
このたまごは 6つで 300円です。|這種雞蛋六個要300日元。

これは スポーツです|這是一種運動
これは 何という スポーツですか。|這種運動叫做什麼？
""",
"""
#N5 #文法
色が すきです|我喜歡顏色
どの色が すきですか。|你喜歡哪種顏色？

外国に 行きます。|去國外
外国に 旅行に 行きます。|會去國外旅行。

やすいです。|便宜耶。
アパートは やすいです。|公寓很便宜。
あの アパートは きれいで やすいです。|那間公寓很漂亮而且很便宜。

ゆうめいです|有名。
ゆうめいでは ありません。|不有名。
あの 先生は ゆうめいでは ありません。|那個老師不有名。

ない|沒有
お金が ない|沒有錢
こまる|感到為難
こまっている。|正感到為難。
お金が なくて こまっています。|正因為沒錢而感到為難。

くらい|黑的
くらく なる|變黑
くらく なりました。|變黑了。
そらが くらく なりました。|天空變黑了。
""",
"""
#N5 #文法
本を かりる|借書
本を かりる前に|在借書之前
名前を 書く|寫下名字
かみに 名前を 書いてください。|請在紙上寫下名字。
本を かりる前に このかみに 名前を 書いてください。|在借書前，請在這個紙上寫下名字。

食べる|吃
食べながら|邊吃
話す|說話
話さない|不要說話
食べながら 話さないで ください。|吃飯時請不要說話。

およぐ|游泳
うみで およぎます|在海裡游泳。
私は うみで およぎたいです。|我想在海裡游泳。
私は なつに うみで およぎたいです。|我夏天時想在海裡游泳。

はやくする|快點
はやくして ください|請快點
時間が ある|有時間
時間が ありません。はやくして ください。|沒時間了。請快點。
""",
"""
#N5 #文法
どちらですか。|在哪裡？
出口は どちらですか。|出口在哪裡？
すみません、出口は どちらですか。|不好意思，出口在哪裡？

ジュースは ありません|沒有果汁
コーヒーは あります|有咖啡。
ジュースは もう ありませんが コーヒーは まだ あります。|果汁已經沒了。但咖啡的話、還有

休みは ありますか。|有放假嗎？
どのぐらい ありますか。|有多久呢？
はる 休みは どのぐらい ありますか。|春假有多久呢？

来ました|來了。
だれが 来ましたか。|誰來了？
きのう ここに だれが 来ましたか。|誰昨天來到這裡來過？

みかん|橘子
みかんや りんご|橘子和蘋果
みかんや りんごが あります。|有橘子和蘋果。
テーブルの上に みかんや りんごが あります。|桌子上有橘子和蘋果。

母は います。|母親在喔。
母は だいどころに います。|媽媽在廚房。

聞きました。|我問過了
だれに 聞きましたか。|你問過誰了？
その ことを だれに 聞きましたか。|對這件事，你問過誰嗎？
""",
"""
#N5 #文法
そうじ しました。|打掃完了
せんたくも おわりました。|衣服洗完了。
そうじ しました。 せんたくも おわりました。|打掃完了、衣服也洗完了。

会いました。|我遇見了。
田中さんには 会いました。|我遇到了田中先生。
田中さんには おととい 会いました。|我前天遇見了田中先生。

火曜日から 今日まで|從星期二到今天
テストが ある|有考試
火曜日から 今日まで テストが ありました。|從星期二到今天有考試。

じてんしゃを のる|騎自行車
買いものに 行く|去購物
じてんしゃに のって 買いものに 行きました。|騎了自行車去購物。

きたない。|污濁。
きたなく なる。|污濁。
水が きたなく なりました。|水變污濁了。
雨で 川の 水が きたなく なりました。|由於下雨，河水變污濁了。

あつい。|熱。
あつくない。|不熱。
きのうは あつくなかった。|昨天不熱。
きのうは あまり あつくなかったです。|昨天不很熱。
""",
"""
#N5 #文法
かぜが 入る|風吹進來。
すずしい かぜが 入ります|涼爽的風吹進來
まどから すずしい かぜが 入りますよ。|從窗戶涼爽的風會吹進來呦。

見る|看
見せる|讓人看
やすいのを 見せる|讓人看便宜的(款式)
もう ちょっと やすいのを、見せて ください。|請讓我看較便宜的(款式)。

じしょを 見る|查字典
かんじを おぼえる|記住漢字
じしょを 見て かんじを おぼえます。|查字典後，記住漢字。

ドアを あける。|打開門。
私は ドアを あけた。|我打開門。(過去式)
私は げんかんの ドアを あけた。|我打開了玄關的大門。

そこの つくえ|那邊的桌子
ボールペンが あります。|有原子筆。
ボールペンが おいて あります。|放有原子筆。
そこの つくえに ボールペンが おいて あります。|那邊的桌上放有原子筆
""",
"""
#N5 #文法
つよい|強
つよく なる|變強
かぜが つよく なりました|風變強了
まどを しめる|關窗
かぜが つよく なりましたから まどを しめました。|因為風變強了、所以關上了窗

てがみを 書く|寫信
私は てがみを 書きます。|我會寫信的。
私は いつも まんねんひつで てがみを 書きます。|我總是用鋼筆寫信。

シャツを 買います|買襯衫
シャツや ネクタイ などを 買います|買襯衫、領帶之類的
デパートで シャツや ネクタイ などを 買いました。|在百貨商店買了襯衫、領帶等。

おんがくを 聞く|聽音樂
おちゃを 飲む|喝茶
おんがくを 聞きながら おちゃを 飲みます。|邊聽音樂邊喝茶。

おなかが いたい|肚子痛
食べて います|有吃飯
あさから 食べて いません。|從早上就沒吃。
おなかが いたくて あさから 何も 食べて いません。|因為肚子痛，從早上就沒吃任何東西。
""",
"""
#N5 #文法
花が さく|花開
花が たくさん さいて|很多花開了
にわが きれい|庭院很美
にわが きれいに なる|庭院變美
花が たくさん さいて にわが きれいに なりました。|因為很多花開了，庭院變得很美。

あたらしい|新的
あたらしく ありません。|不是新的。
この たてものは あたらしく ありません。|這個建築物並不新。

パーティーは たのしいです|派對很有趣
パーティーは たいへん たのしかったです。|派對非常有趣。
パーティーは にぎやかで たいへん たのしかったです。|派對既熱鬧又非常有趣。

あまいです|很甜。
あまくて おいしいです。|很甜、很好吃。
この くだものは あまくて おいしいです。|這種水果很甜、很好吃。

人は じょうぶだ|人很強壯。
かぜを ひきます|感冒。
あの 人は じょうぶだから かぜを ひきません。|那個人很強壯，所以不會感冒。

すき|喜歡
すきでは ありません。|不喜歡。
おさけは あまり すきでは ありません。|我不太喜歡酒。
""",
"""
#N5 #文法
私は 来ました。|我來了
私は 3時間も あるいて 来ました。|我花三個小時也走過來了。
となりの まちから ここまで|從隔壁鎮到這裡
私は となりの まちから ここまで 3時間も あるいて 来ました。|我從隔壁鎮到這裡、花三個小時也走過來了。

そうじを する|掃除
そうじを したあとで|做完掃除後
せんたくを する|洗衣服
きのうは そうじを したあとで せんたくを しました。|昨天掃除後、洗了衣服。

はたらく|工作
はたらいています。|正在工作。
あねは はたらいています。|姊姊正在工作。
あねは ゆうびんきょくで はたらいています。|姊姊正在郵局工作。

休む|休假
しごとを 休みます|工作請假
先週は しごとを 休みました。|上週工作請假了。

あしたは ひまです。|明天很閒。
あしたは 午前も 午後 ひまです。|明天早上、下午都很閒。

おかしを 買う|買甜點
くだものと おかしを 買いました。|我買了水果和甜點。
くだものと おかしを 買いました。ぜんぶで 500円でした。|我買了水果和甜點。全部500日元。
""",
"""
#N5 #文法
ギターを ひく|彈吉他
ギターを 上手に ひきます。|厲害地彈吉他。
田中さんは ギターを 上手に ひきます。|田中先生厲害地彈吉他。

にもつは おもい。|行李很重。
にもつは おもかった。|行李很重。(過去式)
山田さんの にもつは とても おもかったです。|山田先生的行李非常重。

きらい|討厭。
きらいでは ありません。|不討厭。
せんたくは きらいでは ありません。|不討厭洗衣服。

きっさてん|咖啡館
入った きっさてん|去了的咖啡館
きれいです|很美
けさ 入った きっさてんは きれいでした。|早上去了的咖啡店很美

やすむ|休息
あしたは やすみます|明天休息
あしたは やすみたい です。|明天想休息。
あしたは ゆっくり やすみたい です。|明天想悠閒的休息。

かぜが ふる|風吹
電車が とまる|電車停下來
つよい かぜが ふいて、電車が とまりました。|由於強風吹襲，電車停了下來。
""",
"""
#N5 #文法
あぶないです|很危險
およぐ|游泳
およがないで ください。|請不要游泳。
あぶないですから、ここで およがないで ください。|因為很危險，請不要在這游泳。

ばんごはんを 食べる|吃晚飯
しゅくだいを する|做作業
ばんごはんを 食べる 前に しゅくだいを します。|我會在吃晚飯前做作業。

しまります|關上
まどが しまりました|窗戶關上了。
かぜで まどが しまりました。|因為風吹、窗戶關上了。

くつを はく|穿上鞋子
そとに 出ます|出門。
くつを はいて、そとに 出ます。|穿上鞋子、然後出門。

てがみを 書きます。|寫信。
しゅくだいを する|做作業
しゅくだいを した あとで|做完作業後
しゅくだいを した あとで てがみを 書きます。|做完作業後，寫信。

出る|離開
家を 出る|離開家
7時に 家を 出ます。|七點離開家。
""",
"""
#N5 #文法
話す|說話
友だちと 話す|和朋友說話
友だちと 話しました|和朋友聊過了
友だちと 電話で 話しました。|在電話里和朋友們聊過了。

よぶ|叫
よびました|叫了
中山さんを よびました。|叫了中山先生。
パーティーに 中山さんを よびました。|叫了中山先生參加聚會。

はじまる|開始
えいがが はじまる|電影開始
9時から えいがが はじまります。|電影從9點開始。

どのぐらい ですか。|有多遠？
駅から どのぐらい ですか。|離車站有多遠？
あなたの 家は 駅から どのぐらい ですか。|你家離車站有多遠？

見る|看
テレビを 見る|看電視
テレビを 見ました|我看了電視
きのう、テレビを 見ませんでした。|昨天我沒看電視。

飲む|喝
小川さんだけ 飲みます。|只有小川先生有喝。
小川さんだけ おさけを 飲みます。|只有小川有喝酒。
""",
"""
#N5 #文法
あつい です|很熱。
今日は あつい です。|今天很熱。
今日は とても あつい ですね。|今天非常熱。

のる|乘坐
タクシーに のる|乘坐計程車
ここで タクシーに のります。|從這裡搭計程車。

雨が ふる|下雨
雨が ふっている|正在下雨
出かける|出去
今日は 出かけません|今天不會出去。
雨が ふっているから、今日は 出かけません。|因為正在下雨，今天我不會出去。

食べる|吃
ケーキを 食べない|不吃蛋糕
私のケーキを 食べないで ください。|請不要吃我的蛋糕。

カメラは あります|有相機。
カメラは どこにありますか。|相機在哪裡？
きのう買った|昨天買的。
私が きのう買った|我昨天買的
私が きのう買った カメラは どこにありますか。|我昨天買的相機在哪裡？

おんがくを 聞く|聽音樂
ごはんを つくる|做晚餐
おんがくを 聞きながら、ごはんを つくります。|邊聽音樂，邊做飯。
""",
"""
#N5 #文法
びょういんへ 行く|去醫院
びょういんへ 行きます。|去醫院。(禮貌)
びょうきに なった時は|生病時
びょうきに なった時は びょういんへ 行きます。|生病時、去醫院。

食べる|吃
食べたい|想吃。
くだものが 食べたいです。|想吃水果。

あかるい|明亮
あかるく する|使明亮
へやを あかるく する|使房間更明亮
へやを もっと あかるく して ください。|請使房間更加地明亮。

学生です|是學生。
あの人は 学生です|那個人是學生。
あの人は 学生 でしょう。|那個人是學生吧。
あの人は たぶん 学生 でしょう。|那個人可能是學生吧。

なる|變
よくなる|變好
天気が よくなる|天氣變好
天気が よくなりました。|天氣變好了。
""",
"""
#N5 #文法
今日は ねます。|今天要睡覺。
今日は はやく ねます。|今天要早點睡覺。

ねる|睡覺
きのうは ねました。|昨天睡了覺
きのうは 6時間ぐらい ねました。|昨天大概睡了6個小時。

こちらです。|在這裡。
へやは こちらです。|房間在這裡。
先生の へやは こちらです。|老師的房間在這裡。

好き|喜歡。
すきでは ありません。|不喜歡。
スポーツは すきでは ありません。|不喜歡運動。

しめる|關閉
しまっている|是關著的。
しまっています。|是關著的。(禮貌)
ドアが しまっています。|門是關著的。

さいふや かぎ など|錢包和鑰匙之類的
さいふや かぎ などが あります。|有錢包和鑰匙之類的。
かばんの 中に さいふや かぎ などが あります。|包包裡有錢包和鑰匙之類的。
""",
"""
#N5 #文法
みかんは いくらですか。|橘子多少錢？
この みかんは ぜんぶで いくらですか。|這些橘子全部多少錢？

話す|說話
話しましょう|說吧
日本語で 話しましょう。|用日文說吧。

来ません。|不會來。
バスは 来ませんでした。|公車沒來。(過去式)
まちます|等待
30分ぐらい まちました|等待了大約30分鐘
30分ぐらい まちました、バスは 来ませんでした。|等待了大約30分鐘，公車沒來。

天気が いいです。|天氣很好。
天気が よかったです。|天氣很好。(過去式)
きのうは 天気が よかったです。|昨天天氣很好。

ちょっと まって|等一下
ちょっと まって ください。|請等一下。
すみません、ちょっと まって ください。|對不起，請等一下。
""",
"""
#N5 #文法
これは しゃしんです。|這是照片。
これは とった しゃしんです。|這是拍了的照片。
友だちの 家で|在朋友家
せんしゅうの 友だちの 家で|上週在朋友家
これは せんしゅうの 友だちの 家で とった しゃしんです。|這是上週在朋友家拍了的照片。

つくる|製作
ごはんを つくりました。|做了飯。
帰って、ごはんを つくりました。|回家後、做了飯。
よるは 帰って、ごはんを つくりました。|晚上回家後、做了飯。
きのうの よるは 6時に 帰って、ごはんを つくりました。|昨天晚上6點回家後、做了飯。

うたう|唱歌
うたいます|唱歌(禮貌)
うたいましょう|唱歌吧
いっしょに うたいましょう。|一起唱歌吧。

行きます。|會去
あそびに 行きませんか。|要一起出去玩嗎？
あしたは ひまだ|明天有空
あしたは ひまだから、あそびに 行きませんか。|既然明天有空，要一起出去玩嗎？
""",
"""
#N5 #文法
コーヒーを 飲む|喝咖啡
コーヒーを 飲みます。|喝咖啡。(禮貌)
つめたい コーヒーを 飲みます。|喝冰咖啡。
あついとき、つめたい コーヒーを 飲みます。|天氣很熱的時候，會喝冰咖啡。

山川さんと 話す|與山川先生交談
ごはんを 食べる|吃飯
山川さんと 話しながら、ごはんを 食べました。|與山川先生交談時，我吃了飯。

さむい|冷
さむくない|不冷
あまり さむく ありません|不是很冷
きのうは あまり さむく ありませんでした。|昨天不是很冷。

はじまる|開始
はじまりません。|沒開始。
パーティーは はじまりません。|派對沒開始。
パーティーは まだ はじまりません。|派對還沒開始。

おんがくを 聞く|聽音樂
おんがくを 聞きます|聽音樂(禮貌)
どんな おんがくを 聞きますか。|你聽什麼樣的音樂？
""",
"""
#N5 #文法
古いです。|太舊了。
レストランは 古いです。|餐廳很舊。
あの レストランは 古いです。|那家餐館很舊。

食べる|吃
食べます|吃(禮貌)
食べました|吃了
何か 食べましたか|吃了什麼嗎？
けさは 何か 食べましたか。|早上吃了什麼嗎？

もらう|收到
もらいます|收到(禮貌)
てがみを もらいました。|收到了信。
私は てがみを もらいました。|我收到了信。
私は かぞくから てがみを もらいました。|我收到了家人的來信。

とまる|停下
とまりました。|停下了。
電車が とまりました。|電車停了下來。
つよい かぜで|由於強風
つよい かぜで 電車が とまりました。|因為強風、電車停了下來。

電話を する|打電話
電話を しました|打了電話。
父に 電話を しました。|打了電話給父親。
友だちには しません|對朋友沒有那樣做。
でも 友だちには しませんでした。|但對朋友沒有那樣做。
父に 電話を しました。でも 友だちには しませんでした。|我打了電話給父親。但對朋友沒有那樣做。
""",
"""
#N5 #文法
行きます。|去
びょういんへ 行きます。|去醫院。
母は びょういんへ 行きます。|媽媽去了醫院。
1ヶ月に いっかい。|一個月一次。
母は 1ヶ月に いっかい びょういんへ 行きます。|媽媽一月去醫院一次。

べんきょうします。|學習。
私は べんきょうします。|我學習。
私は としょかんで べんきょうします。|我在圖書館學習。
私は ときどき としょかんで べんきょうします。|我偶爾在圖書館學習。

ギターを 弾く。|彈吉他。
ギターを ひきました。|彈了吉他。
だれが ギターを ひきました。|某人彈了吉他。
パーティーで、だれが ギターを ひきました。|某人在派對上彈了吉他。

えいがを 見ます|看電影。
友だちと えいがを 見ました。|和朋友看了電影。
友だちと いっしょに えいがを 見ました。|和朋友一起看了電影。
""",
"""
#N5 #文法
おもしろい|有趣。
おもしろくない|不有趣
えいがは おもしろくない|電影不有趣
えいがは おもしろくなかった|電影不有趣
この えいがは おもしろくなかったよ。|這部電影並不有趣。

来ません。|沒來。
だれも　来ません。|誰都沒來。
だれも 来ませんでした。|誰都沒來。(過去式)
きのうは だれも 来ませんでした。|昨天誰都沒來。

つよい。|強。
かぜが つよい。|風很強。
かぜが つよいでしょう。|預計風會很強。
あしたは かぜが つよいでしょう。|明天預計風會很強。

すき。|喜歡。
やさいが すき。|喜歡蔬菜。
やさいが すきではありません。|不喜歡蔬菜。
やさいが すきではありませんでした。|不喜歡蔬菜。(過去式)
こどもの時 やさいが すきではありませんでした。|小時候不喜歡蔬菜。
""",
"""
#N5 #文法
だれですか。|是誰？
人は だれですか。|人是誰？
休む人は だれですか。|休假的人是誰？
来週 休む人は だれですか。|下週休假的人是誰？

あります。|有。
テストが　あります。|有考試。
月曜日か 火曜日に。|週一或週二。
月曜日か 火曜日に テストが あります。|在周一或週二有考試。

きょうは ありません。|今天沒有。
きょうは いそがしく ありません。|今天不忙。
きょうは あまり いそがしく ありません。|今天不是很忙。

べんりです。|很方便。
たてものは べんりです。|建築物很方便。
エレベーターが ある|有電梯。
たてものは エレベーターが あって|建築物有電梯
あの たてものは エレベーターが あって、べんりです。|那個建築物有電梯，所以很方便。
""",
"""
#N5 #文法
する|實行
しています|正在實行
テストを しています|正在考試。
して ください。|請做。
しずかに して ください。|請保持安靜。
テストを していますから しずかに して ください。|因為正在考試，請保持安靜。

曲がる。|轉彎
左に 曲がる。|左轉。
こうさてんを 左に 曲がる。|在交叉點左轉。
こうさてんを 左に 曲がって ください。|請在交叉點左轉。
その こうさてんを 左に まがって ください。|請在那個交叉點左轉。

つくる。|製作
つくります。|製作。(禮貌)
りょうりは つくります。|做料理。
りょうりは 自分で つくります。|自己做料理。

あります。|有。
10枚 あります。|有十個。
10枚ぐらい あります。|大約有10個。
おさらは 10枚ぐらい あります。|大約有十個盤子。

本です。|書。
あなたの 本ですか。|你的書嗎？
どちらが あなたの 本ですか。|你的書是哪本？
""",
"""
#N5 #文法

あそぶ。|玩。
あそびます。|玩。(禮貌)
あそびました。|玩了。
私は あそびました。|我玩了。
私は いもうとと あそびました。|我和妹妹一起玩了。
私は よく いもうとと あそびました。|我和妹妹一起玩的很盡興了。

行く。|去。
行きます。|去(禮貌)
行きました。|去了
うみへ 行きました。|去了海邊。
バスに のる。|坐公車。
バスに のって、うみへ 行きました。|坐公車、去了海邊。

よぶ。|呼叫。
タクシーを よぶ。|叫計程車。
タクシーを よんで ください。|請幫我叫計程車。

食べる。|吃。
食べましょう。|吃吧。
いっしょに 食べましょう。|一起吃吧。
バナナを いっしょに 食べましょう。|一起吃香蕉吧。
半分にする|分成兩半
バナナを 半分にする|把香蕉分成兩半
バナナを 半分にして いっしょに 食べましょう。|把香蕉分成兩半，一起吃吧。
"""
]
