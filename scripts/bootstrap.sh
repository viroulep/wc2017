apt-get update
apt-get install -y curl git vim htop apt-transport-https

# Create schedapp user if does not exist.
if ! id -u schedapp &>/dev/null; then
  useradd -m -s /bin/bash schedapp
  chown schedapp:schedapp /home/schedapp
fi

echo "Setting up ssh keys for members."

tmp_authorized_keys_path="/tmp/authorized_keys"
for user in viroulep; do
  public_keys_url="https://github.com/$user.keys"

  echo "" >> $tmp_authorized_keys_path
  echo "# Keys for $user" >> $tmp_authorized_keys_path
  curl -s $public_keys_url >> $tmp_authorized_keys_path
done

su schedapp -c "mkdir -p /home/schedapp/.ssh"
su schedapp -c "touch /home/schedapp/.ssh/authorized_keys"
mv /home/schedapp/.ssh/authorized_keys /home/schedapp/.ssh/authorized_keys.bak
chown schedapp:schedapp /tmp/authorized_keys
mv /tmp/authorized_keys /home/schedapp/.ssh


# Setting up rails and db

# Will hold environment variables with secrets
touch /tmp/secrets

echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update

apt-get install -y postgresql-10

user_exists=`sudo -u postgres psql -tAc "select 1 from pg_catalog.pg_roles where rolname='schedapp';"`

if [ "x$user_exists" != "x1" ]; then
  password=`openssl rand -base64 16`
  sudo -u postgres psql -c "create role schedapp login password '$password' createdb;"
  su schedapp -c "echo 'DATABASE_PASSWORD=$password' >> /home/schedapp/.env.production"
fi

# to build rbenv
apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev gcc g++ make

# install nodejs and yarn
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# install stretch backports for certbot
echo "deb http://ftp.debian.org/debian stretch-backports main" | tee /etc/apt/sources.list.d/certbot.list
# this runs apt-get update
curl -sL https://deb.nodesource.com/setup_10.x | bash -

# libpq-dev is for pg gem
apt-get install -y nodejs yarn libpq-dev


# for certbot
apt-get install -y python-certbot-nginx -t stretch-backports

if [ ! -d /home/schedapp/wc2017 ]; then
  su schedapp -c "cd /home/schedapp && git clone https://github.com/viroulep/wc2017.git /home/schedapp/wc2017"
fi
apt-get install -y nginx
cp /home/schedapp/wc2017/conf/nginx_server.conf /etc/nginx/conf.d/
cp /home/schedapp/wc2017/conf/pre_certif.conf /etc/nginx/conf.d/
# Create an empty https conf since we don't have a certificate yet
touch /etc/nginx/nginx_https.conf

service nginx restart

read -p "Do you want to create a new certificate for the server? (N/y)" user_choice
if [ "x$user_choice" == "xy" ]; then
  /home/schedapp/wc2017/scripts/prod_cert.sh create_cert
  cp /home/schedapp/wc2017/conf/nginx_https.conf /etc/nginx/
  rm /etc/nginx/conf.d/pre_certif.conf
  cp /home/schedapp/wc2017/conf/post_certif.conf /etc/nginx/conf.d/
  service nginx restart
fi

echo "Installing cron scripts"
cp /home/schedapp/wc2017/scripts/cert_nginx /etc/cron.weekly

echo "Bootstraping as Schedapp"
su schedapp -c "cd /home/schedapp && /home/schedapp/wc2017/scripts/app_bootstrap.sh"
