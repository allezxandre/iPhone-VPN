# Set up redirections
echo 1 > /proc/sys/net/ipv4/ip_forward
for each in /proc/sys/net/ipv4/conf/*
  do
    echo 0 > $each/accept_redirects
    echo 0 > $each/send_redirects
done

# Set up IPTables
echo "Setting up IP Tables..."
iptables -A INPUT -p udp -m udp --dport 500 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 4500 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 1701 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.1.2.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -s 10.1.2.0/24 -j ACCEPT
echo "Done"