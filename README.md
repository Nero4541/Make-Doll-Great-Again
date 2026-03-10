<<<<<<< HEAD
# Make-Doll-Great-Again
=======
# PicoClaw Multimedia Plugin

這是一個為 PicoClaw 設計的多媒體外掛程式。它透過一個輕量級的 Bash 腳本 (`run_multimedia.sh`) 運作，負責控制硬體（麥克風、相機、喇叭），並將收集到的影音資料傳送給 PicoClaw 的 Gateway API 進行處理。這一切都不需要修改或重新編譯 PicoClaw 的核心 Go 程式。

## 系統需求與依賴套件

在開始之前，請確保你的系統（例如 Ubuntu 或是 Raspberry Pi）已經安裝了以下工具：

```bash
sudo apt update
sudo apt install -y curl jq alsa-utils v4l-utils ffmpeg
```

- `v4l-utils`: 提供 `v4l2-ctl`，用於從 USB 攝影機擷取影像。
- `alsa-utils`: 提供 `arecord` 和 `aplay`，用於錄音與播放音訊。
- `ffmpeg`: 提供 `ffplay`，用於播放 MP3 或其他格式的音效回應。
- `curl` 和 `jq`: 用於發送 HTTP 請求與解析 JSON 資料。

## 安裝與設定

1. **取得程式碼**
   請確保你已經下載了本專案的所有檔案。

2. **設定設定檔**
   設定檔位於 `workspace/multimedia_config.json`。你可以根據你的硬體設備調整裡面的指令：

   ```json
   {
     "platform": "ubuntu-phone",
     "camera_cmd": "v4l2-ctl --device=/dev/video1 --stream-mmap --stream-to=/tmp/frame.jpg --stream-count=1",
     "audio_record_cmd": "arecord -D default -f cd -t wav -d 3 /tmp/input.wav",
     "audio_play_cmd": "ffplay -nodisp -autoexit /tmp/output.mp3",
     "gateway_url": "http://127.0.0.1:18790",
     "api_key": "YOUR_LLM_API_KEY_HERE"
   }
   ```
   - `camera_cmd`: 拍照指令，請確認 `--device=/dev/video1` 裡的 `/dev/video1` 是你正確的相機設備路徑。
   - `audio_record_cmd`: 錄音指令，這裡預設是錄製 3 秒鐘的音訊。
   - `gateway_url`: 指向 PicoClaw 核心 API 的網址，通常是 `http://127.0.0.1:18790`。
   - `api_key`: 若有需要，請在這裡填上你的 LLM API Key。

3. **給予執行權限**
   如果是第一次執行，你需要給予主腳本執行的權限：
   ```bash
   chmod +x run_multimedia.sh
   ```

## 使用方法

1. **啟動 PicoClaw 核心程式**
   首先，你需要確保原有的 PicoClaw 核心應用程式已經在背景啟動，並且 Gateway API 正常監聽中（例如在 Port 18790）。

2. **啟動多媒體外掛**
   執行主腳本來啟動硬體互動迴圈：

   ```bash
   ./run_multimedia.sh
   ```

3. **開始互動**
   - 啟動後，畫面會顯示 `Press Enter to start recording (or 'q' to quit)...`。
   - 按下 `Enter` 鍵，腳本會同時觸發相機拍照與麥克風錄音（預設 3 秒）。
   - 錄製完成後，程式會將相片與聲音打包並透過 API 送交給 PicoClaw 處理。
   - 當 PicoClaw 回傳語音結果後，硬體會自動播放回應的語音檔案。
   - 若要退出程式，請輸入 `q` 並按下 Enter。

## 注意事項

- 因為核心 `picoclaw_app` 維持不變，所以原本設定在 `config.json` 中的其他通訊頻道（如 Telegram, WhatsApp）等功能完全不受影響，能與硬體外掛同時運作！
- 所有請求共用相同的 `workspace`（記憶體、Agent、身份設定），無論你是用實體硬體還是 Telegram 發送訊息，PicoClaw 都會記得你們之間的對話上下文。
>>>>>>> master
