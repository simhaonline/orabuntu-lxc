#!/bin/bash

#    Copyright 2015-2018 Gilbert Standen
#    This file is part of Orabuntu-LXC.

#    Orabuntu-LXC is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    Orabuntu-LXC is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Orabuntu-LXC.  If not, see <http://www.gnu.org/licenses/>.

#    v2.4 	GLS 20151224
#    v2.8 	GLS 20151231
#    v3.0 	GLS 20160710 Updates for Ubuntu 16.04
#    v4.0 	GLS 20161025 DNS DHCP services moved into an LXC container
#    v5.0 	GLS 20170909 Orabuntu-LXC MultiHost
#    v5.33-beta	GLS 20180106 Orabuntu-LXC EE MultiHost Docker AWS S3

#    Note that this software builds a containerized DNS DHCP solution (bind9 / isc-dhcp-server).
#    The nameserver should NOT be the name of an EXISTING nameserver but an arbitrary name because this software is CREATING a new LXC-containerized nameserver.
#    The domain names can be arbitrary fictional names or they can be a domain that you actually own and operate.
#    There are two domains and two networks because the "seed" LXC containers are on a separate network from the production LXC containers.
#    If the domain is an actual domain, you will need to change the subnet though (a feature this software does not yet support - it's on the roadmap) to match your subnet manually.

clear

MultiHostVar5=$1
MultiHostVar6=$2
NameServer=$3

function CheckSystemdResolvedInstalled {
	sudo netstat -ulnp | grep 53 | sed 's/  */ /g' | rev | cut -f1 -d'/' | rev | sort -u | grep systemd- | wc -l
}
SystemdResolvedInstalled=$(CheckSystemdResolvedInstalled)

function CheckLxcNetInstalled {
	systemctl | grep -c lxc-net
}
LxcNetInstalled=$(CheckLxcNetInstalled)

echo ''
echo "=============================================="
echo "Copy nameserver $NameServer...                "
echo "=============================================="
echo ''

function CheckScpProgress {
	ps -ef | grep sshpass | grep scp | grep -v grep | wc -l
}

# nohup sshpass -p ubuntu scp -o CheckHostIP=no -o StrictHostKeyChecking=no -p ubuntu@$MultiHostVar5:~/Manage-Orabuntu/$NameServer.tar.gz ~/Manage-Orabuntu/. &
sshpass -p ubuntu ssh -tt -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$MultiHostVar5 "sudo -S <<< "ubuntu" echo '(Do NOT type a password...backup will start in a moment)'; sudo -S <<< "ubuntu" tar -P -czf ~/Manage-Orabuntu/$NameServer.tar.gz -T ~/Downloads/orabuntu-lxc-master/uekulele/archives/nameserver.lst --checkpoint=10000 --totals"
exit
sleep 5
rsync -hP --rsh="sshpass -p ubuntu ssh -l ubuntu" $MultiHostVar5:~/Manage-Orabuntu/$NameServer.tar.gz ~/Manage-Orabuntu/.

# echo ''
# ScpProgress=$(CheckScpProgress)
# while [ $ScpProgress -gt 0 ]
# do
# 	sleep 2
# 	ls -lh ~/Manage-Orabuntu/olive.tar.gz
# 	ScpProgress=$(CheckScpProgress)
# done

echo ''
echo "=============================================="
echo "Destroy nameserver $NameServer...             "
echo "=============================================="
echo ''
sudo lxc-stop    -n $NameServer
sudo lxc-destroy -n $NameServer
echo ''
echo "=============================================="
echo "Unpack tar file...                            "
echo "=============================================="
echo ''
sudo tar -P -xzf ~/Manage-Orabuntu/$NameServer.tar.gz --checkpoint=10000 --totals
echo ''
echo "=============================================="
echo "Done: Copy nameserver container $NameServer.  "
echo "=============================================="
echo ''
echo "=============================================="
echo "LXC containers for Oracle Status...           "
echo "=============================================="
echo ''

sudo lxc-ls -f

echo ''
echo "=============================================="

if [ $SystemdResolvedInstalled -ge 1 ]
then
	sudo service systemd-resolved restart
fi

if [ $LxcNetInstalled -ge 1 ]
then
	sudo service lxc-net restart > /dev/null 2>&1
fi
