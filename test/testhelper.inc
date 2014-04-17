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
    kill -9 $(cat https.pid) || true
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
