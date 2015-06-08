FROM debian:7
# This docker container is based on this tutorial:
# http://vitobotta.com/l2tp-ipsec-vpn-ios/index.html
MAINTAINER Alexandre Jouandin <alexandre@jouand.in>

# Install VPN software
RUN apt-get update && apt-get upgrade -qy
RUN apt-get install -yq iptables lsof openswan=1:2.6.37-3 xl2tpd ppp

# Copy default configuration
ADD ipsec.conf /etc/ipsec.conf
ADD ipsec.secrets /etc/ipsec.secrets
ADD xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
ADD options.xl2tpd /etc/ppp/options.xl2tpd
ADD chap-secrets /etc/ppp/chap-secrets

# Install Supervisord
RUN apt-get -y install supervisor && \
  mkdir -p /var/log/supervisor && \
  mkdir -p /etc/supervisor/conf.d

# Copy supervisor files
ADD supervisor/supervisor.conf /etc/supervisor.conf
ADD supervisor/conf.d/ /etc/supervisor/conf.d/

# Prepare start-up script
ADD start_vpn.sh /start_vpn
RUN chmod 755 /start_vpn

# Links to the outside world
EXPOSE 500/udp 4500/udp 1701/udp
VOLUME ["/data"]

# Start container
CMD /start_vpn
