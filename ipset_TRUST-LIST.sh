#!/bin/sh
SHDIR=$(cd $(dirname $0); pwd)
LIST=TRUST-LIST
cd $SHDIR/trust

# TRUST-LISTを再作成する前にIPアドレスチェックを無効にします
$SHDIR/IpCheckDisable.sh
ipset flush $LIST

# DNSのSPFレコードからTRUST-LISTを追加します
# SPFレコードでredirectやincludeが指定されることがあるため子スクリプトで処理します
if [ -s spf_list ]; then
  for SPF in $(cat spf_list | sed -e "/^#/d" -e "s/^\([^[:blank:]]*\).*/\1/"); do
    ./dns_spf.sh $SPF 1
  done
fi
# ホスト名からTRUST-LISTを追加します
# SPFレコードでaやmxが指定されることがあるため子スクリプトで処理します
if [ -s host_list ]; then
  for HOST in $(cat host_list | sed -e "/^#/d" -e "s/^\([^[:blank:]]*\).*/\1/"); do
    ./dns_a.sh $HOST 1
  done
fi
# IPアドレスリストからTRUST-LISTを追加します"
if [ -s ip_list ]; then
  for IPADDR in $(cat ip_list | sed -e "/^#/d" -e "s/^\([^[:blank:]]*\).*/\1/"); do
    if [ "$(ipset test $LIST $IPADDR 2>&1 | grep 'NOT in set')" = "" ] ; then
      echo "$IPADDR は追加済です"
    else
      ipset add $LIST $IPADDR
    fi
  done
fi
ipset save $LIST > $SHDIR/ipset/$LIST

# TRUST-LISTを再作成したのでIPアドレスチェックを有効にします
$SHDIR/IpCheckEnable.sh
