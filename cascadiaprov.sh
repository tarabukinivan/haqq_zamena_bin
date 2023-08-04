#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="cascadiad"
cd $HOME/cascadia
git pull
git checkout v0.1.4
make build
sleep 1
if test -f ./build/"$binarnik"
then
    echo "В build"    
else
    echo "В linux"    
fi 
for((;;)); do
    height=$("$binarnik" status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height > 1774000)); then
      systemctl stop "$binarnik"
      
      if test -f ./build/"$binarnik"
      then          
          mv $HOME/sao-consensus/build/"$binarnik" $(which "$binarnik")
      else         
          mv $HOME/sao-consensus/build/linux/"$binarnik" $(which "$binarnik")
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
