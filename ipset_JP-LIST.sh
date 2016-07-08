#!/bin/sh
cd $(dirname $0)
# GeoLite Countryデータベースを元に日本国内IPアドレスでJP-LISTを作成します
IPREGEX="\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}"
ipset flush JP-LIST
for IPADDR in $(cat /usr/local/share/GeoIP/GeoIPCountryWhois.csv \
              | sed -e '/,"JP",/!d' \
              | sed -e "s/^\"\($IPREGEX\)\",\"\($IPREGEX\)\",.*$/\1-\3/") ; do
  ipset add JP-LIST $IPADDR
done
ipset save JP-LIST > ipset/JP-LIST

# JP-LISTを作成したので、ファイアウォールに国外をDROPするルールを追加します
FWDCMD="firewall-cmd --direct"
RULE="ipv4 filter CHK-JP 3 -j DROP"
[ "$($FWDCMD --query-rule $RULE)" = "no" ] && $FWDCMD --add-rule $RULE
