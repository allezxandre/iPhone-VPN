# iPhone-compatible VPN in a docker container 
![docker-logo](https://d3oypxn00j2a10.cloudfront.net/0.18.2/img/nav/docker-logo-loggedout.png) 

*Still a work-in-progress...*

## Building
First, clone this repo with `git clone`, then `cd` to the cloned directory. You'll have to set up passwords. 

Copy `chap-secrets.example` to `chap-secrets`: 

```bash
cp chap-secrets{.example,}
```

and add usernames/passwords in the file. You'll be able to modify this file later if you want to add/remove some accounts, but please change at least the last line as the syntax is --- *intentionnaly* --- wrong

When this is done, just build with

```bash 
docker build -t $YOUR_USERNAME/iphone-vpn
```

To keep your configuration even after you `rm` your container, you can use a folder on your host to keep the files. Personnaly, I use `/srv/docker/iphone-vpn`.

## Run 

To run, just use this command: 

```bash
docker run --privileged --name="vpn-server" -e IP_ADDRESS="10.0.1.4" -e SECRET="tchami" -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp -v /srv/docker/iphone-vpn:/data -v /lib/modules:/lib/modules allezxandre/iphone-vpn:latest
```

Now let me explain why we need all of this: 

* `--privileged` makes sure `iptables` and other root services can do their job
* the `-e` options set up a few variables the container will use on startup
	* `IP_ADDRESS` is optional, but this is the IP Address your machine has when it listens for connections. On a dedicated server, this is the public IP, but on a NATed network (like your home network), this is the machine local IP
	* `SECRET` is mandatory. This is the shared secret setting for your VPN. Not a personal password, but something you'll share with your users that is complementary to the password  
* the `-p` options re-map ports, even though we don't really need that as the `Dockerfile` has an `EXPOSE` command
* Now with the volumes from the `-v` options:
	* `/srv/docker/iphone-vpn` is where the container will keep every configuration files on the local machine, so that even after a `docker rm`, the files are still there
	* `/lib/modules` is needed for the VPN server to have the true Kernel of your machine. Unfortunately, I suppose your system has to have the same Kernel as the docker container, so I don't know how this would work on non-debian/ubuntu machines.

---