#!/bin/sh
DOMAIN=$1
NEST=$(($2 + 1))
cd $(dirname $0)
# DNSのSPFレコードを取得します
SPF=$(dig txt $DOMAIN | grep v=spf1)
[ "$SPF" = "" ] && echo "[$DOMAIN] SPF does not exist!" && exit

# DNSのSPFレコードからipsetのTRUST-LISTにエントリを追加します
for SPF_TEXT in $(dig txt $DOMAIN | grep v=spf1 | sed "s/^.*\"\(.*\)\".*$/\1/"); do
  KEYWORD=$(echo $SPF_TEXT | sed "s/^[^a-z]\?\([^:=]*\).*$/\1/")
  case $KEYWORD in
  redirect)
    REDIRECT=$(echo $SPF_TEXT | cut -d "=" -f 2)
    ./dns_spf.sh $REDIRECT $NEST
    ;;
  include)
    INCLUDE_SPF=$(echo $SPF_TEXT | cut -d ":" -f 2)
    ./dns_spf.sh $INCLUDE_SPF $NEST
    ;;
  ip4)
    IPADDR=$(echo $SPF_TEXT | cut -d ":" -f 2)
    ipset -q add TRUST-LIST $IPADDR
    ;;
  a)
    if [ $(echo $SPF_TEXT | grep ":") ]; then
      INCLUDE_A=$(echo $SPF_TEXT | cut -d ":" -f 2)
      ./dns_a.sh $INCLUDE_A $NEST
    fi
    ;;
  mx)
    if [ $(echo $SPF_TEXT | grep ":") ]; then
      INCLUDE_MX=$(echo $SPF_TEXT | cut -d ":" -f 2)
      DNS_MX=$(dig mx $INCLUDE_MX | grep "^$INCLUDE_MX")
      for MX_NAME in $(echo "$DNS_MX" | sed "s/[[:blank:]]\+/ /g" | cut -d " " -f 6); do
        ./dns_a.sh $MX_NAME $NEST
      done
    fi
    ;;
  esac
done
