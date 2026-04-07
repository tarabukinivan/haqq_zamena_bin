#!/bin/bash
binarnik="lumend"

for((;;)); do
    height=$("$binarnik" status | jq -r '.sync_info.latest_block_height')
    if ((height == 2035000)); then
      systemctl stop "$binarnik"
      systemctl stop lumend2
      mv /root/tmp/"$binarnik" $(which $binarnik)
      sudo systemctl restart "$binarnik"
      sudo systemctl restart lumend2
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u "$binarnik" -f -o cat
