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

it_works_with_https() {
  which ruby || later "Missing ruby"
  which curl || later "Missing curl"

  # -- generate a cerificate signed by a CA in ./ca -------------------
  $ca generate localhost
  $ca init -r ca
  $ca sign -r ca localhost.csr

  # -- start a server in the background -------------------------------
  #    and wait until pid file exists
  [[ -e localhost.pem ]]
  [[ -e localhost.priv ]]
  
  ruby $HERE/https.rb --port 12346 --certificate localhost.pem --key localhost.priv &
  retry test -f https.pid

  # -- test unverified HTTPS connection -------------------------------
  [[ "helloworld" = $(curl -k https://localhost:12346) ]]

  # -- shutdown server ------------------------------------------------
  kill -9 $(cat https.pid)
}
