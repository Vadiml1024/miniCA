#!/usr/bin/env roundup
describe "Verifies certificate works with HTTP server"

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

it_has_prerequisites() {
  which curl || false "Missing curl"
  which ruby || later  "Missing ruby"
  which nginx || later "Missing nginx"
}

it_works_with_ruby_https() {
  generate_certificate localhost

  ruby $HERE/res/https.rb --root $HERE/res --port 12346 --certificate localhost.pem --key localhost.priv &
  retry test -f https.pid

  https_tests
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

  https_tests
}

# -- run actual tests -------------------------------------------------


# -- test unverified HTTPS connection -------------------------------
# This verifies that the certificate works with the server.

https_tests() {

  if [[ "helloworld" != $(curl --ipv4 -k https://localhost:12346) ]]; then
    false not equal
  fi

  # [todo] we would like to verify the certificate via curl also. However,
  # on OSX curl ignores the ca-related command line arguments and uses
  # the system's certificate store instead -- and can not be used
  # for a scripted test as a result.
}
