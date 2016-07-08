#!/bin/sh
SHDIR=$(cd $(dirname $0); pwd)
# TRUST-LIST(信頼できる海外IPリスト)が存在する場合、日本国内IPのチェックを有効にします
# TRUST-LISTの存在チェックはスクリプト内部で行っています
$SHDIR/IpCheckEnable.sh

# JP-LIST(日本国内IPリスト)が存在する場合、リスト外IPをDROPするルールをfirewalldに追加します
if [ -e $SHDIR/ipset/JP-LIST ] ; then
  FWDCMD="firewall-cmd --direct"
  RULE="ipv4 filter CHK-JP 3 -j DROP"
  [ "$($FWDCMD --query-rule $RULE)" = "no" ] && $FWDCMD --add-rule $RULE
fi
