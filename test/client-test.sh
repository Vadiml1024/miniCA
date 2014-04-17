#!/usr/bin/env roundup
describe "Client tests"

. $(dirname $1)/testhelper.inc

it_generates_key_and_csr() {
  $ca generate abc
  [[ -e abc.priv ]]
  [[ -e abc.csr ]]
}

it_does_not_overwrite_key_and_csr() {
  $ca generate abc
  ! $ca generate abc
}
