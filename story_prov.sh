#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="story"
nodedir="$HOME/story"
release="story-linux-amd64-0.9.12-9ae4a63.tar.gz"
resleasename="story-linux-amd64-0.9.12-unstable-9ae4a63"
storyservice="story-testnet.service"
cd $nodedir
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/$release
tar xvzf $release
rm $release
mv $resleasename/"$binarnik" $(which $binarnik)

sleep 1

for((;;)); do
    height=$(curl -s http://167.235.39.5:26657/status | jq -r .result.sync_info.latest_block_height)
    if ((height == 1607234)); then
      systemctl stop "$binarnik"
      mv $resleasename/"$binarnik" $(which $binarnik)      
      sudo systemctl restart "$storyservice"
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u "$storyservice" -f -o cat
