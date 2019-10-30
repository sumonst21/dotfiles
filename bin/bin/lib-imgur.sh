#!/bin/bash

source lib-notify.sh

upload_connect_timeout="5"
upload_timeout="120"
upload_retries="1"
client_id="48b3ad480ab90c5"

function upload_image() {
  echo "Uploading '${1}'..."
  response="$(curl --connect-timeout "$upload_connect_timeout" -m "$upload_timeout" --retry "$upload_retries" -s -H "Authorization: Client-ID $client_id" -F "image=@$1" https://api.imgur.com/3/upload)"

  # imgur response contains stat="ok" when successful
  if [[ "$response" == *"\"success\":true"*  ]]; then
    # cutting the url from the xml response
    img_url=$(echo $response | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["link"]')
    del_url=$(echo $response | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["deletehash"]')
    echo "image  link: $img_url"
    echo "delete link: $del_url"

    echo -n "$img_url" | xclip -selection clipboard
    echo "URL copied to clipboard"

    notify ok "Imgur: Upload done!" "$img_url"

  else # upload failed
    err_msg=$(echo $response | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["data"]["error"]')
    img_url="Upload failed: \"$err_msg\"" # using this for the log file
    echo "$img_url"
    notify error "Imgur: Upload failed :(" "$err_msg"
  fi
}
