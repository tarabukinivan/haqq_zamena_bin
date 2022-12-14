#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd $HOME
git clone https://github.com/lavanet/lava
m=0
while (("${m}" < "22300"))
do
    m=$(lavad status |jq .SyncInfo.latest_block_height | xargs)
    echo "current height" ${m}
    sleep 1
done


cd $HOME/lava
git fetch --all
git checkout v0.4.3
make install
sudo systemctl restart lavad && sudo journalctl -fu lavad -o cat
