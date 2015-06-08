# iPhone-compatible VPN in a docker container 
![docker-logo](https://d3oypxn00j2a10.cloudfront.net/0.18.2/img/nav/docker-logo-loggedout.png) 

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
docker run --privileged --name="vpn-server" -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp -v /srv/docker/iphone-vpn:/data allezxandre/iphone-vpn:latest
```