# Shadowing (影讀)
An app that trains your speaking via Text-To-Speech and Speech Recognition

## MVP for 1.0
### 解決的問題：
* 隨時隨地的增強口說能力 (日本語)

### Main Flow
1. 每一句 (siri 唸 -> 使用者跟著唸 -> 辨識 (辨識時播下一句話))
2. 算分
3. 統計、追蹤進度 

<img src="https://raw.githubusercontent.com/wangchou/Shadowing/master/img/shadowing_flow.jpg" height="300">

### 內容
* 日常對話 100 句 / 歌詞 (一個 set 1分鐘 ~ 5分鐘)

### 統計
* 統計：閱讀時間、正確率、唸單字的數量
* 定每週學習目標，像是小米手錶一樣，表示每週練習的統計
* 像是 kobo e-reader 一樣顯示進度百分比、預計多久可以達成目標

### 細節
* 開始、暫停的 button
* TTS 文章的時候，像 pocket 一樣，在唸出的字下面上螢光筆顏色
* 有耳機時，分左、右聲道，一邊是 TTS 一邊是自己唸的聲音
* 每句話之間要有空白時間

### 可調整的功能
* 可以調整唸的速度
* TTS 選擇中文腔、英國腔、美國腔、日文、男聲女聲
* 可以 replay 每一句 (siri + 使用者說的 @ 左右耳)
* 只跟讀，不辨識模式
* 偽裝成講電話的模式
* 同步/非同步跟讀模式

## UI 頁面規劃
* 跟讀頁 (v0.1)： 讓使用者跟著 Siri 唸的頁面。回饋、遊戲感、回放、速度、左右聲道、辨識...
* 內容頁 (v0.2)： 選取要跟讀的內容
* 統計頁 (v0.3)： 設定每週目標、目前的進度、歷史紀錄、正確率...
* 設定頁 (v1.0)
* 教學頁面 (v2.0)
* 回報頁面 (v2.0)
* 個人頁面 (v3.0)：Offline 錄音分享
