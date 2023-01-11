wget -O haqqv130.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/haqq130 && chmod a+x haqqv130.sh && ./haqqv130.sh

Проверить возвращает ли
[code]
lavad status |jq .SyncInfo.latest_block_height | xargs
[/code]
текущий блок, если все ок:

wget -O lavad.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/lava043.sh && chmod a+x lavad.sh && ./lavad.sh
