#!/bin/sh -eu
#
# This script will pull all Docker images that are currently
# bound to your devilbox git state.
#
# When updating the devilbox via git, do run this script once
# in order to download all images locally.
#

WHICH="all"
if [ "${#}" -eq "1" ]; then
	if [ "${1}" = "bind" ]; then
		WHICH="bind"
	elif [ "${1}" = "php" ]; then
		WHICH="php"
	elif [ "${1}" = "httpd" ]; then
		WHICH="httpd"
	elif [ "${1}" = "mysql" ]; then
		WHICH="mysql"
	elif [ "${1}" = "rest" ]; then
		WHICH="rest"
	else
		echo "Error: Unknown option"
		echo "Supported: php, httpd, mysql, rest"
		exit 1
	fi
fi


###
### Path of devilbox repository
###
CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"


###
### BIND
###
if [ "${WHICH}" = "all" ] || [ "${WHICH}" = "bind" ]; then
	TAG="$( grep '^[[:space:]]*image:[[:space:]]*cytopia/bind' "${CWD}/docker-compose.yml" | sed 's/^.*://g' )"
	docker pull cytopia/bind:${TAG}
fi


###
### PHP
###
TAG="$( grep '^[[:space:]]*image:.*\${PHP_SERVER' "${CWD}/docker-compose.yml" | sed 's/^.*://g' )"
#docker pull devilbox/php-fpm:5.3-work
#docker pull devilbox/php-fpm:5.4-work
#docker pull devilbox/php-fpm:5.5-work
docker pull devilbox/php-fpm:5.6-work
docker pull devilbox/php-fpm:7.0-work
docker pull devilbox/php-fpm:7.1-work
docker pull devilbox/php-fpm:7.2-work
#docker pull cytopia/hhvm-latest:${TAG}
if [ "${WHICH}" = "all" ] || [ "${WHICH}" = "php" ]; then
	SUFFIX="$( grep -E '^\s+image:\s+devilbox/php-fpm' "${CWD}/docker-compose.yml" | sed 's/.*}//g' )"
	IMAGES="$( grep -Eo '^#*PHP_SERVER=[.0-9]+' "${CWD}/env-example" | sed 's/.*=//g' )"
	echo "${IMAGES}" | while read version ; do
		docker pull devilbox/php-fpm:${version}${SUFFIX}
	done
fi


###
### HTTPD
###
TAG="$( grep '^[[:space:]]*image:.*\${HTTPD_SERVER' "${CWD}/docker-compose.yml" | sed 's/^.*://g' )"
docker pull devilbox/nginx-stable:${TAG}
#docker pull devilbox/nginx-mainline:${TAG}
docker pull devilbox/apache-2.2:${TAG}
#docker pull devilbox/apache-2.4:${TAG}
if [ "${WHICH}" = "all" ] || [ "${WHICH}" = "httpd" ]; then
	SUFFIX="$( grep -E '^\s+image:\s+devilbox/\${HTTPD_SERVER' "${CWD}/docker-compose.yml" | sed 's/.*://g' )"
	IMAGES="$( grep -Eo '^#*HTTPD_SERVER=[-a-z]+[.0-9]*' "${CWD}/env-example" | sed 's/.*=//g' )"
	echo "${IMAGES}" | while read version ; do
		docker pull devilbox/${version}:${SUFFIX}
	done
fi

###
### MYSQL
###
TAG="$( grep '^[[:space:]]*image:.*\${MYSQL_SERVER' "${CWD}/docker-compose.yml" | sed 's/^.*://g' )"
#docker pull cytopia/mysql-5.5:${TAG}
docker pull cytopia/mysql-5.6:${TAG}
docker pull cytopia/mysql-5.7:${TAG}
docker pull cytopia/mysql-8.0:${TAG}
#docker pull cytopia/mariadb-5.5:${TAG}
docker pull cytopia/mariadb-10.0:${TAG}
docker pull cytopia/mariadb-10.1:${TAG}
#docker pull cytopia/mariadb-10.2:${TAG}
#docker pull cytopia/mariadb-10.3:${TAG}

###
### MYSQL
###
#docker pull postgres:9.1
#docker pull postgres:9.2
#docker pull postgres:9.3
#docker pull postgres:9.4
#docker pull postgres:9.5
#docker pull postgres:9.6
#docker pull postgres:10.0
#docker pull postgres:10.1
#docker pull postgres:10.2
docker pull postgres:10.3
if [ "${WHICH}" = "all" ] || [ "${WHICH}" = "mysql" ]; then
	SUFFIX="$( grep -E '^\s+image:\s+cytopia/\${MYSQL_SERVER' "${CWD}/docker-compose.yml" | sed 's/.*://g' )"
	IMAGES="$( grep -Eo '^#*MYSQL_SERVER=[-a-z]+[.0-9]*' "${CWD}/env-example" | sed 's/.*=//g' )"
	echo "${IMAGES}" | while read version ; do
		docker pull cytopia/${version}:${SUFFIX}
	done
fi

###
### REDIS
###
#docker pull redis:2.8
#docker pull redis:3.0
#docker pull redis:3.2
docker pull redis:4.0

###
### Rest of the fucking owl
###
#docker pull memcached:1.4.21
#docker pull memcached:1.4.22
#docker pull memcached:1.4.23
#docker pull memcached:1.4.24
#docker pull memcached:1.4.25
#docker pull memcached:1.4.26
#docker pull memcached:1.4.27
#docker pull memcached:1.4.28
#docker pull memcached:1.4.29
#docker pull memcached:1.4.30
#docker pull memcached:1.4.31
#docker pull memcached:1.4.32
#docker pull memcached:1.4.33
#docker pull memcached:1.4.34
#docker pull memcached:1.4.35
#docker pull memcached:1.4.36
#docker pull memcached:1.4.37
#docker pull memcached:1.4.38
#docker pull memcached:1.4.39
#docker pull memcached:1.5.0
#docker pull memcached:1.5.1
#docker pull memcached:1.5.2
#docker pull memcached:1.5.3
docker pull memcached:1.5.4
#docker pull memcached:1.5.4
#docker pull memcached:1.5.5
#docker pull memcached:latest

###
### MONGODB
### For all other non-base service, only download the currently enabled one
###
#docker pull mongo:2.8
#docker pull mongo:3.0
#docker pull mongo:3.2
#docker pull mongo:3.4
#docker pull mongo:3.5
#docker pull mongo:3.6
#docker pull mongo:3.7

if [ "${WHICH}" = "all" ] || [ "${WHICH}" = "rest" ]; then
	if [ ! -f "${CWD}/.env" ]; then
		cp "${CWD}/env-example" "${CWD}/.env"
	fi
	docker-compose --project-directory "${CWD}" --file "${CWD}/docker-compose.yml" pull
fi
