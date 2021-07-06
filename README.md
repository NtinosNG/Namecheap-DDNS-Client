# DDNS-Client for Namecheap

## What this script does

<hr>

If you own a domain and you bought it from namecheap.com then you've probably learned that they offer DDNS service for your domain and now you're looking for a client service to update your custom addresses. This script does exactly that! It gets all the instructions from [here](https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-do-i-use-a-browser-to-dynamically-update-the-hosts-ip/) and uses [curl](https://curl.se/) (instead of a browser) to update your IP addresses every 5 minutes by running as a [systemd](https://en.wikipedia.org/wiki/Systemd) service so that you won't have to do anything else after you set it up! So, if you have a server that runs 24/7 this script might be what you're looking for!

## What is required

In order for this script to work, the following are required:

- A server that'll run 24/7 at the place where the dynamic addresses will be updated (this could be a Raspberry Pi, NAS, Router etc).
- The server should use **systemd** service manager
- [**jq**](https://stedolan.github.io/jq/) JSON processor installed on the server

## How to set it up

> -- NOTICE -- I'm personally using the script on a Raspberry Pi that runs Ubuntu server 20.04, so the commands that I'll be using are going to work on Ubuntu or some other Debian-based distro. However, if you're using a different distro that uses **systemd** then simply adjust the commands accordingly.

1. Download the script on `home/user` folder by either using **Git** or clicking on the **Download zip** button or maybe with `wget` if you don't have a GUI and have/want to use the terminal. For example, to download the zip with `wget` you can do something like:

```
wget https://github.com/NtinosNG/namecheap-ddns-client/archive/refs/heads/main.zip
```

Then, unzip it with `unzip`. If you don't have it you can simple run `sudo apt install unzip` to install it, and then run:

```
unzip main.zip
```

Now if you run `ls` on your user folder it'll look like this:

```
main.zip  namecheap-ddns-client-main
```

It is important to rename the script's folder to `ncddns`, so to do that simple run:

```
mv namecheap-ddns-client-main ncddns
```

Lastly, run `cd ncddns` to change your directory to the script's folder. If you run `ls` in the folder, you're gonna see the following structure:

```
LICENSE  README.md  conf  ncddns.sh  systemd-service
```

The `LICENSE` and `README.md` files don't need any explanation obviously. So, `ncddns.sh` it's the script itself, and `conf` and `systemd-service` folders contain the `ddns.json` and `ncddns.service` files that we'll use to configure our custom domains and run the script as a service respectively.

2. The second step involves configuring your custom addresses, which is a matter of editting the JSON file. By using your favourite editor, `vim`, `nano` etc. edit the `ddns.json` file which you'll notice initially contains the following:

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

As you can see, all you need to do is to replace the three keys, `host`, `password` and `domain` according to your own custom addresses and simply save the file! So, if you wanted to setup ddns for `test.yourdomain.com` for example, you should replace the keys as follows:

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

And that was it for configuring the addresses! Of course, it's a JSON file, so you can add as many addresses as you need by simply separating them by comma. Lastly, to finish up with this step, all we need to do is to install `jq` so that the script can process our JSON file. To do that simply run:

```
sudo apt update && sudo apt install jq
```

If you're on a non-debian distro you can see how you can install it on your own system by visiting jq's [website](https://stedolan.github.io/jq/download/).

3. The last step is to setup the `systemd` service so that the script will run on the background. The first thing we need to do is to edit `ncddns.service` which will contain the following:

```
[Unit]
Description=Namecheap DDNS updating service.
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
WorkingDirectory=/home/{YOUR_USER_FOLDER}/ncddns
ExecStart=/bin/bash /home/{YOUR_USER_FOLDER}/ncddns/ncddns.sh conf/ddns.json
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
```

All you need to do here is to replace `{YOUR_USER_FOLDER}` with your actual user folder name (without the brackets obviously), so that the path will lead to the script. And that was it! Simply save the file and you're ready to move on to the next task! BTW, you've probably noticed that the file contains some comments (that I've excluded from README) that explain what the the above options do. The credit for this goes to [Clownfused](https://github.com/Clownfused) as I used their [gist](https://gist.github.com/Clownfused/1144a4547fc428f7f690cd81b912ac74) to make sure that the service will always restart.

Now that the service knows where to locate the script, we need to copy the file to `/etc/systemd/system` so that systemd will be able to recognise and start our service. To do that simply run:

```
sudo cp systemd-service/ncddns.service /etc/systemd/system/
```

Lastly, we need to reload the service daemon, enable our service and then start it. To do that, simply run one by one the following 3 commands.

```
sudo systemctl daemon-reload
sudo systemctl enable ncddns.service
sudo systemctl start ncddns.service
```

Great, now if everything was successful and you didn't get any errors, if you run:

```
sudo systemctl status ncddns.service
```

You'll see something similar to the following:

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

Of course, some of the information above will be corresponding to your system such as the path as well as the domain you're updating and the IP address that is being updating to.

## Some Considerations

### Regarding the script's location

The location that I'm personally using to store the script is my home user's folder. However, that doesn't have to be like this. Feel free to save the script in whatever folder you like, just keep in mind that you'll need to update `ncddns.service` accordingly, but also you might have to edit the script itself to make it work. So, if you know what you're doing feel free to change the script however you like. I just keep in my home folder for simplicity and perhaps for not having to deal with permission issues.

### If you run into permission issues

In case you have any permission issues try doing the following. While on your user's folder first run:

```
sudo chown -R {YOUR_USER_NAME}:{YOUR_USER_NAME} ncddns
```

...by replacing of course the above with your user's name. This will change the permissions of everything inside the script's folder to your own user. Second, if the script is not executable then you'll have to change it as such. So `cd` to `ncddns` directory and run:

```
sudo chmod +x ncddns.sh
```

You should now have permissions over the script and the script will be executable.

### Regarding the log file

After you start the service and verify that it's running succesfully, if you go to the `ncddns/log` directory, you'll notice that a `ncddns.log` file appeared that shows that your addresses have been updated sucessfully to the external IP address of your network and it'll also include the timestamp. Since that the intended purpose of the script is to run forever (or realistically for as long as possible!), that log file might start to get very large in terms of disk space after some time. In order to resolve that, you can either open the script and comment out line 30 by adding a hashtag # in front of that line, or if you want to actually see the log from time to time to make sure that your addresses are actually updating as expected, you can setup a **Cronjob** to delete that file every some specified period of time. To do that you simple run:

```
sudo crontab -e
```

and then select to edit the file with your editor of choice when prompted and then add the following:

```
0 0 * * * find /home/{YOUR_USER_FOLDER}/ncddns/log/*.log -delete
```

This line will make sure that the `ncddns.log` file will be deleted every day at 00:00. An easy way to figure out how to set that up according to what you want is by visiting [crontab.guru](https://crontab.guru/) site and experiment there! Lastly, you'll need to change of course the `USER_FOLDER` above accordingly, especially if you decided to keep the script in different location other than your user's folder.

### Regarding `systemd`

If your server doesn't support `systemd` (for example you might want use it on an OpenWRT system), this doesn't necessarily mean that you can't use this script, but you'll need to make it run somehow automatically and on the background. You might be able to that by creating a `init` service that'll run by using the `init` service management daemon and then make corresponding alterations to the script (if you have to) in order to make it work.  
