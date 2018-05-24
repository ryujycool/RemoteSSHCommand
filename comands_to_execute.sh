
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth3 -j MASQUERADE
iptables -A FORWARD -i eth3 -o eth4 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth4 -o eth3 -j ACCEPT
