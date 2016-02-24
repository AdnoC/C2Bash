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

# A NOTE ON TYPEDEFS: https://blogs.msdn.microsoft.com/oldnewthing/20130424-00/?p=4563

resetNextId

setId NODE_CLASS
setId NODE_TYPE
setId NODE_VALUE

setId NODE_IDENTIFIER


# All the try* functions return NO_MATCH if there wasn't a match
# They also take a Pointer::newNode as their first argument

function enterScope() {
  declare -n scopes=$scopeStack
  declare newScope
  Queue newScope
  Stack::shift scopes newScope
}
function exitScope() {
  declare -n scopes=$scopeStack
  declare tmp
  Stack::unshift tmp scopes
}

# Pointer::tokenType, Pointer::tokenValue, Pointer::lineNumber, Pointer::stateId, Bool::noSkipWhitespace, Bool::noSkipComment
function nextToken() {
  declare -n ret1=$1
  declare -n ret2=$2
  declare -n ret3=$3
  declare -n retId=$4

  declare stateId
  Stack::length stateId tokenTypes
  retId=$stateId

  declare tType tVal lNum
  Stack::unshift tType tokenTypes
  Stack::unshift tVal tokenValues
  Stack::unshift lNum lineNumbers
  Stack::shift oldTypes $tType
  Stack::shift oldValues "$tVal"
  Stack::shift oldLineNumbers "$lNum"
  while { [ -z "$5" ] && [ $tType -eq $T_WHITESPACE ]; } || { [ -z "$6" ] && [ $tType -eq $T_COMMENT ]; }; do
    Stack::unshift tType tokenTypes
    Stack::unshift tVal tokenValues
    Stack::unshift lNum lineNumbers
    Stack::shift oldTypes $tType
    Stack::shift oldValues "$tVal"
    Stack::shift oldLineNumbers "$lNum"
  done
  ret1=$tType
  ret2=$tVal
  ret3=$lNum
}

# Pointer::tokenType, Pointer::tokenValue, Pointer::lineNumber
function getState() {
  declare -n ret1=$1
  declare -n ret2=$2
  declare -n ret3=$3

  declare tType tVal lNum
  Stack::peek oldTypes tType
  Stack::peek oldValues tVal
  Stack::peek oldLineNumbers lNum

  ret1=$tType
  ret2="$tVal"
  ret3=$lNum
}

# Pointer::stateId
function saveState() {
  declare -n ret=$1
  declare length
  Stack::length length tokenTypes
  ret=$length
}

