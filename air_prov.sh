#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik="junctiond"
nodedir="$HOME/junction"
nodeversion="v0.2.0"
cd
cd $nodedir
git checkout $nodeversion
make build
mv $nodedir/build/junction-jip-2 $nodedir/build/junctiond
sleep 1
if test -f ./build/"$binarnik"
then
    echo "В build"    
else
    echo "В linux"    
fi 
for((;;)); do
    height=$("$binarnik" status |& jq -r ."sync_info"."latest_block_height")
    if ((height == 2383911)); then
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
