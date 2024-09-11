#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="layerd"
nodedir="$HOME/layer"
nodeversion="v0.7.1-alpha1"
cd $nodedir
git pull
git checkout $nodeversion
make build -B
sleep 1
if test -f ./build/"$binarnik"
then
    echo "В build"    
else
    echo "В linux"    
fi 
for((;;)); do
    height=$("$binarnik" status |& jq -r ."sync_info"."latest_block_height")
    if ((height == 1607234)); then
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
