#!/usr/bin/env bash

# /!\ assumed to be executed by root!

create_cert() {
  certbot certonly --webroot -w /home/schedapp/wc2017/public -d sched.virouleau.fr
}

renew_cert() {
  certbot renew
}

cd "$(dirname "$0")"/..

allowed_commands="create_cert renew_cert"
source scripts/_parse_args.sh
