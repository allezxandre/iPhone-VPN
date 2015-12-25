# iPhone-compatible VPN in a docker container 
![docker-logo](https://d3oypxn00j2a10.cloudfront.net/0.18.2/img/nav/docker-logo-loggedout.png) 

*Still a work-in-progress...*

## Building
First, clone this repo with `git clone`, then `cd` to the cloned directory. You'll have to set up passwords. 

Copy `chap-secrets.example` to `chap-secrets`: 

```bash
cp chap-secrets{.example,}
```

and add usernames/passwords in the file. You'll be able to modify this file later if you want to add/remove some accounts, but please change at least the last line as the syntax is --- *intentionnaly* --- wrong (replace `<username>` and `<password>` and remove the `<`/`>`).

When this is done, just build with

```bash 
docker build -t $YOUR_USERNAME/iphone-vpn .
```

To keep your configuration even after you `rm` your container, you can use a folder on your host to keep the files. Personnaly, I use `/srv/docker/iphone-vpn`.

### `systemd` service

If you use `systemd` as your service manager, I provide a simple `vpn-docker.service` file to copy to your `/etc/systemd/system/` folder. It starts the docker container automatically, but it relies on [`systemd-docker`](https://github.com/ibuildthecloud/systemd-docker) by @ibuildthecloud. 

If you don't have systemd-docker on your system, you'll need to either build it to use it (it's very easy to do), or modify the `vpn-docker.service` file to use `docker` instead (*not recommended*).

You'll also **need to modify** the service file to change the image on which it's building (`allezxandre/iphone-vpn` by default) and the VPN's secret 

## Run 

To run in background, just use this command (after changing the appropriate options): 

```bash
docker run -d --privileged --name="vpn-server" -e SECRET="tchami" -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp -v /srv/docker/iphone-vpn:/data -v /lib/modules:/lib/modules $YOUR_USERNAME/iphone-vpn:latest
```

Now let me explain why we need all of this: 

* `--privileged` makes sure `iptables` and other root services accessing to the Kernel can do their job
* the `-e` options set up a few variables the container will use on startup
	* `SECRET` is mandatory. This is the shared secret setting for your VPN. Not a personal password, but something you'll share with your users that is complementary to the password  
* the `-p` options re-map ports, even though we don't really need that as the `Dockerfile` has an `EXPOSE` command
* Now with the volumes from the `-v` options:
	* `/srv/docker/iphone-vpn` is where the container will keep every configuration files on the local machine, so that even after a `docker rm`, the files are still there
	* `/lib/modules` is needed for the VPN server to have the true Kernel of your machine. Unfortunately, I suppose your system has to have the same Kernel as the docker container, so I don't know how this would work on non-debian/ubuntu machines.

---

## Modifications

If you need to modify a configuration file after the first launch, you can do so in the `/data` folder that is linked to your physical server. By default, with the previous command, this folder location is `/srv/docker/iphone-vpn/`.

If you want to start clean, you can delete everything in that folder, the container will repopulate it on the next launch.

## Credits

I used the following websites during the creation of this Docker Image:

* [About the `forceencaps=yes` option](http://serverfault.com/a/588079/292994)
* [Openswan tutorial](http://vitobotta.com/l2tp-ipsec-vpn-ios/index.html)
* the following GitHub repos:
	* [zealic's](https://github.com/zealic/docker-library-ipsec)
	* [rfadams'](https://github.com/rfadams/docker-l2tpipsec-vpn)
* [Raymii's tutorial for Ubuntu](https://raymii.org/s/tutorials/IPSEC_L2TP_vpn_with_Ubuntu_14.04.html)
