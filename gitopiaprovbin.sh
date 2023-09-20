#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd $HOME
mkdir $HOME/gitopia/build
cd $HOME/gitopia/build
wget https://server.gitopia.com/releases/Gitopia/gitopia/v3.1.0/gitopiad_3.1.0_linux_amd64.tar.gz
tar -xvf gitopiad_3.1.0_linux_amd64.tar.gz
rm -rf gitopiad_3.1.0_linux_amd64.tar.gz
chmod +x gitopiad

for((;;)); do
    height=$(gitopiad status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 6334048)); then
      systemctl stop gitopiad
      mv $HOME/gitopia/build/gitopiad $(which gitopiad)       
      sudo systemctl restart gitopiad
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u gitopiad -f -o cat
