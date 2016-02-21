#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/assert.sh
include "$C2BASH_HOME"/helperlibs/io.sh
include "$C2BASH_HOME"/helperlibs/toString.sh

declare -g TEST_FAILED=234

# TestString(function name + args), ExpectedValue
function callTest() {
  value=$($1 >/dev/null 2>&1)
  if assertBool "$value" "$2" >/dev/null 2>&1; then
    return 0
  else
    echoerr "Test '$1' falied"
    declare expect1;
    declare expect2;
    boolToString expect1 "$value"
    boolToString expect2 "$2"
    echoerr "Expected $expect2, Recieved $expect1"
    return $TEST_FAILED
  fi
}

function testCallTest() {

  function tr() {
    return 0;
  }
  function fa() {
    return 1;
  }

  if ! callTest tr true ; then
    echoerr "Test 1 for callTest failed"
  fi
  if callTest tr false; then
    echoerr "Test 2 for callTest failed"
  fi
  if callTest fa true; then
    echoerr "Test 3 for callTest failed"
  fi
  if ! callTest fa false; then
    echoerr "Test 4 for callTest failed"
  fi
}

# If this file is directly executed, call the tests.
if [ -z "${BASH_SOURCE[1]}" ]; then
  testCallTest
fi
