#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="lavad"
nodedir="$HOME/lava"
nodeversion="v0.33.0"
cd $nodedir
git pull
git checkout $nodeversion
export LAVA_BINARY=lavad
make build -B
if test -f ./build/"$binarnik"
then
    echo "В build"    
else
    echo "В linux"    
fi 
for((;;)); do
    height=$("$binarnik" status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 764400)); then
      systemctl stop "$binarnik"
      
      if test -f ./build/"$binarnik"
      then          
          mv $nodedir/build/"$binarnik" $(which $binarnik)         
      else         
          mv $nodedir/build/linux/"$binarnik" $(which $binarnik)         
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
