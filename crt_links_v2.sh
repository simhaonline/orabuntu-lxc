sudo rm *
ln -s /etc/dhcp .
ln -s /etc/dhcp/dhcpd.conf .
ln -s /etc/dhcp/dhclient.conf .
ln -s /var/lib/bind .
ln -s /var/lib/bind/fwd.vmem.org .
ln -s /var/lib/bind/rev.vmem.org .
ln -s /var/lib/bind/fwd.mccc.org .
ln -s /var/lib/bind/rev.mccc.org .
ln -s /etc/bind bind_directory
ln -s /etc/bind/named.conf.options .
ln -s /etc/bind/named.conf.local .
ln -s /etc/bind/rndc.key .
ln -s /var/lib/lxc .
ln -s /etc/network .
ln -s /etc/network/interfaces .
ln -s /etc/network/if-up.d/openvswitch .
ln -s /etc/network/if-down.d/openvswitch openvswitch_directory
ln -s /etc/network/if-up.d/openvswitch-net .
ln -s /etc/NetworkManager/dnsmasq.d/local .
ln -s /var/lib/bind var_lib_bind_directory
ln -s /etc/default/bind9 .
ln -s /etc/default/isc-dhcp-server .
sudo chown root:root openvswitch_directory
