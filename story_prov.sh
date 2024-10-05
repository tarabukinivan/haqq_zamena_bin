#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd $HOME
rm -rf story
git clone https://github.com/piplabs/story
cd $HOME/story
git checkout v0.11.0
go build -o story ./client

sleep 1

for((;;)); do
    height=$(curl -s http://167.235.39.5:26657/status | jq -r .result.sync_info.latest_block_height)
    if ((height == 1325860)); then
      systemctl stop story
      sudo mv $HOME/story/story $(which story)        
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
sudo systemctl restart story && sudo journalctl -u story -f
