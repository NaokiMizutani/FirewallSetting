#!/bin/sh
RULE="ipv4 filter CHK-IP 3 -g CHK-JP"
FWDCMD="firewall-cmd --direct"
if [ "$($FWDCMD --query-rule $RULE)" = "yes" ] ; then
  $FWDCMD --remove-rule $RULE
  echo "--- IP Address Check from offshore disabled"
fi
