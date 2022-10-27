# haqq_zamena_bin
```
#!/bin/bash
echo "-----------------------------------------------------------------------------"

cd
if ! [ -d /root/haqq121/ ]; then
mkdir haqq121
fi
cd haqq121
if ! [ -f /root/haqq121/haqq_1.2.1_Linux_arm64.tar.gz ]; then
wget https://github.com/haqq-network/haqq/releases/download/v1.2.1/haqq_1.2.1_Linux_arm64.tar.gz &>/dev/null
fi
a=$(sha256sum haqq_1.2.1_Linux_arm64.tar.gz)
if [[ "$a" != 90e640666bb0e0424aae31f8da3cb2fa207a11f5002988cd7511a8688* ]]
then
  echo -e "check suuma ne sovpadaet.\nVash check: $a"
  exit
fi
tar xvzf haqq_1.2.1_Linux_arm64.tar.gz && rm haqq_1.2.1_Linux_arm64.tar.gz
mv /root/haqq121/bin /root/haqq121/haqq121
mkdir /root/haqq121/haqq120
cp /root/go/bin/haqqd  /root/haqq121/haqq120

m=0
while (("${m}" <= "686300"))
do
    h=$(haqqd status |jq .SyncInfo.latest_block_height)
    # убираем ковычку
    m=$(sed -e 's/^"//' -e 's/"$//' <<<"$h")
    echo "tek vysota" ${m}
    sleep 1
done

cp /root/haqq121/haqq121/haqqd /root/go/bin/

systemctl restart haqqd && journalctl -u haqqd -f -o cat
```
