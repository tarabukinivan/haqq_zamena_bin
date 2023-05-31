Надо сделать равно
`haqqd status |jq .SyncInfo.latest_block_height | xargs` <br>
wget -O haqqv131.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/haqq131 && chmod a+x haqqv131.sh && ./haqqv131.sh

Проверить возвращает ли

`lavad status |jq .SyncInfo.latest_block_height | xargs`

текущий блок, если все ок:

wget -O lavad.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/lava12.sh && chmod a+x lavad.sh && ./lavad.sh

wget -O sao.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/sao && chmod a+x sao.sh && ./sao.sh
