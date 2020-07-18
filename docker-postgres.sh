#!/bin/sh

echo "Installing Docker"
sudo yum update -y
sudo yum upgrade -y
sudo yum remove docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-engine
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
sudo yum-config-manager -y \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

echo "Starting and Enabling Docker"
sudo systemctl start docker
sudo systemctl enable docker

echo "Configuring database user"
read -p "DB user name: " name
read -s -p "DB password: " password

export POSTGRES_USER=$name
export POSTGRES_PASSWORD=$password
export DB_NAME="my_postgres_db"

sudo docker rm --force postgres || true

echo "Creating database container"
sudo docker run -d \
  --name postgres \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$DB_NAME \
  -p 5432:5432 \
  --restart always \
  postgres:9.6.8-alpine

sleep 20 # Ensuring enough time for postgres database to initialize and create role. (**Important)

sudo docker exec -i postgres psql -U $POSTGRES_USER -d $DB_NAME <<-EOF
create table testdb (
  id serial,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(100),
  gender VARCHAR(100)
);
INSERT INTO testdb (first_name, last_name, email, gender) values ('Rajesh', 'Kumar', 'rk90229@example.com', 'Male');
EOF
