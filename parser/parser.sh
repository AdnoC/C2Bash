#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/queue.sh
include "$C2BASH_HOME"/helperlibs/char.sh
include "$C2BASH_HOME"/helperlibs/stack.sh
include "$C2BASH_HOME"/helperlibs/tree.sh
include "$C2BASH_HOME"/scanner/tokens.sh
include "$C2BASH_HOME"/parser/grammarUnits.sh
include "$C2BASH_HOME"/helperlibs/constantIds.sh
declare -gi NO_MATCH=2314;
declare -gi PARSE_ERROR=528
# http://www.quut.com/c/ANSI-C-grammar-y.html
# Or Annex A of http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf
# Top level is a translation_unit

resetNextId

setId NODE_CLASS
setId NODE_TYPE
setId NODE_VALUE

setId NODE_IDENTIFIER


# All the try* functions return NO_MATCH if there wasn't a match
# They also take a Pointer::newNode as their first argument

# Pointer::tokenType, Pointer::tokenValue, Pointer::lineNumber, Bool::noSkipWhitespace, Bool::noSkipComment
function nextToken() {
  declare -n ret1=$1
  declare -n ret2=$2
  declare -n ret3=$3
  Stack::unshift tokenTypes tType
  Stack::unshift tokenValues tVal
  Stack::unshift lineNumbers lNum
  while { [ -z "$4" ] && [ $tType -eq $T_WHITESPACE ]; } || { [ -z "$5" ] && [ $tType -eq $T_COMMENT ]; }; do
    Stack::unshift tokenTypes tType
    Stack::unshift tokenValues tVal
    Stack::unshift lineNumbers lNum
  done
  ret1=$tType
  ret2=$tVal
  ret3=$lNum
}
# Int::tokenType, String::tokenValue, Int::lineNumber
function resetToken() {
  Stack::shift tokenTypes "$1"
  Stack::shift tokenValues "$2"
  Stack::shift lineNumbers "$3"
}

# String::Error, Int::lineNumber
function parseError() {
  >&2 echo "Parse Error on line $2"
  >&2 echo "$1"
  >&2 echo "Note that lines with escaped newline characters aren't counted"
  exit $PARSE_ERROR
}

# Pointer::newNode, Int::tokenType, String::value
function tryIntConstant() {
  declare t=0
  if [ $2 -eq $T_INTEGER_CONSTANT ] || { [ $2 -eq $T_CHARACTER_CONSTANT ] && t=1; }; then
    declare val=$3
    if [ $t -eq 1 ]; then
      Char::toInt intVal $3
      val=$intVal
    fi

    declare -n ret=$1
    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_INTEGER_CONSTANT
    Tree::set node $NODE_VALUE $intVal

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryFloatConstant() {
  if [ $2 -eq $T_FLOATING_CONSTANT ]; then
    declare -n ret=$1

    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_FLOAT_CONSTANT
    Tree::set node $NODE_VALUE $3

    ret=$node
    return 0;
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::tokenValue
function tryEnumConstant() {
  if [ $2 -eq $T_IDENTIFIER ] && Array::inArray enumConstants "$3"; then
    declare -n ret=$1

    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_ENUMERATION_CONSTANT
    Tree::set node $NODE_VALUE "$3"

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::tokenValue
function tryConstant() {
  if tryIntConstant node $2 "$3" || tryFloatConstant node "$2" "$3" || tryEnumConstant node $2 "$3"; then
    if [ -z node ]; then
      declare -n ret=$1
      ret=$node
    fi
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryString() {
  declare t=0
  if [ $2 -eq $T_STRING_CONSTANT ] || { [ $2 -eq $T_FUNC_NAME ] && t=1; }; then
    declare -n ret=$1

    declare type=$G_STRING_LITERAL
    if [ $t -eq 1 ]; then
      type=$G_FUNC_NAME
    fi

    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_STRING_LITERAL
    Tree::set node $NODE_TYPE $G_FUNC_NAME
    Tree::set node $NODE_VALUE "$3"

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryBaseTypeSpecifier() {
  declare t=0
  case $2 in
    $T_VOID)
      t=$G_VOID
      ;;
    $T_CHAR)
      t=$G_CHAR
      ;;
    $T_SHORT)
      t=$G_SHORT
      ;;
    $T_INT)
      t=$G_INT
      ;;
    $T_LONG)
      t=$G_LONG
      ;;
    $T_FLOAT)
      t=$G_FLOAT
      ;;
    $T_DOUBLE)
      t=$G_DOUBLE
      ;;
    $T_SIGNED)
      t=$G_SIGNED
      ;;
    $T_UNSIGNED)
      t=$G_UNSIGNED
      ;;
    $T_BOOL)
      t=$G_BOOL
      ;;
    $T_COMPLEX)
      t=$G_COMPLEX
      ;;
    $T_IMAGINARY)
      t=$G_IMAGINARY
      ;;
    *)
      ;;
  esac
  if [ $t -ne 0 ]; then
    declare -n ret=$1
    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_TYPE_SPECIFIER
    Tree::set node $NODE_TYPE $t

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

