#!/usr/bin/env bash

include "$C2BASH_HOME"/tests/testing.sh
include "$C2BASH_HOME"/helperlibs/assert.sh

echo 'Beginning testing of assertion implementation'
# Exit when we try to use an uninitialized variable
set -o nounset
# Exiting on error would make testing a pain.
set +o errexit

function assertBoolTest() {
  echotab 'In test: assertBoolTest'
  if ! assertBool '0' 0 >/dev/null; then
    echoerr "Test assertBool1 failed"
  fi
  if assertBool '01' 0 >/dev/null 2>&1; then
    echoerr "Test assertBool2 failed"
  fi
  if ! assertBool 5 1 >/dev/null; then
    echoerr "Test assertBool4 failed"
  fi
  if ! assertBool 1 1 >/dev/null; then
    echoerr "Test assertBool4 failed"
  fi
  echotab 'Completed tests for: assertBoolTest'
}

function assertEqualTest() {
  echotab 'In test: assertEqualTest'
  callTest "assertEqual 'a ' 'a'" 0
  callTest "assertEqual 'a ' 'b'" 1
  callTest "assertEqual 'a' 'b'" 1

  echotab 'Completed tests for: assertEqualTest'
}

incrementDebugTab -3
assertBoolTest

assertEqualTest
