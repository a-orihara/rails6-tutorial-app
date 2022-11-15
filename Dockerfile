# ベースとなるイメージの指定（rubyのバージョン安定版（22/10現在）3.1.2を指定）
FROM ruby:2.7.6

# ビルド時に実行するコマンドの指定
# apt-get:Debian系のパッケージを操作・管理するコマンド
# apt-get update:インストール可能なパッケージの一覧の更新
# -qq:quietモードで実行。ログを極力表示させない。エラー以外を表示しないオプション
RUN apt-get update -qq \
  # パッケージのインストール（nodejs、npmを指定）
  # imagemagick:rails tutorial13章の為にインストール
  && apt-get install -y nodejs npm imagemagick \
  # rm -rf:ディレクトリを強制削除
  # aptのキャッシュを削除し容量を小さくする
  && rm -rf /var/lib/apt/lists/* \
  && npm install --global yarn

# 作業ディレクトリの指定
# ここで指定したディレクトリが、その後のDockerfile内でのRUN,COPYなどのあらゆる命令の起点となる。
WORKDIR /rails6-tutorial-app
COPY Gemfile /rails6-tutorial-app/Gemfile
COPY Gemfile.lock /rails6-tutorial-app/Gemfile.lock
# Gemfileに記載されたGem(初回時はrailsが記載)をインストールする。再ビルド時にbundle installするために記載。
RUN bundle install
# コンテナ起動時に毎回実行されるスクリプトを追加する。/usr/bin/はコンテナのLinuxベースのディレクトリ。
COPY entrypoint.sh /usr/bin/
# entrypoint.shの権限(+x:すべてのユーザーに実行権限を追加)を変更
RUN chmod +x /usr/bin/entrypoint.sh
# 1
ENTRYPOINT ["entrypoint.sh"]
# コンテナがホストに対してリッスンするport番号を3000に設定する。
EXPOSE 3000
# イメージの実行時に実行するメインプロセスの設定
CMD ["rails", "server", "-b", "0.0.0.0"]


# 1
# ENTRYPOINTは、コンテナを実行ファイル(executable)として処理するように設定できます。
# exec形式を公式で推奨。shell形式では、CMDやrunコマンドラインの引数を使えません。
# ENTRYPOINTのexec形式は、確実に実行するデフォルトのコマンドと引数を設定するために使います。
# 複数のコマンドが必要な場合は、シェルスクリプトから実行する