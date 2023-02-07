#!/bin/bash
echo "-----------------------------------------------------------------------------"

m=0
while (("${m}" < "63760"))
do
    m=$(lavad status |jq .SyncInfo.latest_block_height | xargs)
    echo "current height" ${m}
    sleep 1
done


cd $HOME/lava
git fetch --all
git checkout v0.5.2
make install
lavad version --long | head
sudo systemctl restart lavad && sudo journalctl -u lavad -f -o cat
