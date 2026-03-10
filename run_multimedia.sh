#!/bin/bash
# Multimedia Plugin for PicoClaw

CONFIG_FILE="workspace/multimedia_config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

# We use grep/sed as a lightweight way to parse JSON in bash if jq is not available on minimal boards
CAMERA_CMD=$(grep '"camera_cmd"' $CONFIG_FILE | sed -E 's/.*"camera_cmd": "(.*)",/\1/')
AUDIO_RECORD_CMD=$(grep '"audio_record_cmd"' $CONFIG_FILE | sed -E 's/.*"audio_record_cmd": "(.*)",/\1/')
AUDIO_PLAY_CMD=$(grep '"audio_play_cmd"' $CONFIG_FILE | sed -E 's/.*"audio_play_cmd": "(.*)",/\1/')
GATEWAY_URL=$(grep '"gateway_url"' $CONFIG_FILE | sed -E 's/.*"gateway_url": "(.*)",/\1/')

echo "Starting PicoClaw Multimedia Loop..."
echo "Gateway: $GATEWAY_URL"

while true; do
    read -p "Press Enter to start recording (or 'q' to quit)... " choice
    if [ "$choice" = "q" ]; then
        break
    fi

    echo "📸 Capturing image..."
    eval $CAMERA_CMD &
    
    echo "🎤 Recording audio for 3 seconds..."
    eval $AUDIO_RECORD_CMD
    
    echo "🧠 Sending to PicoClaw API..."
    # Convert image to base64
    B64_IMAGE=$(base64 -w 0 /tmp/frame.jpg)
    
    # Send to Gateway API (Assuming a hypothetical /chat/multimedia endpoint)
    # Note: Actual endpoint path needs to be verified against PicoClaw's API docs
    RESPONSE=$(curl -s -X POST "${GATEWAY_URL}/chat" \
        -H "Content-Type: application/json" \
        -d "{
            \"message\": \"Please analyze the audio and image.\",
            \"audio_path\": \"/tmp/input.wav\",
            \"image_base64\": \"data:image/jpeg;base64,${B64_IMAGE}\"
        }")
    
    # Extract audio response path or TTS the text response
    # This part depends heavily on the exact JSON schema of PicoClaw's Gateway response.
    echo "🔊 Playing response..."
    # eval $AUDIO_PLAY_CMD
done