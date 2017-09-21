#!/bin/bash

# script vars #

REPO= #osg-testing
MYSQL_ROOT_PASSWORD=top_secret
VO_NAME=TEST_VO
VO_ALIAS=testvo
MYSQL_DB_PASSWORD=secret
DB_PORT=3306
VOMS_PORT=15001
EMAIL_FROM=edquist@cs.wisc.edu
SMTP_HOST=smtp.fnal.gov

svars=(
  REPO MYSQL_ROOT_PASSWORD VO_NAME VO_ALIAS MYSQL_DB_PASSWORD
  DB_PORT VOMS_PORT EMAIL_FROM SMTP_HOST
)

# functions #

fail () { echo "$@" >&2; exit 1; }

retry () {
  local n=$1 delay=$2
  shift 2
  while (( n-- >= 0 )); do
    sleep $delay
    "$@" && return
  done
  return 1
}

cert () {
  # cert {subject|issuer}
  openssl x509 -in /etc/grid-security/hostcert.pem -noout -$1 | sed "s/^$1= //"
}

user_input_var () {
  local __
  # read -p "$1=" -ei "${!1}" "$1"
  read -p "$1= [${!1}] " __
  [[ $__ ]] && eval $1=\$__
  [[ ! ${!1} =~ [^-_a-zA-Z0-9.@] ]] || fail "sorry, i don't like '${!1}'"
}

stars () {
  yes '*' | head -$1 | tr -d '\n'
}

SECTION () {
  local s=$*
  echo
  echo "******$(stars ${#s})******"
  echo "****  $s  ****"
  echo "******$(stars ${#s})******"
  echo
}

on_err () {
  echo
  echo "Error running \"$BASH_COMMAND\" (line ${BASH_LINENO[0]})"
  read -p "Continue? [y/N] " && [[ $REPLY = [yY]* ]] || exit 1
}

trap on_err ERR


[[ $USER = root ]] || fail "You probably mean to run this as root..."

case $1 in
  -ok ) shift; OK=Y ;;
esac
# set script vars if on a tty #

if [[ $OK != Y && -t 0 && -t 1 ]]; then
  for x in ${svars[@]}; do
    user_input_var $x
  done
  echo
  for x in ${svars[@]}; do
    echo "$x=\"${!x}\""
  done
  echo
  read -p 'OK? [y/N] ' && [[ $REPLY = [yY]* ]] || exit 1
fi

HOST_CERT_SUBJECT=$(cert subject)
HOST_CERT_ISSUER=$(cert issuer)

EL_RELEASE=$(</etc/redhat-release)
case $EL_RELEASE in
  *"release 5"* ) EL=5 TOMCAT=tomcat$EL FETCH_CRL=fetch-crl3 ;;
  *"release 6"* ) EL=6 TOMCAT=tomcat$EL FETCH_CRL=fetch-crl  ;;
  * ) fail "Bad redhat-release string: $EL_RELEASE"
esac


SECTION Install the CA Certificates

yum clean --enablerepo=\* expire-cache
yum install -y osg-ca-certs

SECTION Install VOMS

yum install -y ${REPO:+--enablerepo="$REPO"} osg-voms

SECTION Configure MySQL Database 

/etc/init.d/mysqld start
mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"

SECTION Setup the Service Certificates

cd /etc/grid-security
cp -b hostcert.pem voms/vomscert.pem
cp -b hostkey.pem voms/vomskey.pem
chown -R voms:voms voms

cd /etc/grid-security
if [[ -e /etc/grid-security/http ]]; then
  mv /etc/grid-security/http{,~}
fi
mkdir -p /etc/grid-security/http
cp hostcert.pem http/httpcert.pem
cp hostkey.pem http/httpkey.pem
chown -R tomcat:tomcat http

SECTION Configure Tomcat options

echo 'CATALINA_OPTS="${CATALINA_OPTS} -XX:MaxPermSize=256m"' \
     >> /etc/$TOMCAT/$TOMCAT.conf

if [[ $EL = 6 ]]; then
  echo \
  'JAVA_ENDORSED_DIRS="${JAVA_ENDORSED_DIRS}:/usr/share/voms-admin/endorsed"' \
     >> /etc/$TOMCAT/$TOMCAT.conf
fi

cat >> /etc/security/limits.conf <<__EOT__
tomcat          soft    nofile  63536
tomcat          hard    nofile  63536

tomcat          soft    nproc   16384
tomcat          hard    nproc   16384
__EOT__


SECTION Configure Trust Manager

/var/lib/trustmanager-tomcat/configure.sh

SECTION Add and configure a VO

voms-admin-configure install \
    --dbtype mysql \
    --vo $VO_NAME \
    --createdb \
    --deploy-database \
    --dbauser root \
    --dbapwd $MYSQL_ROOT_PASSWORD \
    --dbusername  admin-$VO_NAME \
    --dbpassword $MYSQL_DB_PASSWORD \
    --dbport  $DB_PORT \
    --port $VOMS_PORT \
    --mail-from $EMAIL_FROM \
    --smtp-host $SMTP_HOST \
    --sqlloc /usr/lib64/voms/libvomsmysql.so \
    --cert /etc/grid-security/voms/vomscert.pem \
    --key  /etc/grid-security/voms/vomskey.pem \
    --read-access-for-authenticated-clients 

/sbin/service voms start $VO_NAME
/sbin/service voms-admin start $VO_NAME

retry 10 1 \
/usr/sbin/voms-db-deploy.py add-admin --vo $VO_NAME  \
    --dn "$HOST_CERT_SUBJECT" \
    --ca "$HOST_CERT_ISSUER"

/usr/sbin/$FETCH_CRL -p10 -T10 || :  # fetch-crl errors are common
/sbin/service $TOMCAT start

retry 6 5 \
voms-admin --nousercert --vo $VO_NAME add-ACL-entry \
    /$VO_NAME ANYONE VOMS_CA "CONTAINER_READ,MEMBERSHIP_READ" true

echo "voms.csrf.log_only = true" \
    >> /etc/voms-admin/$VO_NAME/voms.service.properties


SECTION Advertise your VOMS server

printf '"%s" "%s" "%s" "%s" "%s"\n' \
       $VO_ALIAS $HOSTNAME $VOMS_PORT "$HOST_CERT_SUBJECT" $VO_NAME \
       >> /etc/vomses

mkdir -p /etc/grid-security/vomsdir/$VO_NAME

{ echo "$HOST_CERT_SUBJECT"
  echo "$HOST_CERT_ISSUER"
} > /etc/grid-security/vomsdir/$VO_NAME/$HOSTNAME


SECTION Starting and Enabling Services

# commenting these out since for tests we don't need fetch-crl to keep running
#/usr/sbin/$FETCH_CRL || :  # fetch-crl errors are common
#/sbin/service $FETCH_CRL-boot start || :
#/sbin/service $FETCH_CRL-cron start || :

/sbin/service mysqld start
service voms start
service $TOMCAT start

/sbin/chkconfig $FETCH_CRL-boot on
/sbin/chkconfig $FETCH_CRL-cron on

/sbin/chkconfig mysqld on
/sbin/chkconfig voms on
/sbin/chkconfig $TOMCAT on


SECTION All Done

