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