#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd $HOME/lava
git pull
git checkout v0.6.0
make build
$HOME/lava/build/lavad version --long | grep -e version -e commit

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

#systemctl stop lavad
#mv $HOME/lava/build/lavad $(which lavad)
#lavad version --long | grep -e version -e commit
#systemctl restart lavad && journalctl -u lavad -f -o cat
