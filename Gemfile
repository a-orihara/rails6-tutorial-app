source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.6'

gem 'rails',      '6.0.4'
# awsのs3へのアップロードに使用
gem 'aws-sdk-s3',                 '1.113.0', require: false
# imagemagickの画像加工で使用
gem 'image_processing',           '1.12.2'
# imagemagickの画像加工で使用
gem 'mini_magick',                '4.9.5'
# 2
gem 'active_storage_validations', '0.8.2'
# has_secure_passwordを使ってパスワードをハッシュ化するためには、最先端のハッシュ関数であるbcryptが必要
gem 'bcrypt',         '3.1.13'
gem 'faker',                   '2.20.0'
gem 'will_paginate',           '3.3.1'
gem 'bootstrap-will_paginate', '1.0.0'
# 1
gem 'bootstrap-sass', '3.4.1'
gem 'puma',       '4.3.6'
gem 'sass-rails', '5.1.0'
gem 'webpacker',  '4.0.7'
gem 'turbolinks', '5.2.0'
gem 'jbuilder',   '2.9.1'
gem 'bootsnap',   '1.10.3', require: false

group :development, :test do
  gem 'sqlite3', '1.4.2'
  gem 'byebug',  '11.0.1', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console',           '4.0.1'
  gem 'listen',                '3.1.5'
  gem 'spring',                '2.1.0'
  gem 'spring-watcher-listen', '2.0.1'
end

group :test do
  gem 'capybara',                 '3.28.0'
  gem 'selenium-webdriver',       '3.142.4'
  gem 'webdrivers',               '4.1.2'
  gem 'rails-controller-testing', '1.0.4'
  gem 'minitest',                 '5.11.3'
  gem 'minitest-reporters',       '1.3.8'
  gem 'guard',                    '2.16.2'
  gem 'guard-minitest',           '2.4.6'
end

group :production do
  gem 'pg', '1.1.4'
end

# Windows ではタイムゾーン情報用の tzinfo-data gem を含める必要があります
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


# 1
# Bootstrap フレームワークでは、動的なスタイルシートを生成するために LESS CSS 言語を使っていますが、
# Rails の Asset Pipeline はデフォルトでは(LESS と非常によく似た)Sass 言語をサポートします(5.2)。
# そのため、bootstrap-sass は、LESS を Sass へ変換し、
# 必要な Bootstrap ファイルを現在のアプリケーションですべて利用できるようにします。

# 2
# なお執筆時点の Active Storage は、(少々驚きですが)こうしたフォーマット機能やバ リデーション機能がネ
# イティブでサポートされていません。よくあることですが、こうい う場合はそうした機能を gem で追加します。