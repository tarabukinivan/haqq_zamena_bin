#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd $HOME/lava
git pull
git checkout v0.7.0-RC1
make build
$HOME/lava/build/lavad version --long | grep -e version -e commit

for((;;)); do
    height=$(lavad status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height==102800)); then
      systemctl stop lavad
      mv $HOME/lava/build/lavad $(which lavad)
      sudo systemctl restart lavad
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u lavad -f -o cat
