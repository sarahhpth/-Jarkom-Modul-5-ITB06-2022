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

## Konfigurasi Setiap Node pada Jaringan

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

### CLients (Forger, Desmond, Blackbell, Briar)

```
auto eth0
iface eth0 inet dhcp
```

### Eden

```auto eth0
iface eth0 inet static
	address 192.217.7.130
	netmask 255.255.255.248
        gateway 192.217.7.129
```
