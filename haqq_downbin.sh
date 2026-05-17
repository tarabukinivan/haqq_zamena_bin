#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="haqqd"
nodedir="$HOME/bin"
cd $nodedir

sleep 1
chmod +x $nodedir/"$binarnik"

echo "new version: $nodedir/$binarnik"
for((;;)); do
    height=$("$binarnik" status |& jq -r ."sync_info"."latest_block_height")
    if ((height == 21551100)); then
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
cd $HOME
journalctl -u "$binarnik" -f -o cat