function tryConstantExpression() {
  #placehoder
  return 0
}


# Pointer::newNode, Int::tokenType, String::value
function tryEnumerator() {
  declare newNode
  if tryIdentifier newNode "$2" "$3"; then
    Stack::shift enumConstants "$3"
    declare -n ret=$1

    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_ENUMERATOR
    Tree::set node $NODE_IDENTIFIER "$3"

    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if [ $nextType -eq $T_ASSIGN_OP ]; then
      nextToken nextType nextValue lineNum
      if tryConstantExpression newNode $nextType "$nextValue"; then
        Tree::set node $NODE_VALUE "$newNode"
      else
        parseError "Enumerators must be assigned a constant value if they are to be assigned" $lineNum
      fi
    else
      resetToken $nextType "$nextValue" $lineNum
    fi

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryTypeQualifier() {
  declare t=0
  case $2 in
    $T_CONT)
      t=$G_CONST
      ;;
    $T_RESTRICT)
      t=$G_RESTRICT
      ;;
    $T_VOLATILE)
      t=$G_VOLATILE
      ;;
    $T_ATOMIC)
      t=$G_ATOMIC
      ;;
    *)
      ;;
  esac

  if [ $t -ne 0 ]; then
    declare -n ret=$1
    declare node
    Tree node

    Tree::set node $NODE_CLASS $G_TYPE_QUALIFIER
    Tree::set node $NODE_TYPE $t

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function trySpecifierQualifierList() {
  declare newNode
  if tryTypeSpecifier newNode $2 "$3" || tryTypeQualifier newNode $2 "$3"; then
    declare ret=$1
    declare node
    Tree node
    declare values
    Stack values

    Tree::set node $NODE_CLASS $G_SPECIFIER_QUALIFIER_LIST
    Stack::shift values $newNode

    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if trySpecifierQualifierList newNode $nextType "$nextValue"; then
      declare otherVals
      Tree::get newNode otherVals
      Array::Merge values otherVals
    else
      resetToken $nextType "$nextValue" $lineNum
    fi

    Tree::set node $NODE_VALUE $values

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

function tryAbstractDeclarator() {
  #placehoder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function tryTypeName() {
  declare newNode
  if trySpecifierQualifierList newNode $2 "$3"; then
    declare -n ret=$1

    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_TYPE_NAME

    declare values
    Stack values
    Stack::shift values "$newNode"

    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if tryAbstractDeclarator newNode $nextType "$nextValue"; then
      Stack::shift values $newNode
    else
      resetToken $nextType "$nextValue" $lineNum
    fi

    Tree::set node $NODE_VALUE $values

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryAtomicTypeSpecifier() {
  if [ $2 -eq $T_ATOMIC ]; then
    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if [ $nextType -eq $T_LPAREN ]; then
      nextToken nextType nextValue lineNum
      declare newNode
      if tryTypeName newNode $nextType "nextValue"; then
        declare -n ret=$1

        declare node
        Tree node
        Tree::set node $NODE_CLASS $G_ATOMIC_TYPE_SPECIFIER
        Tree::set node $NODE_VALUE $newNode

        ret=$node
        return 0
      else
        parseError "Atomic declarations must be followed with a type name" $lineNum
      fi
    else
      parseError "Atomic declarations must be followed with a type name in parenthases" $lineNum
    fi
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryStructOrUnion() {
  declare t=0
  case $2 in
    $T_STRUCT)
      t=$G_STRUCT
      ;;
    $T_UNION)
      t=$G_UNION
      ;;
    *)
      ;;
  esac

  if [ $t -ne 0 ]; then
    declare -n ret=$1
    declare node
    Tree node
    
    Tree::set node $NODE_CLASS $G_STRUCT_OR_UNION
    Tree::set node $NODE_TYPE $t

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

function tryStructDeclaration() {
  #placehoder
  return 0
}

function tryStructDeclarationList() {
  declare newNode
  if tryStructDeclaration newNode $2 "$3"; then
    declare node
    Tree node
    declare values
    Stack values

    Tree::set node $NODE_CLASS $G_STRUCT_DECLARATION_LIST
    Stack::shift values $newNode

    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if tryStructDeclaration newNode $nextType "$nextValue"; then
      declare otherVals
      Tree::get newNode $NODE_VALUE otherVals
      Array::Merge values otherVals
    fi

    Tree::set node $NODE_VALUE $values

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}
# Pointer::newNode, Int::tokenType, String::value
function tryStructUnionTypeSpecifier() {
  declare newNode
  if tryStructOrUnion newNode $2 "$3"; then
    declare -n ret=$1
    declare node
    Tree node

    declare nType
    Tree::get newNode $NODE_TYPE nType

    Tree::set node $NODE_CLASS $G_STRUCT_OR_UNION_SPECIFIER
    Tree::set node $NODE_TYPE $nType

    declare hadIdenOrBrace=0

    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if tryIdentifier newNode $nextType "$nextValue"; then
      hadIdenOrBrace=1
      Tree::set node $NODE_IDENTIFIER $newNode
      nextToken nextType nextValue lineNum
    fi

    if [ $nextType -eq $T_LBRACE ]; then
      hadIdenOrBrace=1
      if tryStructDeclarationList newNode $nextType "$nextValue"; then
        Tree::set node $NODE_VALUE $newNode

        nextToken nextType nextValue lineNum
        if [ $nextType -ne $T_RBRACE ]; then
          parseError "Missing '}' after struct declaration list" $lineNum
        fi
      else
        PARSE_ERROR "Braces after specifying a struct/union require a declaration list" $lineNum
      fi
    else
      if [ $hadIdenOrBrace -eq 0 ]; then
        parseError "Stuct/Union specificying requires an identifier or a declaration list" $lineNum
      else 
        resetToken $nextType "$nextValue" $lineNum
      fi
    fi
  else
    return $NO_MATCH
  fi
}


# Pointer::newNode, Int::tokenType, String::value
function tryEnumeratorList() {
  declare enums
  Stack enums
  declare newNode
  if tryEnumerator newNode "$2" "$3"; then
    declare -n ret=$1

    Stack::shift enums $newNode
    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_ENUMERATOR_LIST

    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    while [ $nextType -eq $T_COMMA ]; do
      nextToken nextType nextValue lineNum
      if tryEnumerator newNode "$nextType" "$nextValue"; then
        Stack::shift enums $newNode
        nextToken nextType nextValue lineNum
      fi
    done
    resetToken "$nextType" "$nextValue" "$lineNum"

    Tree::set node $NODE_VALUE $enums

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryEnumSpecifier() {
  if [ $2 -eq $T_ENUM ]; then
    declare -n ret=$1
    declare node
    Tree node
    Tree::set node $NODE_CLASS $G_ENUM_SPECIFIER


    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    declare newNode
    if tryIdentifier newNode $nextType "$nextValue" $lineNum; then
      Tree::set node $NODE_IDENTIFIER $newNode
      nextToken nextType nextValue lineNum
    fi

    if [ $nextType -eq $T_LBRACE ]; then
      if tryEnumeratorList newNode $nextType "$nextValue"; then
        Tree::set node $NODE_VALUE $newNode
        nextToken nextType nextValue lineNum
        if [ $nextType -eq $T_COMMA ]; then
          nextToken nextType nextValue lineNum
        fi
        if [ $nextType -ne $T_RBRACE ]; then
          parseError "Expected '}' to end enumerator list" "$lineNum"
        fi
      fi
    else
      resetToken "$nextType" "$nextValue" "$lineNum"
    fi
  else
    return $NO_MATCH
  fi
}

function tryTypeDefedTypeSpecifier() {
  #placehoder
  return 0
}

function tryTypeSpecifier() {
  #placehoder
  return 0
}

# Pointer::newNode, Int::tokenType, String::tokenValue
function tryIdentifier() {
  if [ $1 -eq $T_IDENTIFIER ] && ! tryEnumConstant node $2 "$3" && ! tryTypeSpecifier $2 "$3"; then
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::builtNode
function tryPrimaryExpression() {
  #placehoder
  return 0
}


function parseTokens() {
  # Check the scope rules in a second pass to make sure the declaration was in scope
  declare enumConstants
  Stack enumConstants
  declare typeDefs
  Stack typeDefs;
  
}

parseTokens
