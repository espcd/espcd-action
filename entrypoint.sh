#!/bin/bash

platform=$(echo ${INPUT_FQBN} | sed 's|\(.*\):.*|\1|')
options=""
if [[ ${platform} == "esp32:esp32" ]]
then
    options="--additional-urls \"https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json\""
fi
if [[ ${platform} == "esp8266:esp8266" ]]
then
    options="--additional-urls \"https://arduino.esp8266.com/stable/package_esp8266com_index.json\""
fi

echo "Update arduino cli core index"
arduino-cli core update-index ${options}

echo "Install arduino cli core and tool dependencies"
arduino-cli core install ${platform} ${options}

echo "Install espcd-library dependency"
mkdir -p ~/Arduino/libraries
git clone https://github.com/espcd/espcd-library.git ~/Arduino/libraries/espcd-library

echo "Install AutoConnect dependency"
arduino-cli lib install AutoConnect

echo "Install ArduinoJson dependency"
arduino-cli lib install ArduinoJson

echo "Compile the arduino sketch"
arduino-cli compile --fqbn ${INPUT_FQBN} --output-dir /tmp "${INPUT_SKETCH}"

echo "Upload compiled firmware to espcd-backend"
filename=$(basename "${INPUT_SKETCH}")
firmware_file="/tmp/${filename}.bin"

if [[ "${INPUT_COMPRESSION}" == "gzip" ]]
then
    gzip -c "${firmware_file}" > "${firmware_file}".gz
    firmware_file="${firmware_file}".gz
fi
response=$(
    curl \
        --silent \
        --show-error \
        --fail \
        --request POST \
        "${INPUT_URL}/firmwares?api_key=${INPUT_API_KEY}" \
        -F "[firmware]title=${INPUT_TITLE}" \
        -F "[firmware]description=${INPUT_DESCRIPTION}" \
        -F "[firmware]version=${GITHUB_SHA}" \
        -F "[firmware]fqbn=${INPUT_FQBN}" \
        -F "[firmware]content=@${firmware_file}"
)
firmware_id=$(echo ${response} | jq ".id")

if [[ "${INPUT_PRODUCT}" ]]
then
    curl \
        --silent \
        --show-error \
        --fail \
        --request PATCH \
        "${INPUT_URL}/products/${INPUT_PRODUCT}/firmware/${INPUT_FQBN}?api_key=${INPUT_API_KEY}" \
        -F "firmware_id=${firmware_id}"
fi
