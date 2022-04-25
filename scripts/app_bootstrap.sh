
# Get or update rbenv

if [ ! -d $HOME/.rbenv ]; then
	git clone https://github.com/rbenv/rbenv.git ~/.rbenv
else
	cd ~/.rbenv && git pull
fi
cd ~/.rbenv && src/configure && make -C src
echo '' > ~/.bash_aliases
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_aliases
echo 'eval "$(rbenv init -)"' >> ~/.bash_aliases
echo 'export RAILS_ENV=production' >> ~/.bash_aliases
# necessary for puma
echo 'export RACK_ENV=production' >> ~/.bash_aliases
# remove annoying message
echo 'export LC_ALL=en_US.UTF-8' >> ~/.bash_aliases
source ~/.bash_aliases

echo '[[ -f ~/.bashrc ]] && . ~/.bashrc' > ~/.bash_profile
cp ~/wc2017/conf/bashrc ~/.bashrc

if [ ! -d $HOME/.rbenv/plugins/ruby-build ]; then
	git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
else
	cd ~/.rbenv/plugins/ruby-build && git pull
fi


# the repo is cloned by the root bootstrap
rbenv install -v `cat ~/wc2017/.ruby-version` -s

# Safe to be executed multiple times, as subsequent bootstrap will be ignored
mv ~/.env.production ~/wc2017

# setup crontabs
#cat << EOF > /tmp/cron.afs
#@daily /home/afs/speedcubingfrance.org/scripts/deploy.sh scheduled_jobs
#@weekly /home/afs/speedcubingfrance.org/scripts/backup_db.sh
#EOF
#crontab -r
#crontab /tmp/cron.afs

read -p "Do you want to setup the rails application? (N/y)" user_choice
if [ "x$user_choice" == "xy" ]; then
	/home/schedapp/wc2017/scripts/deploy.sh bootstrap_rails
fi

read -p "Do you want to setup the environment variables? (N/y)" user_choice
if [ "x$user_choice" == "xy" ]; then
	/home/schedapp/wc2017/scripts/deploy.sh setup_env
fi
