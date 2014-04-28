# The ca script to test

here=$(cd $(dirname $1) && pwd)
ca=${here}/../bin/miniCA

export MINICA_TEST_MODE=y 

# A temporary workspace to run tests.
scrub=${here}/tmp

before() {
  rm -rf $scrub
  mkdir -p $scrub
  cd $scrub
}

after() {
  if [ -f https.pid ]; then
    kill -TERM $(cat https.pid) || true
  fi

  cd ..
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
