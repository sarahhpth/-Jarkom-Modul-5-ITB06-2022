# Jarkom-Modul-5-ITB06-2022

Repository ini dibuat sebagai laporan resmi untuk pengerjaan [Soal Shift Modul 5](https://docs.google.com/document/d/1b-tRRx2BLu1RxCgXxnoI2lYJbG9E0C08adRppePfHxk/edit) dari praktikum Mata Kuliah Komunikasi Data dan Jaringan Komputer.

**Anggota Kelompok ITB06**

- Sarah Hanifah Pontoh 5027201006
- Sharira Saniane 5027201016
- Naufal Dhiya Ulhaq 5027201029

## Subnetting Menggunakan VLSM

Pembagian subnet pada jaringan sebagai berikut:
![Image 1](image/subnet.jpg)

Jumlan keseluruhan host adalah 1231 sehingga netmask keseluruhan adalah /21. Berikut adalah skema pembagian dalam tree.
![Image 2](image/vlsm_tree.png)

Pembagian IP setiap subnet:
![Image 3](image/vlsm_table.jpg)

## Konfigurasi Node dan Routing

### Strix

```
auto eth0
 iface eth0 inet dhcp

auto eth1
iface eth1 inet static
	address 192.217.1.1
	netmask 255.255.255.0

auto eth2
iface eth2 inet static
	address 192.217.2.1
	netmask 255.255.255.0

auto eth3
iface eth3 inet static
	address 192.217.3.1
	netmask 255.255.255.0
```

Sebagai router yang langsung terhubung dengan NAT, tambahkan route berikut untuk menghubungkan setiap subnet.

```route add -net 192.217.7.0 netmask 255.255.255.128 gw 192.217.7.146 #forger
route add -net 192.217.0.0 netmask 255.255.252.0 gw 192.217.7.146 #desmond
route add -net 192.217.7.128 netmask 255.255.255.248 gw 192.217.7.146 #eden & WISE

route add -net 192.217.4.0 netmask 255.255.254.0 gw 192.217.7.150 #blackbell
route add -net 192.217.6.0 netmask 255.255.255.0 gw 192.217.7.150 #briar
route add -net 192.217.7.136 netmask 255.255.255.248 gw 192.217.7.150 #garden & SSS
```

Set up sebagai DHCP relay

```
apt-get update
apt-get install isc-dhcp-relay -y
echo '
SERVERS="192.217.7.131"
INTERFACES="eth2 eth1"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
```

### Westalis

```
auto eth0
iface eth0 inet static
	address 192.217.7.146
	netmask 255.255.255.252
auto eth1
iface eth1 inet static
	address 192.217.0.1
	netmask 255.255.252.0
auto eth2
iface eth2 inet static
	address 192.217.7.1
	netmask 255.255.255.128
auto eth3
iface eth3 inet static
	address 192.217.7.129
	netmask 255.255.255.248

```

Tambahkan juga route berikut untuk menghubungkan dengan router Strix
`route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.217.7.145`

Set up sebagai DHCP relay

```apt update
apt install isc-dhcp-relay -y
echo '
SERVERS="192.217.7.131"
INTERFACES="eth2 eth3 eth0 eth1"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
```

### Ostania

```
auto eth0
iface eth0 inet static
	address 192.217.7.150
	netmask 255.255.255.252
auto eth1
iface eth1 inet static
	address 192.217.7.137
	netmask 255.255.255.248
auto eth2
iface eth2 inet static
	address 192.217.4.1
	netmask 255.255.254.0
auto eth3
iface eth3 inet static
	address 192.217.6.1
	netmask 255.255.255.0
```

Tambahkan juga route berikut untuk menghubungkan dengan router Strix
`route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.217.7.149`

Set up sebagai DHCP relay

```apt update
apt install isc-dhcp-relay -y
echo '
SERVERS="192.217.7.131"
INTERFACES="eth2 eth3 eth1 eth0"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
```

### CLients (Forger, Desmond, Blackbell, Briar)

```
auto eth0
iface eth0 inet dhcp
```

### Eden (DNS Server)

```auto eth0
iface eth0 inet static
	address 192.217.7.130
	netmask 255.255.255.248
        gateway 192.217.7.129
```

Set sebagai DNS server

```apt update
apt install bind9 -y
```

Pada file `/etc/bind/named.conf.options` tambahkan:

```options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
        };
        allow-query { any; };
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
```

```
service bind9 restart
```

### WISE (DHCP Server)

```auto eth0
iface eth0 inet static
	address 192.217.7.131
	netmask 255.255.255.248
        gateway 192.217.7.129
```

Set sebagai DHCP server

```apt update
apt install isc-dhcp-server -y
```

Pada `/etc/default/isc-dhcp-server` tambahkan:

```INTERFACES="eth0"

```

Pada `/etc/dhcp/dhcpd.conf`tambahkan setiap subnet pada jaringan:

```ddns-update-style none;
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
```

```
service isc-dhcp-server restart
```

### Garden (Web Server)

```auto eth0
iface eth0 inet static
	address 192.217.7.138
	netmask 255.255.255.248
        gateway 192.217.7.137
```

Set sebagai web server

```apt update
apt install apache2 -y
service apache2 start
echo "$HOSTNAME" > /var/www/html/index.html
```

### SSS

```auto eth0
iface eth0 inet static
	address 192.217.7.139
	netmask 255.255.255.248
        gateway 192.217.7.137
```

Set sebagai web server

```apt update
apt install apache2 -y
service apache2 start
echo "$HOSTNAME" > /var/www/html/index.html
```
