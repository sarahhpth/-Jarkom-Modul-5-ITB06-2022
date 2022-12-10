#!/bin/bash

strix(){
apt-get update
IPETH0="$(ip -br a | grep eth0 | awk '{print $NF}' | cut -d'/' -f1)"
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source "$IPETH0" -s 192.217.0.0/21

route add -net 192.217.7.0 netmask 255.255.255.128 gw 192.217.7.146 #forger
route add -net 192.217.0.0 netmask 255.255.252.0 gw 192.217.7.146 #desmond
route add -net 192.217.7.128 netmask 255.255.255.248 gw 192.217.7.146 #eden & WISE

route add -net 192.217.4.0 netmask 255.255.254.0 gw 192.217.7.150 #blackbell
route add -net 192.217.6.0 netmask 255.255.255.0 gw 192.217.7.150 #briar
route add -net 192.217.7.136 netmask 255.255.255.248 gw 192.217.7.150 #garden & SSS

apt-get install isc-dhcp-relay -y

echo '
SERVERS="192.217.7.131"
INTERFACES="eth2 eth1"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
# No.2
iptables -A FORWARD -d 192.217.7.131 -i eth0 -p tcp --dport 80 -j DROP
iptables -A FORWARD -d 192.217.7.131 -i eth0 -p udp --dport 80 -j DROP

}
westalis(){
route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.217.7.145
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install isc-dhcp-relay -y
echo '
SERVERS="192.217.7.131"
INTERFACES="eth2 eth3 eth0 eth1"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
}
ostania(){
route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.217.7.149
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install isc-dhcp-relay -y
echo '
SERVERS="192.217.7.131"
INTERFACES="eth2 eth3 eth1 eth0"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
# No.5
iptables -A PREROUTING -t nat -p tcp -d 192.217.7.130 -m statistic --mode nth --every 2 --packet 0 -j DNAT --to-destination 192.217.7.139:80
iptables -A PREROUTING -t nat -p tcp -d 192.217.7.130 -j DNAT --to-destination 192.217.7.138:80

iptables -A PREROUTING -t nat -p tcp -d 192.217.7.130 -m statistic --mode nth --every 2 --packet 0 -j DNAT --to-destination 192.217.7.138:443
iptables -A PREROUTING -t nat -p tcp -d 192.217.7.130 -j DNAT --to-destination 192.217.7.139:443

}
WISE(){
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install isc-dhcp-server -y
echo '
INTERFACES="eth0"
' > /etc/default/isc-dhcp-server

echo '
ddns-update-style none;
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;
default-lease-time 600;
max-lease-time 7200;
log-facility local7;
subnet 192.217.0.0 netmask 255.255.252.0 {
    range 192.217.0.2 192.217.3.254;
    option routers 192.217.0.1;
    option broadcast-address 192.217.3.255;
    option domain-name-servers 192.217.7.130;
    default-lease-time 360;
    max-lease-time 7200;
}
subnet 192.217.7.0 netmask 255.255.255.128 {
    range 192.217.7.2 192.217.7.126;
    option routers 192.217.7.1;
    option broadcast-address 192.217.7.127;
    option domain-name-servers 192.217.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}
subnet 192.217.4.0 netmask 255.255.254.0 {
    range 192.217.4.2 192.217.5.254;
    option routers 192.217.4.1;
    option broadcast-address 192.217.5.255;
    option domain-name-servers 192.217.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}
subnet 192.217.6.0 netmask 255.255.255.0 {
    range 192.217.6.2 192.217.6.254;
    option routers 192.217.6.1;
    option broadcast-address 192.217.6.255;
    option domain-name-servers 192.217.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}
subnet 192.217.7.128 netmask 255.255.255.248 {}
subnet 192.217.7.144 netmask 255.255.255.252 {}
subnet 192.217.7.148 netmask 255.255.255.252 {}
subnet 192.217.7.136 netmask 255.255.255.248 {}
' > /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart

#No. 3 Reject bila terdapat PING ICMP Lebih dari 2
iptables -A INPUT -p icmp -m connlimit --connlimit-above 2 --connlimit-mask 0 -j DROP
}

eden(){
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install bind9 -y
echo '
options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
        };
        allow-query { any; };
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};

' > /etc/bind/named.conf.options
service bind9 restart
#No. 3 Reject bila terdapat PING ICMP Lebih dari 2
iptables -A INPUT -p icmp -m connlimit --connlimit-above 2 --connlimit-mask 0 -j DROP
#No. 4 Akses menuju web server (garden dan SSS)
#forger
iptables -A INPUT -s 192.217.7.0/25 -m time --weekdays Sat,Sun -j REJECT
iptables -A INPUT -s 192.217.7.0/25 -m time --timestart 00:00 --timestop 06:59 --weekdays Mon,Tue,Wed,Thu,Fri -j REJECT
iptables -A INPUT -s 192.217.7.0/25 -m time --timestart 16:01 --timestop 23:59 --weekdays Mon,Tue,Wed,Thu,Fri -j REJECT
#desmond
iptables -A INPUT -s 192.217.0.0/25 -m time --weekdays Sat,Sun -j REJECT
iptables -A INPUT -s 192.217.0.0/25 -m time --timestart 00:00 --timestop 06:59 --weekdays Mon,Tue,Wed,Thu,Fri -j REJECT
iptables -A INPUT -s 192.217.0.0/25 -m time --timestart 16:01 --timestop 23:59 --weekdays Mon,Tue,Wed,Thu,Fri -j REJECT


}

garden(){
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install apache2 -y
service apache2 start
echo "$HOSTNAME" > /var/www/html/index.html
apt install netcat -y
}

SSS(){
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install apache2 -y
service apache2 start
echo "$HOSTNAME" > /var/www/html/index.html
apt install netcat -y
}

forger(){
apt update
}
desmond(){
apt update
}
blackbell(){
apt update
apt install netcat -y
}
briar(){
apt update
apt install netcat -y
}

if [ $HOSTNAME == "strix" ]
then
    strix
elif [ $HOSTNAME == "westalis" ]
then
    westalis
elif [ $HOSTNAME == "ostania" ]
then
    ostania
elif [ $HOSTNAME == "WISE" ]
then
    WISE
elif [ $HOSTNAME == "eden" ]
then
    eden
elif [ $HOSTNAME == "garden" ]
then
    garden
elif [ $HOSTNAME == "SSS" ]
then
    SSS
elif [ $HOSTNAME == "forger" ]
then
    forger
elif [ $HOSTNAME == "desmond" ]
then
    desmond
elif [ $HOSTNAME == "blackbell" ]
then
    blackbell
elif [ $HOSTNAME == "briar" ]
then
    briar
fi