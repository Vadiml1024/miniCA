#!/usr/bin/env roundup
describe "Various certificate validations"

HERE=$(cd $(dirname $1) && pwd)
. $HERE/testhelper.inc

# .dev hostnames should resolve to 127.0.0.1. If they don't we
# do not run 
if [[ $(res/jit res/resolve test.ca.dev) = "127.0.0.1" ]]; then
  DEV_RESOLVES_TO_LOCALHOST=y
else
  DEV_RESOLVES_TO_LOCALHOST=
fi

retry() {
  for i in 1 2 3 4 5 6 7 8 9 10 ; do
    $@ && return
    sleep 0.1
  done
  
  echo "$@ fails after 10 tries; giving up"
  return 1
}

ssl_verify() {
  result=$(openssl s_client -showcerts $@ 2>/dev/null 2>/dev/null </dev/null | 
    grep "Verify return code" | 
    sed 's-.*: --')
  echo $result
  echo $result | grep '^0 ' > /dev/null
}

it_has_prerequisites() {
  which curl || false "Missing curl"
  which gnutls-cli || false "Missing gnutls-cli"

  which ruby || later  "Missing ruby"
  which nginx || later "Missing nginx"
}

it_works_with_nginx() {
  generate_certificate localhost

  export ROOT=$HERE/res
  export SSL_CERT=localhost.pem
  export SSL_KEY=localhost.priv
  export PWD=$(pwd)

  $HERE/res/stmpl $HERE/res/nginx.conf > nginx.conf.actual
  nginx -c $(pwd)/nginx.conf.actual
  retry test -f https.pid

  # verify against root certificate: this is proof that the localhost 
  # certificate can be validated via a root certificate in the 
  # certificate chain. 

  # -- verify certificate with openssl's s_client ---------------------

  # Note that openssl's s_client does not verify the connection name 
  # (i.e. localhost)
  
  ssl_verify -CAfile ca/root/root/certificate.pem -connect localhost:12346

  # -- verify certificate with gnutls-cli client ----------------------

  # works on a localhost connection
  gnutls-cli --x509cafile=ca/root/root/certificate.pem localhost -p 12346 < /dev/null 

  # don't trust on non-localhost connection
  if [[ "$DEV_RESOLVES_TO_LOCALHOST" ]]; then
    ! gnutls-cli --x509cafile=ca/root/root/certificate.pem test.ca.dev -p 12346 < /dev/null 
  fi
}