# Int::stateId
function resetToken() {
  declare tType tVal lNum
  declare length
  Stack::length length tokenTypes
  while [ $1 -lt $length ]; do
    Stack::unshift tType oldTypes
    Stack::unshift tVal oldValues
    Stack::unshift lNum oldLineNumbers
    Stack::shift tokenTypes $tType
    Stack::shift tokenValues "$tVal"
    Stack::shift lineNumbers $lNum

    Stack::length length tokenTypes
  done
  while [ $1 -gt $length ]; do
    Stack::unshift tType tokenTypes
    Stack::unshift tVal tokenValues
    Stack::unshift lNum lineNumbers
    Stack::shift oldTypes $tType
    Stack::shift oldValues "$tVal"
    Stack::shift oldLineNumbers "$lNum"

    Stack::length length tokenTypes
  done
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
    Array node
    Array::set node $NODE_CLASS $G_INTEGER_CONSTANT
    Array::set node $NODE_VALUE $intVal

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
    Array node
    Array::set node $NODE_CLASS $G_FLOAT_CONSTANT
    Array::set node $NODE_VALUE $3

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
    Array node
    Array::set node $NODE_CLASS $G_ENUMERATION_CONSTANT
    Array::set node $NODE_VALUE "$3"

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
    Array node
    Array::set node $NODE_CLASS $G_STRING_LITERAL
    Array::set node $NODE_TYPE $G_FUNC_NAME
    Array::set node $NODE_VALUE "$3"

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
    Array node
    Array::set node $NODE_CLASS $t

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

function tryConstantExpression() {
  #placeholder
  return 0
}


# Pointer::newNode, Int::tokenType, String::value
function tryEnumerator() {
  declare newNode
  if tryIdentifier newNode "$2" "$3"; then
    Stack::shift enumConstants "$3"
    declare -n ret=$1

    declare node
    Array node
    Array::set node $NODE_CLASS $G_ENUMERATOR
    Array::set node $NODE_IDENTIFIER "$3"

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if [ $nextType -eq $T_ASSIGN_OP ]; then
      nextToken nextType nextValue lineNum
      if tryConstantExpression newNode $nextType "$nextValue"; then
        Array::set node $NODE_VALUE "$newNode"
      else
        parseError "Enumerators must be assigned a constant value if they are to be assigned" $lineNum
      fi
    else
      resetToken $stateid
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
    Array node

    Array::set node $NODE_CLASS $G_TYPE_QUALIFIER
    Array::set node $NODE_TYPE $t

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
    Array node
    declare values
    Stack values

    Array::set node $NODE_CLASS $G_SPECIFIER_QUALIFIER_LIST
    Stack::shift values $newNode

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if trySpecifierQualifierList newNode $nextType "$nextValue"; then
      declare otherVals
      Array::get otherVals newNode $NODE_VALUE
      Array::Merge values otherVals
    else
      resetToken $stateId
    fi

    Array::set node $NODE_VALUE $values

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryTypeQualifierList() {
  declare newNode
  if tryTypeQualifier newNode $2 "$3"; then
    declare node values
    Array node
    Stack values

    Array::set node $NODE_CLASS $G_TYPE_QUALIFIER_LIST
    Stack::shift values $newNode

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if tryTypeQualifier newNode $nextType "$nextValue"; then
      declare otherVals
      Array::get otherVals newNode $NODE_VALUE
      Array::merge values otherVals
    else
      resetToken $stateId
    fi

    Array::set node $values 
    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryPointer() {
  if [ $2 -eq $G_STAR ]; then
    declare -n ret=$1
    declare node values newNode
    Array node
    Stack values

    Array::set node $NODE_CLASS $G_POINTER

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if tryTypeQualifierList newNode $nextType "$nextValue"; then
      Stack::shift values $newNode
      nextToken nextType nextValue lineNum stateId
    fi

    if tryPointer newNode $nextType "$nextValue"; then
      Stack::shift values $newNode
    else
      resetToken $stateId
    fi

    Array::set node $NODE_VALUE $values

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryDirectAbstractDeclarator() {
  #placeholder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function tryAbstractDeclarator() {
  declare -n ret=$1
  declare newNode node values
  Array node
  Array::set node $NODE_CLASS $G_ABSTRACT_DECLARATOR
  Stack values
  declare nextType=$2 nextValue="$3" lineNum=$lineNum stateId
  saveState stateId

  if tryPointer newNode $nextType "$nextValue"; then
    Stack::shift values $newNode
    nextToken nextType nextValue lineNum
  fi
  declare len

  if tryDirectAbstractDeclarator newNode $nextType "$nextValue"; then
    Stack::shift values $newNode
  else
    Stack::length len values
    # If we consumed an additional token (due to finding a pointer)
    if [ $len -gt 0 ]; then
      resetToken $stateid
    fi
  fi

  Stack::length len values
  if [ $len -gt 0 ]; then
    Array:set node $NODE_VALUE $values

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryTypeName() {
  declare newNode
  if trySpecifierQualifierList newNode $2 "$3"; then
    declare -n ret=$1

    declare node
    Array node
    Array::set node $NODE_CLASS $G_TYPE_NAME

    declare values
    Stack values
    Stack::shift values "$newNode"

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if tryAbstractDeclarator newNode $nextType "$nextValue"; then
      Stack::shift values $newNode
    else
      resetToken $stateId
    fi

    Array::set node $NODE_VALUE $values

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
        Array node
        Array::set node $NODE_CLASS $G_ATOMIC_TYPE_SPECIFIER
        Array::set node $NODE_VALUE $newNode

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
    Array node
    
    Array::set node $NODE_CLASS $G_STRUCT_OR_UNION
    Array::set node $NODE_TYPE $t

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

function tryStructDeclaration() {
  #placeholder
  return 0
}

function tryStructDeclarationList() {
  declare newNode
  if tryStructDeclaration newNode $2 "$3"; then
    declare node
    Array node
    declare values
    Stack values

    Array::set node $NODE_CLASS $G_STRUCT_DECLARATION_LIST
    Stack::shift values $newNode

    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if tryStructDeclaration newNode $nextType "$nextValue"; then
      declare otherVals
      Array::get otherVals newNode $NODE_VALUE
      Array::Merge values otherVals
    fi

    Array::set node $NODE_VALUE $values

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
    Array node

    declare nType
    Array::get nType newNode $NODE_TYPE

    Array::set node $NODE_CLASS $G_STRUCT_OR_UNION_SPECIFIER
    Array::set node $NODE_TYPE $nType

    declare hadIdenOrBrace=0

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum
    if tryIdentifier newNode $nextType "$nextValue"; then
      hadIdenOrBrace=1
      Array::set node $NODE_IDENTIFIER $newNode
      nextToken nextType nextValue lineNum stateId
    fi

    if [ $nextType -eq $T_LBRACE ]; then
      # hadIdenOrBrace=1
      if tryStructDeclarationList newNode $nextType "$nextValue"; then
        Array::set node $NODE_VALUE $newNode

        nextToken nextType nextValue lineNum
        if [ $nextType -eq $T_RBRACE ]; then
          ret=$node
          return 0
        else
          parseError "Missing '}' after struct declaration list" $lineNum
        fi
      else
        parseError "Braces after specifying a struct/union require a declaration list" $lineNum
      fi
    else
      if [ $hadIdenOrBrace -ne 0 ]; then
        resetToken $stateId
        ret=$node
        return 0
      else
        parseError "Stuct/Union specificying requires an identifier or a declaration list" $lineNum
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
    Array node
    Array::set node $NODE_CLASS $G_ENUMERATOR_LIST

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    while [ $nextType -eq $T_COMMA ]; do
      nextToken nextType nextValue lineNum stateId
      if [ $nextType -eq $T_COMMA ]; then
        parseError "Found two commas where an enumeration constant was expected" $lineNum
      fi

      if tryEnumerator newNode "$nextType" "$nextValue"; then
        Stack::shift enums $newNode
        nextToken nextType nextValue lineNum stateId
      fi
    done
    resetToken $stateId

    Array::set node $NODE_VALUE $enums

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
    Array node
    Array::set node $NODE_CLASS $G_ENUM_SPECIFIER


    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    declare newNode
    if tryIdentifier newNode $nextType "$nextValue" $lineNum; then
      Array::set node $NODE_IDENTIFIER $newNode
      nextToken nextType nextValue lineNum stateId
    fi

    if [ $nextType -eq $T_LBRACE ]; then
      if tryEnumeratorList newNode $nextType "$nextValue"; then
        Array::set node $NODE_VALUE $newNode
        nextToken nextType nextValue lineNum stateId
        if [ $nextType -eq $T_COMMA ]; then
          nextToken nextType nextValue lineNum stateId
        fi
        if [ $nextType -ne $T_RBRACE ]; then
          parseError "Expected '}' to end enumerator list" "$lineNum"
        fi
      fi
    else
      resetToken $stateId
    fi
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryTypeDefNameSpecifier() {
  if [ $2 -eq $T_IDENTIFIER ] && Array::inArray typeDefs "$3"; then
    declare -n ret=$1
    declare node
    Array node

    Array::set node $NODE_CLASS $G_TYPEDEF_NAME
    Array::set node $NODE_VALUE "$3"

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryTypeSpecifier() {
  declare newNode
  if tryBaseTypeSpecifier newNode $2 "$3" || tryAtomicTypeSpecifier newNode $2 "$3" || \
      tryStructUnionTypeSpecifier newNode $2 "$3" || tryEnumSpecifier newNode $2 "$3" || \
      tryTypeDefNameSpecifier newNode $2 "$3"; then
    declare -n ret=$1

    # General wrapper node to combine all the typeSpecifiers under a single node
    declare node
    Array node

    Array::set $NODE_TYPE $G_TYPE_SPECIFIER
    Array::set $NODE_VALUE $newNode

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi

}

function tryInitDeclaratorList() {
  #placeholder
  return 0
}

function tryStaticAssertDeclaration() {
  #placeholder
  return 0
}

function tryDeclarationSpecifiers() {
  #placeholder
  return 0
}
function tryDeclaration() {
  #placeholder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function tryFunctionSpecifier() {
  declare t=0
  case $2 in
    $T_INLINE)
      t=$G_INLINE
      ;;
    $T_NORETURN)
      t=$G_NORETURN
      ;;
    *)
      ;;
  esac

  if [ $t -ne 0 ]; then
    declare -n ret=$1
    declare node
    Array node
    
    Array::set node $NODE_CLASS $G_FUNCTION_SPECIFIER
    Array::set node $NODE_TYPE $t

    ret=$node
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::tokenValue
function tryIdentifier() {
  #placeholder
  if [ $1 -eq $T_IDENTIFIER ] && ! tryEnumConstant node $2 "$3" && ! tryTypeSpecifier $2 "$3"; then
    return 0
  else
    return $NO_MATCH
  fi
}

function tryGenericSelection() {
  #placeholder
  return 0
}

function tryExpression() {
  #placeholder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function tryPostfixExpression() {
  declare newNode
  if tryPrimaryExpression newNode $2 "$3"; then
    echo 'hi'
    #placeholder
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function tryPrimaryExpression() {
  declare newNode
  declare -n ret=$1
  if tryIdentifier newNode $2 "$3" || tryConstant newNode $2 "$3" || tryString newNode $2 "$3" || \
      tryGenericSelection newNode $2 "$3"; then
    ret=$newNode
    return 0
  else
    if [ $2 -eq $T_LPAREN ]; then
      declare nextType nextValue lineNum stateId
      nextToken nextType nextValue lineNum stateId
      if tryExpression newNode $nextType "$nextValue"; then
        nextToken nextType nextValue lineNum stateId
        if [ $nextType -eq $T_RPAREN ]; then
          ret=$newNode
          return 0
        else
          parseError "Expected ')' after primary expression" $lineNum
        fi
      else
        # Not sure if this should actually be an error or we should just reset and return no match
        parseError "Expected expression after '('" $lineNum
        resetToken $stateId
      fi
      
    fi
  fi
  return $NO_MATCH
}

function tryExternalDeclaration() {
  #placeholder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function tryTranslationUnit() {
  declare newNode
  if tryExternalDeclaration newNode $2 "$3"; then
    declare -n ret=$1
    declare node values
    Array node
    Stack values

    Array::set node $NODE_CLASS $G_TRANSLATION_UNIT
    Stack::shift values $newNode

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if tryTranslationUnit newNode $nextType "$nextValue"; then
      declare otherVals
      Array::get otherVals newNode $NODE_VALUE
      Array::merge values otherVals
    else
      resetToken $stateId
    fi

    Array::set node $NODE_VALUE $values
  else
    return $NO_MATCH
  fi
}

function parseTokens() {
  # Check the scope rules in a second pass to make sure the declaration was in scope
  declare scopeStack
  Stack scopeStack
  declare enumConstants
  Stack enumConstants
  declare typeDefs
  Stack typeDefs;

  declare oldTypes oldValues oldLineNumbers
  Stack oldTypes
  Stack oldValues
  Stack oldLineNumbers
  
  declare abstractSyntaxArray
  declare nextType nextValue lineNum
  nextToken nextType nextValue lineNum

  if tryTranslationUnit abstractSyntaxArray $nextType "$nextValue"; then
    echo "Succesfully parsed tokens into AST"
  else
    parseError "Could not parse top-level syntax. You fucked up in one of the first lines." $lineNum
  fi
}

parseTokens
