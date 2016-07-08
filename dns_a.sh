#!/bin/sh
HOST=$1
NEST=$2
# DNSレコードを取得します
DNS=$(dig a $HOST | grep "^$1")
if [ "$DNS" = "" ] ; then
  [ $NEST -eq 1 ] && echo "[$HOST] DNS does not exist!"
  exit
fi
# DNSレコードからipsetのTRUST-LISTにエントリを追加します
IFS_BACKUP=$IFS
IFS=$'\n'
for LINE in $(echo "$DNS" | sed "s/[[:blank:]]\+/ /g"); do
  TYPE=$(echo $LINE | cut -d " " -f 4)
  ADDR=$(echo $LINE | cut -d " " -f 5)
  case $TYPE in
  A)
    ipset -q add TRUST-LIST $ADDR
    ;;
  CNAME)
    ./dns_a.sh $ADDR $((NEST + 1))
    ;;
  esac
done
IFS=$IFS_BACKUP
