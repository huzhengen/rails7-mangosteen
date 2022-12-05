# Rails7-mangosteen

Create the project
```
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
bundle config mirror.https://rubygems.org https://gems.ruby-china.com
gem install rails -v 7.0.2.3
pacman -S postgresql-libs
cd ~/repos
rails new --api --database=postgresql --skip-test mangosteen-1
code mangosteen-1
bundle exe rails server
bundle --verbose
```

Start postgres in docker
```
docker run -d \
    --name db-for-mangosteen \
    -e POSTGRES_USER=mangosteen \
    -e POSTGRES_PASSWORD=123456 \
    -e POSTGRES_DB=mangosteen_dev \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v mangosteen-data:/var/lib/postgresql/data \
    --network=network1 \
    postgres:14
```

Database
```
bin/rails g model user email:string name:string
bin/rails db:migrate
bin/rails db:rollback step=1
RAILS_ENV=test bin/rails db:create db:migrate
```

User
```
bin/rails g model user email:string name:string
bin/rails g controller users show create
```

ValidationCode
```
bin/rails g model ValidationCode email:string kind:string used_at:datetime
bin/rails g controller Api::V1::ValidationCodes
```

Items
```
bin/rails g model item
bin/rails g controller Api::V1::Items
```

kaminari
```
bin/rails g kaminari:config
```

RSpec
```
bin/rails generate rspec:install
bin/rails generate rspec:model user
bundle exec rspec
```