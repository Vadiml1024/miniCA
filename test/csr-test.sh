#!/usr/bin/env roundup
describe "CSR tests"

. $(dirname $1)/testhelper.inc

it_signs_a_csr() {
  $ca generate abc

  # fails if file is missing
  # ! $ca sign -r ca xxx.csr

  $ca sign -r ca abc.csr
  [[ -e abc.pem ]]
}
