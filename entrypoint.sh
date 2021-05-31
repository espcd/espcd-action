#!/bin/bash

platform=$(echo ${INPUT_FQBN} | sed 's|\(.*\):.*|\1|')

options=""
if [[ ${platform} == "esp32:esp32" ]] ;
then
    options="--additional-urls \"https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json\""
fi
if [[ ${platform} == "esp8266:esp8266" ]] ;
then
    options="--additional-urls \"https://arduino.esp8266.com/stable/package_esp8266com_index.json\""
fi

# install core
arduino-cli core update-index ${options}
arduino-cli core install ${platform} ${options}

# install dependencies
mkdir -p ~/Arduino/libraries
git clone https://github.com/espcd/espcd-library.git ~/Arduino/libraries/espcd-library
arduino-cli lib install AutoConnect
arduino-cli lib install ArduinoJson

# compile sketch
arduino-cli compile --fqbn ${INPUT_FQBN} --output-dir /tmp "${INPUT_SKETCH}"

# set firmware path
filename=$(basename "${INPUT_SKETCH}")
firmware_file="/tmp/${filename}.bin"

# upload firmware
curl \
    --silent \
    --show-error \
    --fail \
    --include \
    --request POST "${INPUT_URL}" \
    -F "[firmware]product_id=${INPUT_PRODUCT}" \
    -F "[firmware]title=${INPUT_TITLE}" \
    -F "[firmware]description=${INPUT_DESCRIPTION}" \
    -F "[firmware]version=${GITHUB_SHA}" \
    -F "[firmware]fqbn=${INPUT_FQBN}" \
    -F "[firmware]content=@${firmware_file}"
