#!/usr/bin/env roundup
describe "Various certificate validations"

HERE=$(cd $(dirname $1) && pwd)
. $HERE/testhelper.inc

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

start_https_server_for() {
  local commonname=${1:-}
  [[ "$commonname" ]]

  generate_certificate $commonname

  export ROOT=$HERE/res
  export SSL_CERT=$commonname.pem
  export SSL_KEY=$commonname.priv
  export PWD=$(pwd)

  $HERE/res/stmpl $HERE/res/nginx.conf > nginx.conf.actual
  nginx -c $(pwd)/nginx.conf.actual
  retry test -f https.pid

  # verify against root certificate: this is proof that the localhost 
  # certificate can be validated via a root certificate in the 
  # certificate chain. 

  # -- verify certificate with openssl's s_client ---------------------

  # Note that openssl's s_client does not verify the connection name, 
  # that's why the following line checks that there is SSL on 
  # localhost:12346, which verifies against ca/root.pem.
  
  ssl_verify -CAfile ca/root.pem -connect localhost:12346

  # -- verify certificate with gnutls-cli client ----------------------

  # works on a localhost connection
}


it_works_with_localhost() {
  start_https_server_for localhost

    gnutls-cli --x509cafile=ca/root.pem localhost -p 12346 < /dev/null 
  ! gnutls-cli --x509cafile=ca/root.pem othername.minica.dev -p 12346 < /dev/null 
}

it_works_with_dev_name() {
  # .dev hostnames should resolve to 127.0.0.1. If they don't we
  # cannot run this test. 
  if ! [[ $($HERE/res/jit $HERE/res/resolve test.ca.dev) = "127.0.0.1" ]]; then
    false Make sure that .dev hostnames resolves to 127.0.0.1
  fi

  start_https_server_for test.ca.dev

    gnutls-cli --x509cafile=ca/root.pem test.ca.dev -p 12346 < /dev/null 
  ! gnutls-cli --x509cafile=ca/root.pem test2.ca.dev -p 12346 < /dev/null 
  ! gnutls-cli --x509cafile=ca/root.pem localhost -p 12346 < /dev/null 
}
