#!/usr/bin/env roundup
describe "CA tests"

. $(dirname $1)/testhelper.inc

it_verifies_certificate() {
  $ca init -r ca1
  $ca generate foo
  $ca sign -r ca1 foo.csr

  # see issue #2
  $ca verify -r ca1 foo.reverse.pem

  # fails if file is missing
  
  # fails to verify against other ca
  $ca init -r ca2
  ! $ca verify -r ca2 foo.pem
}
