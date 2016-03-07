wd="$(dirname "${BASH_SOURCE[0]}")"
source "$wd/../../main.sh"
export __DEBUG=true 

output="$(source "$C2BASH_HOME"/scanner/scanner.sh "$wd/sample.c")"
if echo "$output" | diff "$wd"/scannerTest.expected - ; then
  echo "Test Succeeded"
  return 0
else
  echo "Test Failed"
  return 1
fi
