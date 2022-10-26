#!/bin/bash
# ↑1

# エラーが発生するとスクリプトを終了する
set -e

# 2
rm -f /myapp/tmp/pids/server.pid

# CMDで渡されたコマンド（→Railsのサーバー起動）を実行
exec "$@"

# 1
# 1行目に記載。bashを利用したシェルスクリプトであることを示している
# linuxカーネルはファイルの先頭に#!があれば、その後ろに書かれたコマンド（この場合は/bin/bash）を実行する。

# 2
# Railsに潜在的に存在するserver.pidファイルがあれば削除します。
# pidファイルが既に存在するためサーバーが立ち上がらないエラーを回避する為。
# pidはプロセスid。開発用webサーバーを起動する時に、tmp/pids/server.pidに書き込まれ、
# 終了する時に削除される。server.pidにpidが書かれているとサーバーが起動中と判断されてしまう。