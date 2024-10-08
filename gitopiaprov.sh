#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="gitopiad"
nodedir="$HOME/gitopia"
nodeversion="v4.0.0"
cd $nodedir
git pull
git checkout $nodeversion
make build
sleep 1
if test -f ./build/"$binarnik"
then
    echo "В build"    
else
    echo "В bin"    
fi 
for((;;)); do
    height=$("$binarnik" status 2>&1 | jq -r ."SyncInfo"."latest_block_height")
    if ((height == 24330422)); then
      systemctl stop "$binarnik"
      
      if test -f ./build/"$binarnik"
      then          
          mv $nodedir/build/"$binarnik" $(which $binarnik)
      else         
          mv $nodedir/bin/"$binarnik" $(which $binarnik)
      fi      
      sudo systemctl restart "$binarnik"
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done
journalctl -u "$binarnik" -f -o cat
