#!/bin/bash
echo "-----------------------------------------------------------------------------"
nodedir="$HOME/sge"
binarnik="sged"
cd $nodedir
git pull
git checkout v1.8.2
make --ignore-errors build -B
sleep 1
if test -f ./build/"$binarnik"
then
    echo "В build"    
else
    echo "В linux"    
fi 
for((;;)); do
    height=$("$binarnik" status |& jq -r .sync_info.latest_block_height)
    if ((height == 8912597)); then
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
