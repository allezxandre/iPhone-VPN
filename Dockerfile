FROM debian:8
# This docker container is based on this tutorial:
# http://vitobotta.com/l2tp-ipsec-vpn-ios/index.html
MAINTAINER Alexandre Jouandin <alexandre@jouand.in>

RUN apt-get update && apt-get upgrade -y \
                   && apt-get install -y iptables \
                   && apt-get install -y openswan=1:2.6.37-3

ADD ipsec.conf /etc/ipsec.conf

# Prepare start-up script
ADD start_vpn.sh /start_vpn
RUN chmod 755 /start_vpn

# Links to the outside world
EXPOSE 500/udp 4500/udp 1701/udp
VOLUME ["/data"]

# Start container
CMD ["/start_vpn"]