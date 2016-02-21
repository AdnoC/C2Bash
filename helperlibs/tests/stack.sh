include $(dirname $0)/../stack.sh
echo 'Beginning testing of stack implementation'

function scopeTest() {
  function scopeTestInner() {
    declare -a a=(1 2 3 4)
    declare -i aLength=4
    echo ${a[@]}
    echo $aLength
    push a 'hello world'
    echo ${a[@]}
    echo $aLength
  }
  scopeTestInner
  echo $a
  echo $aLength
}

scopeTest
