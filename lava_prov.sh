#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="lavad"
binarnik2="lavap"
nodedir="$HOME/lava"
nodeversion="v0.25.2"
cd $nodedir
git pull
git checkout $nodeversion
export LAVA_BINARY=lavad
make build -B
export LAVA_BINARY=lavap
make build -B
sleep 1
if test -f ./build/"$binarnik"
then
    echo "В build"    
else
    echo "В linux"    
fi 
for((;;)); do
    height=$("$binarnik" status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 514533)); then
      systemctl stop "$binarnik"
      
      if test -f ./build/"$binarnik"
      then          
          mv $nodedir/build/"$binarnik" $(which $binarnik)
          mv $nodedir/build/"$binarnik2" $(which $binarnik2)
      else         
          mv $nodedir/build/linux/"$binarnik" $(which $binarnik)
          mv $nodedir/build/linux/"$binarnik2" $(which $binarnik2)
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
