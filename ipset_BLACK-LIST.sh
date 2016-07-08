#!/bin/sh
SHDIR=$(cd $(dirname $0); pwd)
LIST=BLACK-LIST

# IPアドレスリストからBLACK-LISTに拒否IPを追加します
ipset flush $LIST
cd $SHDIR/black
if [ -s ip_list ]; then
  for IPADDR in $(cat ip_list | sed -e "/^#/d" -e "s/^\([^[:blank:]]*\).*/\1/"); do
    ipset add $LIST $IPADDR
  done
fi
ipset save $LIST > $SHDIR/ipset/$LIST
