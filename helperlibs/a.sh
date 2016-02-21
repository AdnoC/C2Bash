function a() {
  q=3
  source ./getRef.sh w q
  echo $w
  w=0
  echo $q
}

# a
# echo $w


b() {
  e[2]='1234'
  declare -n p=(e[2])
  p='zcxv'
}


c() {
  declare -n w=$1
  echo ${!w}
  w=te
  # eval "$w=54qwer"
  echo $w
  # declare -n $var=$1
  # echo $var
}


e=(a s d f)
# b 'e[2]'
c e[2]
echo ${e[@]}


