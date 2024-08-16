#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="emped"

for((;;)); do
    height=$("$binarnik" status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 12380500)); then
      systemctl stop "$binarnik"
      mv $HOME/tmp/empedbin/$binarnik $(which $binarnik)
      sudo systemctl restart "$binarnik"
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u "$binarnik" -f -o cat
