#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="centaurid"
nodedir="$HOME/composable-centauri"
nodeversion="v4.0.2"
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
    height=$("$binarnik" status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 792909)); then
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
