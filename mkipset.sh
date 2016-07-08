#!/bin/sh
yum -y install ipset
yum -y install bind-utils
yum -y install wget
yum -y install unzip

mkdir /usr/local/sbin/firewall
mkdir /usr/local/sbin/firewall/black
mkdir /usr/local/sbin/firewall/trust
mkdir /etc/systemd/system/firewalld.service.d
mkdir -p /usr/local/share/GeoIP

cp ExecStartPre.sh /usr/local/sbin/firewall/
chmod +x /usr/local/sbin/firewall/ExecStartPre.sh

cp custom1.conf /etc/systemd/system/firewalld.service.d/custom.conf

systemctl daemon-reload
systemctl restart firewalld.service
systemctl status firewalld.service

ipset list

cp environment /usr/local/sbin/firewall/
source /usr/local/sbin/firewall/environment

FwCmd --zone=dmz --change-interface=$EXTIF

FwAddChain LOG-DROP
FwAddRule LOG-DROP 1 -m limit --limit $LOGLIMIT --limit-burst $LOGBURST -j LOG --log-prefix 'FIREWALL_DROP'
FwAddRule LOG-DROP 2 -j DROP

FwAddChain CHK-JP
FwAddRule CHK-JP 1 -s $ALLLAN -j RETURN
FwAddRule CHK-JP 2 -i $EXTIF -m set --match-set JP-LIST src -j RETURN

FwAddChain CHK-IP
FwAddRule CHK-IP 1 -i $EXTIF -m set --match-set TRUST-LIST src -j RETURN
FwAddRule INPUT 1 -i $EXTIF -m set --match-set BLACK-LIST src -j DROP
FwAddRule INPUT 2 -i $EXTIF -m set --match-set BLOCK-LIST src -j DROP
FwAddRule INPUT 3 -i $EXTIF -p tcp --dport 80 -j CHK-JP

iptables -nvL

cp IpCheckEnable.sh /usr/local/sbin/firewall/
cp IpCheckDisable.sh /usr/local/sbin/firewall/
chmod +x /usr/local/sbin/firewall/IpCheckEnable.sh
chmod +x /usr/local/sbin/firewall/IpCheckDisable.sh

cp ExecStartPost.sh /usr/local/sbin/firewall/
chmod +x /usr/local/sbin/firewall/ExecStartPost.sh

cp custom2.conf /etc/systemd/system/firewalld.service.d/custom.conf

systemctl daemon-reload
systemctl restart firewalld.service
systemctl status firewalld.service

cp ipset_JP-LIST.sh /usr/local/sbin/firewall/
chmod +x /usr/local/sbin/firewall/ipset_JP-LIST.sh

cp update-geoip-database /usr/local/sbin/
chmod +x /usr/local/sbin/update-geoip-database

/usr/local/sbin/update-geoip-database $(date -d 2016-06-30 +"%F")

cp cron-update-geoip-database /etc/cron.d/update-geoip-database

cp ip_list /usr/local/sbin/firewall/black
cp ip_list /usr/local/sbin/firewall/trust

cp ipset_BLACK-LIST.sh /usr/local/sbin/firewall/
chmod +x /usr/local/sbin/firewall/ipset_BLACK-LIST.sh

/usr/local/sbin/firewall/ipset_BLACK-LIST.sh

cp spf_list /usr/local/sbin/firewall/trust/
cp host_list /usr/local/sbin/firewall/trust/

cp ipset_TRUST-LIST.sh /usr/local/sbin/firewall/
cp dns_spf.sh /usr/local/sbin/firewall/trust/
cp dns_a.sh /usr/local/sbin/firewall/trust/

chmod +x /usr/local/sbin/firewall/ipset_TRUST-LIST.sh
chmod +x /usr/local/sbin/firewall/trust/dns_spf.sh
chmod +x /usr/local/sbin/firewall/trust/dns_a.sh

/usr/local/sbin/firewall/ipset_TRUST-LIST.sh

cp update_TRUST-LIST /etc/cron.daily/
chmod +x /etc/cron.daily/update_TRUST-LIST

cp rc.sh /usr/local/sbin/firewall/
chmod +x /usr/local/sbin/firewall/rc.sh

# vi /etc/rc.d/rc.local
# RCSH=/usr/local/sbin/firewall/rc.sh ; [-e $RCSH ] && $RCSH

# chmod +x /etc/rc.d/rc.local

