
wget -O haqq_prov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/haqq_prov.sh && chmod a+x haqq_prov.sh && ./haqq_prov.sh

Проверить возвращает ли

`lavad status |jq .SyncInfo.latest_block_height | xargs`

текущий блок, если все ок:

wget -O lavad.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/lava_prov.sh && chmod a+x lavad.sh && ./lavad.sh

wget -O lavapupd.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/lavapprov.sh && chmod a+x lavapupd.sh && ./lavapupd.sh

wget -O entrypoint.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/entrypoint_prov.sh && chmod a+x entrypoint.sh && ./entrypoint.sh

wget -O sao.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/sao016.sh && chmod a+x sao.sh && ./sao.sh

wget -O compprov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/compprov.sh && chmod a+x compprov.sh && ./compprov.sh

`wget -O cascadiaprov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/cascadiaprov.sh && chmod a+x cascadiaprov.sh && ./cascadiaprov.sh`

wget -O gitopiaprov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/gitopiaprov.sh && chmod a+x gitopiaprov.sh && ./gitopiaprov.sh

wget -O gitopiaprovbin.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/gitopiaprovbin.sh && chmod a+x gitopiaprovbin.sh && ./gitopiaprovbin.sh

wget -O sge_prov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/sge_prov.sh && chmod a+x sge_prov.sh && ./sge_prov.sh

wget -O sgetestnetprov.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/main/sgetestnetprov.sh && chmod a+x sgetestnetprov.sh && ./sgetestnetprov.sh
