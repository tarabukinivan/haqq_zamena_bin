#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="emped"
nodedir="$HOME/empe-chain"
nodeversion="0.3.0"
cd $nodedir

for((;;)); do
    height=$("$binarnik" status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 3871292)); then
      systemctl stop "$binarnik"
      mv $nodedir/"$binarnik" $(which $binarnik)      
      sudo systemctl restart "$binarnik"
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u "$binarnik" -f -o cat
