#!/bin/bash
echo "-----------------------------------------------------------------------------"
binarnik="pryzmd"
cd $HOME && \
wget -O pryzmd https://storage.googleapis.com/pryzm-zone/core/0.20.0/pryzmd-0.20.0-linux-amd64 && \
chmod +x $HOME/pryzmd && \
old_bin_path="/root/go/bin/"

sleep 1
for((;;)); do
    height=$("$binarnik" status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 1675700)); then
      systemctl stop "$binarnik"
      
      if test -f ./build/"$binarnik"
      then          
          mv $nodedir/build/"$binarnik" $(which $binarnik)
      else         
          mv $nodedir/build/linux/"$binarnik" $(which $binarnik)
      fi      
      sudo systemctl restart "$binarnik"
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u "$binarnik" -f -o cat
