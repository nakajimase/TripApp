kill -QUIT `ps -ef | grep unicorn_rails | grep master | grep -v grep | awk '{ print $2 }'`
echo 'Before'
ps -ef | grep unicorn | grep -v grep
bundle exec unicorn_rails -c config/unicorn.rb -E production -D
echo 'After'
ps -ef | grep unicorn | grep -v grep
