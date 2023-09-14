Надо сделать равно
`haqqd status |jq .SyncInfo.latest_block_height | xargs` <br>
wget -O haqq_prov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/haqq_prov.sh && chmod a+x haqq_prov.sh && ./haqq_prov.sh

Проверить возвращает ли

`lavad status |jq .SyncInfo.latest_block_height | xargs`

текущий блок, если все ок:

wget -O lavad.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/lava_prov.sh && chmod a+x lavad.sh && ./lavad.sh

wget -O sao.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/sao016.sh && chmod a+x sao.sh && ./sao.sh

wget -O compprov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/compprov.sh && chmod a+x compprov.sh && ./compprov.sh

`wget -O cascadiaprov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/cascadiaprov.sh && chmod a+x cascadiaprov.sh && ./cascadiaprov.sh`

wget -O gitopiaprov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/gitopiaprov.sh && chmod a+x gitopiaprov.sh && ./gitopiaprov.sh
