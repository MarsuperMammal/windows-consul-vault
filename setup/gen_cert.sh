#!/bin/bash
set -e

usage() {
  cat <<EOF
Generate a self-signed SSL cert

Prerequisites:

Requires openssl is installed and available on \$PATH.

Usage:

  $0 <COMPANY>

Where DOMAIN is the domain to be deployed and COMPANY is your companies name.

And a self-signed cert for Consul/Vault with the following subjectAltNames in the directory specified.

 * *.node.consul
 * *.service.consul

 * IP
 * 127.0.0.1
EOF

  exit 1
}

if ! which openssl > /dev/null; then
  echo
  echo "ERROR: The openssl executable was not found. This script requires openssl."
  echo
  usage
fi

COMPANY=$1

if [ "x$COMPANY" == "x" ]; then
  echo
  echo "ERROR: Specify company as the third argument, e.g. HashiCorp"
  echo
  usage
fi

# Create a temporary build dir and make sure we clean it up. For
# debugging, comment out the trap line.
BUILDDIR=`mktemp -d /tmp/ssl-XXXXXX`
trap "rm -rf $BUILDDIR" INT TERM EXIT

echo "Creating Vault cert"

DOMAIN=consul
BASE="vault"
CSR="${BASE}.csr"
KEY="${BASE}.key"
CRT="${BASE}.crt"
VAULTSSLCONF=${BUILDDIR}/vault_selfsigned_openssl.cnf

 cp openssl.cnf ${VAULTSSLCONF}
 (cat <<EOF
[ alt_names ]
DNS.1 = *.node.consul
DNS.2 = *.service.consul
IP.1 = 127.0.0.1
EOF
) >> $VAULTSSLCONF

# MinGW/MSYS issue: http://stackoverflow.com/questions/31506158/running-openssl-from-a-bash-script-on-windows-subject-does-not-start-with
if [[ "${OS}" == "MINGW32"* || "${OS}" == "MINGW64"* || "${OS}" == "MSYS"* ]]; then
  SUBJ="//C=US\ST=California\L=San Francisco\O=${COMPANY}\OU=${BASE}\CN=*.consul"
else
  SUBJ="/C=US/ST=California/L=San Francisco/O=${COMPANY}/OU=${BASE}/CN=*.consul"
fi

openssl genrsa -out $KEY 2048
openssl req -new -out $CSR -key $KEY -subj "${SUBJ}" -config $VAULTSSLCONF
openssl x509 -req -days 3650 -in $CSR -signkey $KEY -out $CRT -extensions v3_req -extfile $VAULTSSLCONF
