#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd $HOME
rm -rf lava
git clone https://github.com/lavanet/lava
cd $HOME/lava
git checkout v0.6.0

m=0
while (("${m}" < "82570"))
do
    m=$(lavad status |jq .SyncInfo.latest_block_height | xargs)
    dig=`echo "digid" | awk '/(^[0-9]{2,6}$)/'${m}`
    if [ "$dig" = "digid" ];then
      echo "current height" ${m}
    else
      echo "net otveta"
      m=0
    fi
    sleep 1
done

sudo systemctl stop lavad
make install
lavad version --long | head
sudo systemctl restart lavad && sudo journalctl -u lavad -f -o cat
