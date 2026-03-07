這是一份為你整理好的最終打包方案 Markdown 文件。你可以直接複製這份內容，作為你專案的 README.md，或是開發時的標準參考指南 (SOP)。

🚀 跨平台 PicoClaw 語音視覺 AI 助理 (PicoClaw-MultiMedia)
📌 1. 專案概述

本專案基於 Sipeed 的極輕量 AI 框架 PicoClaw 進行二次開發，打造一個支援「語音對話 + 視覺辨識」的 AI 實體助理。

支援平台：Ubuntu Phone (ARM64) 與 LicheeRV-Nano W (RISC-V 64-bit)。

輸入端：麥克風 (語音) + 鏡頭 (視覺畫面)。

輸出端：AI 語音合成，支援本機喇叭與自動切換藍牙裝置。

核心優勢：「單一程式碼，雙平台運行」。完美融合 PicoClaw 原生的 workspace 架構，透過 Go 語言跨平台編譯與動態 config.json 適配硬體差異。

🏗️ 2. 系統架構與工作流程

觸發喚醒 (Trigger)：透過實體按鍵 (GPIO) 或螢幕按鈕觸發。

感知輸入 (Input)：

呼叫 Linux 音訊指令 (arecord) 錄製使用者語音。

呼叫 Linux 影像指令 (v4l2-ctl 或 gstreamer) 擷取當前鏡頭畫面。

大腦處理 (Processing)：

STT：將語音檔轉為文字。

PicoClaw Core：結合語音轉譯的文字、當前相機畫面 (Base64)、以及 workspace 內的設定檔 (AGENT.md, SOUL.md 等) 送入多模態大模型 (VLM)。

語音輸出 (Output)：

TTS：將大模型回覆的文字轉為語音檔。

播放：依照 config.json 的設定，透過喇叭或藍牙 (aplay -D bluealsa / ffplay) 播放 AI 聲音。

📂 3. 目錄與檔案結構規範

系統採「執行檔與資料分離」設計。核心設定與媒體暫存檔皆收納於 PicoClaw 標準的 ~/.picoclaw/workspace/ 目錄中。

code
Text
download
content_copy
expand_less
📦 你的專案 (設備端配置)
 ┣ 📜 picoclaw_app          # 執行檔 (Go 編譯出的二進制檔，建議放於 /usr/local/bin)
 ┗ 📂 ~/.picoclaw/
    ┗ 📂 workspace/         # 🧠 PicoClaw 的大腦與靈魂中心
       ┣ 📂 memory/         # [原生] 存放對話歷史與上下文 (SQLite/JSON)
       ┣ 📂 skills/         # [原生] 存放外部工具腳本 (如：主動拍照技能)
       ┣ 📜 AGENT.md        # [原生] 系統指令：定義助理的整體運作規則
       ┣ 📜 IDENTITY.md     # [原生] 身份設定：設定它是一個「有實體的機器人」
       ┣ 📜 SOUL.md         # [原生] 性格設定：語氣、情緒反應
       ┣ 📜 USER.md         # [原生] 你的資料：讓它知道怎麼稱呼你
       ┣ 📜 config.json     # ⚙️ [擴充] 設定檔：加入雙平台的硬體設備參數
       ┗ 📂 temp/           # 🌟 [新增] 多媒體暫存區 (每次對話覆蓋，節省空間)
          ┣ 📜 input.wav    # 當次錄製的語音
          ┣ 📜 frame.jpg    # 當次抓取的鏡頭畫面
          ┗ 📜 output.mp3   # 當次準備播放的合成語音
🧠 4. AI 角色與硬體感知設定 (Markdown 檔)

透過修改 workspace/ 內的 .md 檔案，讓 AI 意識到自己的載體與輸出限制，無需修改任何 Go 程式碼：

IDENTITY.md：

「你是一個運行在 Linux 實體設備上的 AI 助理。你配備了麥克風可以『聽』見聲音，也有鏡頭可以『看』見目前的畫面。」

AGENT.md：

「你的回覆將會被轉換為語音直接播放。因此，你的回答必須保持口語化、簡短扼要，絕對不要使用複雜的 Markdown 標籤、表格或過長的條列式說明。」

⚙️ 5. 雙平台硬體適配策略 (config.json)

保留 PicoClaw 原本的 API 參數，並在 config.json 中加入自訂的 "hardware" 區塊。程式啟動時會根據此區塊決定如何操作硬體。

📱 方案 A：Ubuntu Phone (ARM64) 配置範例
code
JSON
download
content_copy
expand_less
{
  "llm_api_key": "sk-xxxxxx",
  "model": "gpt-4o",
  "hardware": {
    "platform": "ubuntu-phone",
    "camera_cmd": "v4l2-ctl --device=/dev/video1 --stream-mmap --stream-to=~/.picoclaw/workspace/temp/frame.jpg --stream-count=1",
    "audio_record_cmd": "arecord -D default -f cd -t wav -d 3 ~/.picoclaw/workspace/temp/input.wav",
    "audio_play_cmd": "ffplay -nodisp -autoexit ~/.picoclaw/workspace/temp/output.mp3",
    "bluetooth_auto_route": true
  }
}

(註：Ubuntu Touch 使用 PulseAudio，藍牙連線時會自動切換音訊，播放指令保持預設即可。)

📟 方案 B：LicheeRV-Nano W (RISC-V) 配置範例
code
JSON
download
content_copy
expand_less
{
  "llm_api_key": "sk-xxxxxx",
  "model": "gpt-4o",
  "hardware": {
    "platform": "licheerv-nano",
    "camera_cmd": "v4l2-ctl --device=/dev/video0 --stream-mmap --stream-to=~/.picoclaw/workspace/temp/frame.jpg --stream-count=1",
    "audio_record_cmd": "arecord -D hw:0,0 -f S16_LE -r 16000 -d 3 ~/.picoclaw/workspace/temp/input.wav",
    "audio_play_cmd": "aplay -D bluealsa ~/.picoclaw/workspace/temp/output.mp3",
    "bluetooth_auto_route": false
  }
}

(註：LicheeRV 資源有限，錄音降頻至 16000Hz 以節省資源，並可直接指定 bluealsa 輸出至藍牙。)

🛠️ 6. 跨平台編譯與部署指南

在開發環境 (Windows/Mac/Linux) 撰寫好 Go 程式碼後，使用以下指令進行跨平台編譯：

code
Bash
download
content_copy
expand_less
# 1. 編譯 Ubuntu Phone (ARM64) 版本
GOOS=linux GOARCH=arm64 go build -o picoclaw_app_ubuntu

# 2. 編譯 LicheeRV-Nano W (RISC-V 64-bit) 版本
GOOS=linux GOARCH=riscv64 go build -o picoclaw_app_lichee

部署步驟：

將編譯好的執行檔透過 SSH/ADB 傳送至設備。

在設備上的 ~/.picoclaw/workspace/ 中放置對應平台的 config.json 及設定好的 .md 檔。

執行 ./picoclaw_app_xxx 即可啟動你的專屬多媒體 AI 助理！