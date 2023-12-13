#!/bin/bash
echo "-----------------------------------------------------------------------------"

binarnik2="lavap"
nodedir="$HOME/lava"
nodeversion="v0.31.1"
cd $nodedir
git pull
git checkout $nodeversion
export LAVA_BINARY=lavap
make build -B
sleep 1
if test -f ./build/"$binarnik2"
then
    echo "В build"    
else
    echo "В linux"    
fi 
for((;;)); do
    height=$(lavad status |& jq -r ."SyncInfo"."latest_block_height")
    if ((height == 671912)); then
          mv $nodedir/build/"$binarnik2" $(which $binarnik2)
      echo "restart"
      break
    else
      echo $height
    fi
    sleep 1
done

systemctl restart provider-lava-evmosm

systemctl restart provider-lava-axelarm
