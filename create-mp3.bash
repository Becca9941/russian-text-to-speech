#!/bin/bash

curl -X POST \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
-d @russian-text.json \
https://texttospeech.googleapis.com/v1/text:synthesize | jq -r '.audioContent' | base64 --decode > audio-file.mp3

rm -rf synthesize-output-base64.txt
