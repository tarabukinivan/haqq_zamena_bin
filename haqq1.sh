#!/bin/bash
cd
m=0
while (("${m}" < "684935"))
do
    m=$(haqqd status |jq .SyncInfo.latest_block_height | xargs)
    echo "current height" ${m}
    sleep 1
done

sudo systemctl stop haqqd
cd $HOME && rm -rf haqq
git clone https://github.com/haqq-network/haqq && cd haqq
git checkout v1.2.1
make install

sleep 1
systemctl restart haqqd && journalctl -u haqqd -f -o cat
