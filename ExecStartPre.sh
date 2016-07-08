#!/bin/sh
cd $(dirname $0)
# ipset用保存ディレクトリを作成します
[ ! -e ./ipset ] && mkdir ipset

# ipsetのすべてのセットを削除します
ipset destroy

# ipsetのセット/エントリ作成を行います
# それぞれ、悪質な接続元,信頼できる海外接続元,日本国内接続元になります
# ipsetのセーブデータが存在した場合はリストアします
# 存在しない場合はセットを作成します
# 存在しない場合のエントリ作成をfirewalldの起動前に行うと時間がかかり過ぎ
# firewalldがタイムアウトしますので、エントリ作成の作成はfirewalldの起動後に行います
for LIST in BLACK-LIST TRUST-LIST JP-LIST; do
  if [ -e ipset/$LIST ] ; then
    ipset restore < ipset/$LIST
  else
    ipset create $LIST hash:net
  fi
done

# 接続を一時的にブロックするIPのセットを作成します
# エントリの作成はswatchによるアクセス監視で行います
# このセットにエントリしたIPアドレスは1時間(3600秒)で自動的に削除されるようにしています
ipset create BLOCK-LIST hash:net timeout 3600

