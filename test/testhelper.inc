# The ca script to test

here=$(cd $(dirname $1) && pwd)
ca=${here}/../bin/ca

# A temporary workspace to run tests.
scrub=${here}/tmp

before() {
  mkdir -p $scrub
  cd $scrub
}

after() {
  if [ -f https.pid ]; then
    kill -TERM $(cat https.pid) || true
  fi

  cd ..
  rm -rf $scrub
}

md5() {
  local md5=$(which md5)
  if [[ "$md5" ]]; then
    cat $@ | $md5
  else
    false
  fi
}

generate_certificate() {
  local name=$1
  [[ "$name" ]]
  
  # -- generate a cerificate signed by a CA in ./ca -------------------
  $ca generate $name
  $ca init -r ca
  $ca sign -r ca $name.csr

  [[ -e $name.pem ]]
  [[ -e $name.priv ]]
}
