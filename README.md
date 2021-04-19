# namecheap-ddns-client

DDNS-Client for Namecheap

```
sudo apt update && sudo apt install jq
```

```
{
    "hosts":[
       {
          "host":"YOUR_SUBDOMAIN",
          "password":"YOUR_NAMECHEAP_DDNS_PASSWORD",
          "domain":"YOUR_DOMAIN_NAME.TLD"
       }
    ]
 }
```

```
    "hosts":[
       {
        "host":"test",
        "password":"provided-by-namecheap-ddns-service",
        "domain":"yourdomain.com"
       }
    ]
 }
```

```
[Unit]
Description=Namecheap DDNS updating service.
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
WorkingDirectory=/home/{YOUR_USER_FOLDER}/ncddns
ExecStart=/bin/bash /home/{YOUR_USER_FOLDER}/ncddns/ncddns.sh conf/ddns.json

[Install]
WantedBy=multi-user.target
```

```
cd ncddns
sudo cp systemd-service/ncddns.service /etc/systemd/system/
```

```
sudo systemctl daemon-reload
sudo systemctl enable ncddns.service
sudo systemctl start ncddns.service
sudo systemctl status ncddns.service
```

```
● ncddns.service - Namecheap DDNS updating service.
     Loaded: loaded (/etc/systemd/system/ncddns.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-04-19 10:24:57 GMT; 1h 6min ago
   Main PID: 27576 (bash)
      Tasks: 2 (limit: 1826)
     CGroup: /system.slice/ncddns.service
             ├─27576 /bin/bash /home/{YOUR_USER_FOLDER}/ncddns/ncddns.sh conf/ddns.json
             └─28634 sleep 5m

Apr 19 11:13:40 server_name bash[27576]: 19-04-2021 11:13:40 - Successfully updated dynamic DNS: 'YOUR_SUBDOMAIN.YOUR_DOMAIN.TLD' to 00.00.00.00 - HTTP Status: 200
```

```
0 8 * * * find /home/{YOUR_USER_FOLDER}/ncddns/log/*.log -delete
```
