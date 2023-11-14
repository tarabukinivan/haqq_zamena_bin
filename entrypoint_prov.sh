#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd $HOME
if ! [ -d $HOME/tmp/ ]; then
mkdir $HOME/tmp
fi
cd $HOME/tmp

wget https://github.com/entrypoint-zone/testnets/releases/download/v1.2.0/entrypointd-1.2.0-linux-amd64.tgz &>/dev/null

tar xvzf entrypointd-1.2.0-linux-amd64.tgz && rm entrypointd-1.2.0-linux-amd64.tgz



for((;;)); do
    height=$(entrypointd status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 351000)); then
      systemctl stop entrypointd
      mv $HOME/tmp/build/entrypointd-1.2.0-linux-amd64 /root/go/bin/entrypointd
      sudo systemctl restart entrypointd && journalctl -u entrypointd -f -o cat
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
