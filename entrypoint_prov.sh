#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd $HOME
if ! [ -d $HOME/tmp/ ]; then
mkdir $HOME/tmp
fi
cd $HOME/tmp

wget -O entrypointd https://github.com/entrypoint-zone/testnets/releases/download/v1.3.0/entrypointd-1.3.0-linux-amd64
chmod +x entrypointd

for((;;)); do
    height=$(entrypointd status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 680000)); then
      systemctl stop entrypointd
      mv $HOME/tmp/entrypointd /root/go/bin/entrypointd
      sudo systemctl restart entrypointd && journalctl -u entrypointd -f -o cat
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
