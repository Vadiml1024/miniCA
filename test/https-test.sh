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

it_works_with_https() {
  which ruby || later "Missing ruby"
  which curl || later "Missing curl"

  # -- generate a cerificate signed by a CA in ./ca -------------------
  $ca generate localhost
  $ca init -r ca
  $ca sign -r ca localhost.csr

  # -- start a server in the background -------------------------------
  #    and wait until pid file exists. The server will be killed 
  #    in after() (see testhelper.inc)
  [[ -e localhost.pem ]]
  [[ -e localhost.priv ]]
  
  ruby $HERE/https.rb --root $HERE/httproot --port 12346 --certificate localhost.pem --key localhost.priv &
  retry test -f https.pid

  # -- test unverified HTTPS connection -------------------------------
  [[ "helloworld" = $(curl -k https://localhost:12346) ]]

  # -- verify certificate with openssl's s_client ---------------------

  # verify against root certificate: this is proof that the localhost 
  # certificate is signed by the root certificate.
  ssl_verify -CAfile ca/root/certificate.pem -connect localhost:12346
  
  later Some tests below do not work
  # TODO: verify against server certificate. Does not work; should it?
  # The code below does not work yet.. why?
  # openssl s_client -showcerts -connect localhost:12346  </dev/null | openssl x509 -outform PEM > server.pem
  # cat server.pem
  # ssl_verify -CAfile server.pem -connect localhost:12346

  # -- curl connection fails, when no custom cert is specified --------
  curl https://localhost:12346 && false
  [[ "$?" = 60 ]]
  
  # -- test HTTPS connection with given CAcert ------------------------
  # TODO: 
  # curl --cacert ca/root/certificate.pem https://localhost:12346
  
  #  [[ "helloworld" = $(curl -k https://localhost:12346) ]]
}
