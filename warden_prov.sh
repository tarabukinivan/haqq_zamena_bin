#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="wardend"

for((;;)); do
    height=$("$binarnik" status |& jq -r ."sync_info"."latest_block_height")
    if ((height == 1534500)); then
      systemctl stop "$binarnik"
      mv $HOME/wardenprotocol/build/wardend $(which $binarnik)
      sudo systemctl restart "$binarnik"
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u "$binarnik" -f -o cat
