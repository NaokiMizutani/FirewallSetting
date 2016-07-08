#!/bin/sh
# ipset用国別IPアドレスデータベース(GeoIP)のディレクトリを作成します
GEOIPDIR=/usr/local/share/GeoIP
[ ! -e $GEOIPDIR ] && mkdir -p $GEOIPDIR

# ipset用国別IPアドレスデータベース(GeoIP)が存在しない場合は作成します
[ ! -e $GEOIPDIR/GeoIPCountryWhois.csv ] && /usr/local/sbin/update-geoip-database

# ipsetのエントリ作成を行います
# 悪質な接続元,信頼できる海外接続元,日本国内
cd $(dirname $0)
for LIST in BLACK-LIST TRUST-LIST JP-LIST; do
  [ ! -e ./ipset/$LIST ] && ./ipset_$LIST.sh
done

# 各LISTを作成したので、firewall起動後処理を再実行します
./ExecStartPost.sh
