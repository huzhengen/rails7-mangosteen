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

ValidationCode.destroy_all
ValidationCode.count
```

Rails
```
bin/rails routes
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
bin/rails generate rspec:request validation_codes
```

Items
```
bin/rails g model item
bin/rails g controller Api::V1::Items
bin/rails generate rspec:request items
bin/rails g migration AddKindToItem
```

Tags
```
bin/rails g model tag user:references name:string sign:string deleted_at:datetime
bin/rails g controller api/v1/tags
bin/rails g migration AddKindToTags
```

Sessions
```
bin/rails g controller api/v1/sessions
```

Me
```
bin/rails g controller api/v1/mes
```

kaminari
```
bin/rails g kaminari:config
```

RSpec
```
bin/rails generate rspec:install
bin/rails generate rspec:model user
bin/rails generate rspec:request items
bin/rails generate rspec:request validation_codes
bundle exec rspec
```

key
```
rm config/credentials.yml.enc
EDITOR="code --wait" rails credentials:edit
EDITOR="code --wait" rails credentials:edit --environment production
```

Linux
```
sudo adduser mangosteen
apt-get update
usermod -a -G docker mangosteen
mkdir /home/mangosteen/.ssh
cp ~/.ssh/authorized_keys /home/mangosteen/.ssh
chown -R mangosteen:mangosteen /home/mangosteen/.ssh/
chmod +x bin/pack_for_remote.sh bin/setup_remote.sh
cp -r /workspaces/oh-my-env-1/temp/xxx vendor
```

docker
```
docker ps -a
docker stop xxx && docker rm xxx
docker rm -f xxx
docker image ls
docker image rm xxx
docker logs xxx
docker system prune
```

Mailer
```
bin/rails generate mailer User
bin/rails c
UserMailer.welcome_email("123456", "xxx@xxx.com").deliver
```

Git
```
git rm -r --cached dist
git add .
git commit --amend -m "update"
```

rspec_api_documentation
```
mkdir spec/acceptance
vim spec/acceptance/orders_spec.rb
code spec/acceptance/orders_spec.rb
bin/rake docs:generate
open doc/api/index.html
pnpx http-server doc/api/
```

middleware
```
bin/rails middleware
```

https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#configure-your-test-suite

```
bin/rails g migration RenameTagsIdToTagIds
```