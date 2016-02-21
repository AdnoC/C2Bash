function recursiveLimit() {
  let recurseCount=recurseCount+1
  if [ "$(expr $recurseCount % 100)" -eq 0 ]; then
    echo "On recurse number $recurseCount"
  fi
  recursiveLimit
}

# Seg faulted after 7200 recurses
function recursiveLimitTest() {
  declare -gi recurseCount=0
  recursiveLimit
  echo "Final recurse count: $recurseCount"
}

recursiveLimitTest
