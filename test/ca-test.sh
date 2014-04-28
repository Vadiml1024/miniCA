#!/usr/bin/env roundup
describe "CA tests"

. $(dirname $1)/testhelper.inc

it_inits_ca() {
  $ca init -r ca
  [[ -f ca/root.pem ]]
}

it_does_not_overwrite_ca() {
  $ca init -r ca
  checksum=$(md5 ca/root/private_key.pem)
  $ca init -r ca
  [[ "${checksum}" = $(md5 ca/root/private_key.pem) ]]
}
