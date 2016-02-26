#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/return.sh
include "$C2BASH_HOME"/helperlibs/queue.sh
include "$C2BASH_HOME"/helperlibs/char.sh
include "$C2BASH_HOME"/helperlibs/stack.sh
include "$C2BASH_HOME"/helperlibs/array.sh
include "$C2BASH_HOME"/scanner/tokens.sh
include "$C2BASH_HOME"/parser/grammarUnits.sh
include "$C2BASH_HOME"/helperlibs/constantIds.sh
declare -gi NO_MATCH=2314
declare -gi PARSE_ERROR=528
declare -gi FINISHED_TOKENS=9082
# http://www.quut.com/c/ANSI-C-grammar-y.html
# Or Annex A of http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf
# Top level is a translation_unit

# A NOTE ON TYPEDEFS: https://blogs.msdn.microsoft.com/oldnewthing/20130424-00/?p=4563

resetNextId

setId NODE_CLASS
setId NODE_TYPE
setId NODE_VALUE

setId NODE_IDENTIFIER

# All the try * functions return NO_MATCH if there wasn't a match
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
  declare stateId
  Stack::length stateId tokenTypes
  if [ "$stateId" -eq 0 ]; then
    if [ $# -gt 3 ]; then
      @return "" "" "" 0
      return $FINISHED_TOKENS
    else
      @return "" "" ""
      return $FINISHED_TOKENS
    fi
  fi

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

  if [ $# -gt 3 ]; then
    @return "$tType" "$tVal" "$lNum" "$stateId"
    return 0
  else
    @return "$tType" "$tVal" "$lNum"
    return 0
  fi
}

# Pointer::tokenType, Pointer::tokenValue, Pointer::lineNumber
function getState() {
  declare tType tVal lNum
  Stack::peek oldTypes tType
  Stack::peek oldValues tVal
  Stack::peek oldLineNumbers lNum

  @return "$tType" "$tVal" "$lNum"
  return 0
}

# Pointer::stateId
function saveState() {
  declare length
  Stack::length length tokenTypes
  @return "$length"
  return 0
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
  return 0;
}

# String::functionName, ...String::parameters
function try() {
  # declare __stateId
  # saveState __stateId
  declare __function="$1"
  shift
  if ! "$__function" "$@"; then
    # resetToken "$__stateId"
    return $NO_MATCH
  fi
  return 0
}

# String::Error, Int::lineNumber
function parseError() {
  Queue::push parseErrors "$(printf "Parse Error on line %s\n%s\nNote that lines with escaped newline characters are not counted" "$2" "$1")"
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function intConstant() {
  declare t=0
  if [ $2 -eq $T_INTEGER_CONSTANT ] || { [ $2 -eq $T_CHARACTER_CONSTANT ] && t=1; }; then
    declare val=$3
    if [ $t -eq 1 ]; then
      Char::toInt intVal $3
      val=$intVal
    fi

    declare node
    Array node
    Array::set node $NODE_CLASS $G_INTEGER_CONSTANT
    Array::set node $NODE_VALUE $intVal

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function floatConstant() {
  if [ $2 -eq $T_FLOATING_CONSTANT ]; then

    declare node
    Array node
    Array::set node $NODE_CLASS $G_FLOAT_CONSTANT
    Array::set node $NODE_VALUE $3

    @return "$node"
    return 0;
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::tokenValue
function enumConstant() {
  if [ $2 -eq $T_IDENTIFIER ] && Array::inArray enumConstants "$3"; then

    declare node
    Array node
    Array::set node $NODE_CLASS $G_ENUMERATION_CONSTANT
    Array::set node $NODE_VALUE "$3"

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::tokenValue
function constant() {
  if try intConstant node $2 "$3" || try floatConstant node "$2" "$3" || try enumConstant node $2 "$3"; then
    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function string() {
  declare t=0
  if [ $2 -eq $T_STRING_CONSTANT ] || { [ $2 -eq $T_FUNC_NAME ] && t=1; }; then

    declare type=$G_STRING_LITERAL
    if [ $t -eq 1 ]; then
      type=$G_FUNC_NAME
    fi

    declare node
    Array node
    Array::set node $NODE_CLASS $G_STRING_LITERAL
    Array::set node $NODE_TYPE $G_FUNC_NAME
    Array::set node $NODE_VALUE "$3"

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function baseTypeSpecifier() {
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
    declare node
    Array node
    Array::set node $NODE_CLASS $t

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

function constantExpression() {
  #placeholder
  return 0
}


# Pointer::newNode, Int::tokenType, String::value
function enumerator() {
  declare newNode
  if try identifier newNode "$2" "$3"; then
    Stack::shift enumConstants "$3"

    declare node
    Array node
    Array::set node $NODE_CLASS $G_ENUMERATOR
    Array::set node $NODE_IDENTIFIER "$3"

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if [ $nextType -eq $T_ASSIGN_OP ]; then
      nextToken nextType nextValue lineNum
      if try constantExpression newNode $nextType "$nextValue"; then
        Array::set node $NODE_VALUE "$newNode"
      else
        parseError "Enumerators must be assigned a constant value if they are to be assigned" $lineNum
        return $NO_MATCH
      fi
    else
      resetToken $stateid
    fi

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function typeQualifier() {
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
    declare node
    Array node

    Array::set node $NODE_CLASS $G_TYPE_QUALIFIER
    Array::set node $NODE_TYPE $t

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function specifierQualifierList() {
  declare newNode
  if try typeSpecifier newNode $2 "$3" || try typeQualifier newNode $2 "$3"; then
    declare node
    Array node
    declare values
    Stack values

    Array::set node $NODE_CLASS $G_SPECIFIER_QUALIFIER_LIST
    Stack::shift values $newNode

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if try specifierQualifierList newNode $nextType "$nextValue"; then
      declare otherVals
      Array::get otherVals newNode $NODE_VALUE
      Array::Merge values otherVals
    else
      resetToken $stateId
    fi

    Array::set node $NODE_VALUE $values

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function typeQualifierList() {
  declare newNode
  if try typeQualifier newNode $2 "$3"; then
    declare node values
    Array node
    Stack values

    Array::set node $NODE_CLASS $G_TYPE_QUALIFIER_LIST
    Stack::shift values $newNode

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if try typeQualifier newNode $nextType "$nextValue"; then
      declare otherVals
      Array::get otherVals newNode $NODE_VALUE
      Array::merge values otherVals
    else
      resetToken $stateId
    fi

    Array::set node $values 
    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function pointer() {
  if [ $2 -eq $G_STAR ]; then
    declare node values newNode
    Array node
    Stack values

    Array::set node $NODE_CLASS $G_POINTER

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if try typeQualifierList newNode $nextType "$nextValue"; then
      Stack::shift values $newNode
      nextToken nextType nextValue lineNum stateId
    fi

    if try pointer newNode $nextType "$nextValue"; then
      Stack::shift values $newNode
    else
      resetToken $stateId
    fi

    Array::set node $NODE_VALUE $values

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function directAbstractDeclarator() {
  #placeholder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function abstractDeclarator() {
  declare newNode node values
  Array node
  Array::set node $NODE_CLASS $G_ABSTRACT_DECLARATOR
  Stack values
  declare nextType=$2 nextValue="$3" lineNum=$lineNum stateId
  saveState stateId

  if try pointer newNode $nextType "$nextValue"; then
    Stack::shift values $newNode
    nextToken nextType nextValue lineNum
  fi
  declare len

  if try directAbstractDeclarator newNode $nextType "$nextValue"; then
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

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function typeName() {
  declare newNode
  if try specifierQualifierList newNode $2 "$3"; then

    declare node
    Array node
    Array::set node $NODE_CLASS $G_TYPE_NAME

    declare values
    Stack values
    Stack::shift values "$newNode"

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if try abstractDeclarator newNode $nextType "$nextValue"; then
      Stack::shift values $newNode
    else
      resetToken $stateId
    fi

    Array::set node $NODE_VALUE $values

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function atomicTypeSpecifier() {
  if [ $2 -eq $T_ATOMIC ]; then
    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if [ $nextType -eq $T_LPAREN ]; then
      nextToken nextType nextValue lineNum
      declare newNode
      if try typeName newNode $nextType "nextValue"; then

        declare node
        Array node
        Array::set node $NODE_CLASS $G_ATOMIC_TYPE_SPECIFIER
        Array::set node $NODE_VALUE $newNode

        @return "$node"
        return 0
      else
        parseError "Atomic declarations must be followed with a type name" $lineNum
        return $NO_MATCH
      fi
    else
      parseError "Atomic declarations must be followed with a type name in parenthases" $lineNum
      return $NO_MATCH
    fi
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function structOrUnion() {
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
    declare node
    Array node
    
    Array::set node $NODE_CLASS $G_STRUCT_OR_UNION
    Array::set node $NODE_TYPE $t

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

function structDeclaration() {
  #placeholder
  return 0
}

function structDeclarationList() {
  declare newNode
  if try structDeclaration newNode $2 "$3"; then
    declare node
    Array node
    declare values
    Stack values

    Array::set node $NODE_CLASS $G_STRUCT_DECLARATION_LIST
    Stack::shift values $newNode

    declare nextType nextValue lineNum
    nextToken nextType nextValue lineNum
    if try structDeclaration newNode $nextType "$nextValue"; then
      declare otherVals
      Array::get otherVals newNode $NODE_VALUE
      Array::Merge values otherVals
    fi

    Array::set node $NODE_VALUE $values

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function structUnionTypeSpecifier() {
  declare newNode
  if try structOrUnion newNode $2 "$3"; then
    declare node
    Array node

    declare nType
    Array::get nType newNode $NODE_TYPE

    Array::set node $NODE_CLASS $G_STRUCT_OR_UNION_SPECIFIER
    Array::set node $NODE_TYPE $nType

    declare hadIdenOrBrace=0

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum
    if try identifier newNode $nextType "$nextValue"; then
      hadIdenOrBrace=1
      Array::set node $NODE_IDENTIFIER $newNode
      nextToken nextType nextValue lineNum stateId
    fi

    if [ $nextType -eq $T_LBRACE ]; then
      # hadIdenOrBrace=1
      if try structDeclarationList newNode $nextType "$nextValue"; then
        Array::set node $NODE_VALUE $newNode

        nextToken nextType nextValue lineNum
        if [ $nextType -eq $T_RBRACE ]; then
          @return "$node"
          return 0
        else
          parseError "Missing '}' after struct declaration list" $lineNum
          return $NO_MATCH
        fi
      else
        parseError "Braces after specifying a struct/union require a declaration list" $lineNum
        return $NO_MATCH
      fi
    else
      if [ $hadIdenOrBrace -ne 0 ]; then
        resetToken $stateId
        @return "$node"
        return 0
      else
        parseError "Stuct/Union specificying requires an identifier or a declaration list" $lineNum
        return $NO_MATCH
      fi
    fi
  else
    return $NO_MATCH
  fi
}


# Pointer::newNode, Int::tokenType, String::value
function enumeratorList() {
  declare enums
  Stack enums
  declare newNode
  if try enumerator newNode "$2" "$3"; then

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
        return $NO_MATCH
      fi

      if try enumerator newNode "$nextType" "$nextValue"; then
        Stack::shift enums $newNode
        nextToken nextType nextValue lineNum stateId
      fi
    done
    resetToken $stateId

    Array::set node $NODE_VALUE $enums

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function enumSpecifier() {
  if [ $2 -eq $T_ENUM ]; then
    declare node
    Array node
    Array::set node $NODE_CLASS $G_ENUM_SPECIFIER


    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    declare newNode
    if try identifier newNode $nextType "$nextValue" $lineNum; then
      Array::set node $NODE_IDENTIFIER $newNode
      nextToken nextType nextValue lineNum stateId
    fi

    if [ $nextType -eq $T_LBRACE ]; then
      if try enumeratorList newNode $nextType "$nextValue"; then
        Array::set node $NODE_VALUE $newNode
        nextToken nextType nextValue lineNum stateId
        if [ $nextType -eq $T_COMMA ]; then
          nextToken nextType nextValue lineNum stateId
        fi
        if [ $nextType -ne $T_RBRACE ]; then
          parseError "Expected '}' to end enumerator list" "$lineNum"
          return $NO_MATCH
        fi
      fi
    else
      resetToken $stateId
    fi

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function typeDefNameSpecifier() {
  if [ $2 -eq $T_IDENTIFIER ] && Array::inArray typeDefs "$3"; then
    declare node
    Array node

    Array::set node $NODE_CLASS $G_TYPEDEF_NAME
    Array::set node $NODE_VALUE "$3"

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function typeSpecifier() {
  declare newNode
  if try baseTypeSpecifier newNode $2 "$3" || try atomicTypeSpecifier newNode $2 "$3" || \
      try structUnionTypeSpecifier newNode $2 "$3" || try enumSpecifier newNode $2 "$3" || \
      try typeDefNameSpecifier newNode $2 "$3"; then

    # General wrapper node to combine all the typeSpecifiers under a single node
    declare node
    Array node

    Array::set $NODE_TYPE $G_TYPE_SPECIFIER
    Array::set $NODE_VALUE $newNode

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi

}

function initDeclaratorList() {
  #placeholder
  return 0
}

function staticAssertDeclaration() {
  #placeholder
  return 0
}

function declarationSpecifiers() {
  #placeholder
  return 0
}
function declaration() {
  #placeholder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function functionSpecifier() {
echo "functionSpecifier"
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
    declare node
    Array node
    
    Array::set node $NODE_CLASS $G_FUNCTION_SPECIFIER
    Array::set node $NODE_TYPE $t

    @return "$node"
    return 0
  else
    return $NO_MATCH
  fi
}

# Pointer::newNode, Int::tokenType, String::tokenValue
function identifier() {
echo "identifier"
  #placeholder
  if [ $1 -eq $T_IDENTIFIER ] && ! try enumConstant node $2 "$3" && ! try typeSpecifier $2 "$3"; then
    return 0
  else
    return $NO_MATCH
  fi
}

function genericSelection() {
  #placeholder
  return 0
}

function expression() {
  #placeholder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function postfixExpression() {
echo "postfixExpression"
  declare newNode
  if try primaryExpression newNode $2 "$3"; then
    echo 'hi'
    #placeholder
  fi
}

# Pointer::newNode, Int::tokenType, String::value
function primaryExpression() {
echo "primaryExpression"
  declare newNode
  if try identifier newNode $2 "$3" || try constant newNode $2 "$3" || try string newNode $2 "$3" || \
      try genericSelection newNode $2 "$3"; then
    @return "$newNode"
    return 0
  else
    if [ $2 -eq $T_LPAREN ]; then
      declare nextType nextValue lineNum stateId
      nextToken nextType nextValue lineNum stateId
      if try expression newNode $nextType "$nextValue"; then
        nextToken nextType nextValue lineNum stateId
        if [ $nextType -eq $T_RPAREN ]; then
          @return "$newNode"
          return 0
        else
          parseError "Expected ')' after primary expression" $lineNum
          return $NO_MATCH
        fi
      else
        # Not sure if this should actually be an error or we should just reset and return no match
        parseError "Expected expression after '('" $lineNum
        return $NO_MATCH
      fi
      
    fi
  fi
  return $NO_MATCH
}

function externalDeclaration() {
declare len

if Queue::length len tokenTypes && [ $len -eq 0 ]; then
  return 0
else
  return $NO_MATCH
fi
  #placeholder
  return 0
}

# Pointer::newNode, Int::tokenType, String::value
function translationUnit() {
echo "transUnit"
  declare newNode
  if try externalDeclaration newNode $2 "$3"; then
    declare node values
    Array node
    Stack values

    Array::set node $NODE_CLASS $G_TRANSLATION_UNIT
    Stack::shift values $newNode

    declare nextType nextValue lineNum stateId
    nextToken nextType nextValue lineNum stateId
    if try translationUnit newNode $nextType "$nextValue"; then
      declare otherVals
      Array::get otherVals newNode $NODE_VALUE
      Array::merge values otherVals
    else
      resetToken $stateId
    fi

    Array::set node $NODE_VALUE $values
    @return "$node"
    return 0
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
  declare parseErrors
  Queue parseErrors

  declare oldTypes oldValues oldLineNumbers
  Stack oldTypes
  Stack oldValues
  Stack oldLineNumbers
  
  declare abstractSyntaxArray
  declare nextType nextValue lineNum
  nextToken nextType nextValue lineNum

  if try translationUnit abstractSyntaxArray $nextType "$nextValue"; then
    echo "Succesfully parsed tokens into AST"
  else
    parseError "Could not parse top-level syntax." $lineNum
    echo "ELSE"
    echo "${__queue3Values[@]}"
    declare iter
    Array::iterationString iter parseErrors
    declare it
    for it in "${!iter}"; do
      >&2 printf "\n%s" "$it"
    done
  fi
}

if [ "${#FUNCNAME[@]}" -eq "0" ]; then
  parseTokens
fi
