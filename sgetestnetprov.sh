#!/bin/bash
echo "-----------------------------------------------------------------------------"
nodedir="$HOME/sge"
binarnik="sgetd"
pute=`which $binarnik`
cd $nodedir
git pull
git checkout v1.3.0
make --ignore-errors build
sleep 1
if test -f ./build/"$binarnik"
then
    echo "В build"    
else
    echo "В linux"    
fi 
for((;;)); do
    height=$("$binarnik" status --home $HOME/.sget |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 727796)); then
      systemctl stop "$binarnik"
      
      if test -f ./build/"$binarnik"
      then          
          mv $nodedir/build/sged $(which $binarnik)
      else         
          mv $nodedir/build/linux/sged $(which $binarnik)
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
