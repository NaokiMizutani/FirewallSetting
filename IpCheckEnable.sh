#!/bin/sh
if [ -e $(dirname $0)/ipset/TRUST-LIST ] ; then
  RULE="ipv4 filter CHK-IP 3 -g CHK-JP"
  FWDCMD="firewall-cmd --direct"
  if [ "$($FWDCMD --query-rule $RULE)" = "no" ] ; then
    $FWDCMD --add-rule $RULE
    echo "--- IP Address Check from offshore enabled"
  fi
fi
