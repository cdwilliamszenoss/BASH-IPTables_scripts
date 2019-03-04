modprobe  xt_recent ip_list_tot=10000 ip_pkt_list_tot=5

iptables  -X
iptables  -F
iptables  -P INPUT DROP
iptables  -P FORWARD DROP
iptables  -P OUTPUT ACCEPT
iptables  -N shlimit

iptables  -t nat -P PREROUTING ACCEPT
iptables  -t nat -P POSTROUTING ACCEPT
iptables  -t nat -P OUTPUT ACCEPT

iptables  -t nat -A PREROUTING -i vlan2 -p tcp --dport 5900 -j DNAT --to-destination 192.168.1.49:5900
iptables  -t nat -A PREROUTING -d 192.168.1.0/255.255.255.0 -i vlan2 -j DROP


iptables  -t nat -A POSTROUTING -o vlan2 -j MASQUERADE
iptables  -t nat -A POSTROUTING -s 192.168.1.0/255.255.255.0 -d 192.168.1.0/255.255.255.0 -o br0 -j SNAT --to-source 192.168.1.1

iptables  -t mangle -P PREROUTING ACCEPT
iptables  -t mangle -P INPUT ACCEPT
iptables  -t mangle -P FORWARD ACCEPT
iptables  -t mangle -P OUTPUT ACCEPT
iptables  -t mangle -P POSTROUTING ACCEPT
iptables  -t mangle -A PREROUTING -i vlan2 -j DSCP --set-dscp 0x00
iptables  -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu


iptables  -A INPUT -m state --state INVALID -j DROP
iptables  -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables  -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -j shlimit
iptables  -A INPUT -p tcp -m tcp -m multiport --dports 443,80,5900 -m state --state NEW -j ACCEPT




iptables  -A FORWARD -m state --state INVALID -j DROP
iptables  -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables  -A FORWARD -i vlan2 -p tcp --dport 5900 -d 192.168.1.49 -j ACCEPT



iptables  -A shlimit -m recent --set --name shlimit --rsource
iptables  -A shlimit -m recent --rcheck --seconds 5 --hitcount 5 --name shlimit --rsource -j DROP
