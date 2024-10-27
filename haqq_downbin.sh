#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="haqqd"
nodedir="$HOME/haqq"
release="https://github.com/haqq-network/haqq/releases/download/v1.8.2/haqq_1.8.2_linux_amd64.tar.gz"
cd $HOME
rm -rf $nodedir
mkdir -p $nodedir
wget -O $nodedir/haqq_1.8.2_linux_amd64.tar.gz $release
sleep 1
cd $nodedir
tar -xvzf haqq_1.8.2_linux_amd64.tar.gz
sleep 1
for((;;)); do
    height=$("$binarnik" status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 13684000)); then
      systemctl stop "$binarnik" 
          mv $nodedir/bin/"$binarnik" $(which $binarnik)
      sudo systemctl restart "$binarnik"
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
cd $HOME
rm -rf $nodedir
journalctl -u "$binarnik" -f -o cat
