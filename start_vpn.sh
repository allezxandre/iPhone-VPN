#/bin/bash
set -e

# Redirect all traffic
echo 1 > /proc/sys/net/ipv4/ip_forward
for each in /proc/sys/net/ipv4/conf/*
do
    echo 0 > $each/accept_redirects
    echo 0 > $each/send_redirects
done


# Get the IP Address of the container
IP_ADDRESS=$(ip addr show | grep inet | grep eth0 | cut -d/ -f1 | awk '{ print $2}' | head -n1)
echo "The IP Address of this server is $IP_ADDRESS"

# Set up IPTables
echo "Setting up IP Tables..."
iptables -A INPUT -p udp -m udp --dport 500 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 4500 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 1701 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.1.2.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -s 10.1.2.0/24 -j ACCEPT
echo "Done"

# Set up permanent storage
chmod 775 /data

chown -R root:vpn /data 

# Add default configuration

# IPSec
  # ipsec.conf
if [ ! -d /data/ipsec.conf ]; then
  mv /etc/ipsec.conf /data/ipsec.conf
  # Update IP Address 
  sed 's/SERVER_IP_REPLACE/'$IP_ADDRESS'/' /data/ipsec.conf 
  echo "--- File ipsec.conf:"
  cat /data/ipsec.conf 
  echo '--------------------'
fi
rm /etc/ipsec.conf
ln -sf /data/ipsec.conf /etc/ipsec.conf
  # ipsec.secrets
if [ ! -d /data/ipsec.secrets ]; then
  mv /etc/ipsec.secrets /data/ipsec.secrets
  # Update IP Address 
  sed 's/SERVER_IP_REPLACE/'$IP_ADDRESS'/' /data/ipsec.secrets 
  echo "--- File ipsec.secrets:"
  cat /data/ipsec.secrets 
  echo '--------------------'
  # Update secret
  if [ -z $SECRET ]; then
    SECRET="docker"
    echo "WARNING! You haven't set a VPN secret"
    echo "Default secret: 'docker'"
  fi
  sed 's/SECRET_REPLACE/'$SECRET'/' /data/ipsec.secrets
fi
rm /etc/ipsec.secrets
ln -sf /data/ipsec.secrets /etc/ipsec.secrets

# Start IPSec 
service ipsec restart
service xl2tpd restart 
sleep 3 
ipsec verify 

# Keep the container running
# (from https://github.com/rfadams/docker-l2tpipsec-vpn/blob/master/bin/run)
while [ true ]; do
      echo "ipsec working"
      sleep 60
done
