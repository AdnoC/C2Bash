#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/constantIds.sh
resetNextId

# Tokens should be assigned in order of priority designated by this list.
declare -ga __TOKEN_LITERAL
declare -ga __TOKEN_CONSTANT
declare -ga __TOKEN_SYMBOL
declare -ga __TOKEN_OPERATOR
declare -ga __TOKEN_KEYWORD

declare -gA TMP=()
# Maps token ids to their names
declare -gA __TOKEN_MAP

# Token IDs are prefixed with 'T_' to differentiate them from other IDs that might share the same name
# Number of tokens (aka current last id#): 102
### Character Literals
setId T_CHARACTER_LITERAL


### Constants
setId T_CHARACTER_CONSTANT
setId T_FLOATING_CONSTANT
setId T_INTEGER_CONSTANT
setId T_STRING_CONSTANT
setId T_WHITESPACE

### Special Symbols
setId T_LBRACE
setId T_LBRACKET
setId T_LPAREN
setId T_RBRACE
setId T_RBRACKET
setId T_RPAREN

setId T_LINE_END
setId T_SEMICOLON
setId T_FUNC_NAME
setId T_COMMENT

### Operators A.K.A. Punctuators (when combined with symbols)
setId T_AMPERSAND
setId T_ANDAND
setId T_AND_ASSIGN
setId T_ARROW
setId T_ASSIGN_OP
setId T_COLON
setId T_COMMA
setId T_DECR
setId T_DIV
setId T_DIV_ASSIGN
setId T_DOT
setId T_EQ
setId T_ER_ASSIGN
setId T_ELLIPSIS
setId T_GT
setId T_GTE
setId T_HASH
setId T_HASHHASH
setId T_HAT
setId T_IDENTIFIER
setId T_TYPEDEFname
setId T_INCR
setId T_LS
setId T_LS_ASSIGN
setId T_LT
setId T_LTE
setId T_MINUS
setId T_MINUS_ASSIGN
setId T_MOD
setId T_MOD_ASSIGN
setId T_MULT_ASSIGN
setId T_NE
setId T_NOT
setId T_OR
setId T_OR_ASSIGN
setId T_OROR
setId T_PLUS
setId T_PLUS_ASSIGN
setId T_QUESTION
setId T_RS
setId T_RS_ASSIGN
setId T_STAR
setId T_TILDA


### Keywords
setId T_AUTO
setId T_BREAK
setId T_CASE
setId T_CHAR
setId T_CONST
setId T_CONTINUE
setId T_DEFAULT
setId T_DO
setId T_DOUBLE
setId T_ELSE
setId T_ENUM
setId T_EXTERN
setId T_FLOAT
setId T_FOR
setId T_GOTO
setId T_IF
setId T_INLINE
setId T_INT
setId T_LONG
setId T_REGISTER
setId T_RESTRICT
setId T_RETURN
setId T_SHORT
setId T_SIGNED
setId T_SIZEOF
setId T_STATIC
setId T_STRUCT
setId T_SWITCH
setId T_TYPEDEF
setId T_UNION
setId T_UNSIGNED
setId T_VOID
setId T_VOLATILE
setId T_WHILE
setId T_BOOL
setId T_COMPLEX
setId T_IMAGINARY

# NOT IMPLEMENTED
setId T_ATOMIC

# Need to include universal character support

TMP["DECIMAL_DIGIT"]='[0-9]'
TMP["OCTAL_DIGIT"]='[0-7]'
TMP["HEXADECIMAL_DIGIT"]='[0-9a-fA-F]'
TMP["SINGLE_LETTER"]='[A-Za-z_$]'
TMP["OPTIONAL_EXPONENT"]="[eE][+-]?${TMP['DECIMAL_DIGIT']}+"
TMP["WHITESPACE"]="[[:space:]]+"
# declare -g __TOKEN_REGEX["SIMPLE_ESCAPE"]="([A-Za-z'\"?#*\\])"
TMP["SIMPLE_ESCAPE"]="([abfnrtv'\"\\?])"
TMP["OCTAL_ESCAPE"]="(${TMP['OCTAL_DIGIT']}{1,3})"
TMP["HEX_ESCAPE"]="([xX]${TMP['HEXADECIMAL_DIGIT']}{1,8})"

TMP["CHARACTER_LITERAL"]="([^\'\\\n]|([\\](${TMP['SIMPLE_ESCAPE']}|${TMP['OCTAL_ESCAPE']}|${TMP['HEX_ESCAPE']})))"
TMP["STRING_LITERAL"]="([^\'\\\n]|([\\](${TMP['SIMPLE_ESCAPE']}|${TMP['OCTAL_ESCAPE']}|${TMP['HEX_ESCAPE']})))"
TMP["SPECIAL_CHARS"]='{}()\[\]'

### Character Literals
__TOKEN_LITERAL[$T_CHARACTER_LITERAL]=$${TMP['CHARACTER_LITERAL']}

### Constants
__TOKEN_CONSTANT[$T_CHARACTER_CONSTANT]="'${TMP['CHARACTER_LITERAL']}'"
__TOKEN_CONSTANT[$T_FLOATING_CONSTANT]="(${TMP['DECIMAL_DIGIT']}*\.${TMP['DECIMAL_DIGIT']}*)|(${TMP['DECIMAL_DIGIT']}*\.${TMP['DECIMAL_DIGIT']}*${TMP['WHITESPACE']}?${TMP['OPTIONAL_EXPONENT']})|(${TMP['DECIMAL_DIGIT']}+${TMP['WHITESPACE']}?${TMP['OPTIONAL_EXPONENT']})"
__TOKEN_CONSTANT[$T_INTEGER_CONSTANT]="(0${TMP['OCTAL_DIGIT']}+)|(0[xX]${TMP['HEXADECIMAL_DIGIT']}+)|(${TMP['DECIMAL_DIGIT']}+)"
__TOKEN_CONSTANT[$T_STRING_CONSTANT]="\"(|${TMP['STRING_LITERAL']}*[^\\])\""
# declare -g __TOKEN_CONSTANT[$T_STRING_CONSTANT]="[^\\]\"${TMP['STRING_LITERAL']}*[^\\]\""
__TOKEN_CONSTANT[$T_WHITESPACE]="${TMP['WHITESPACE']}"

### Special Symbols
__TOKEN_SYMBOL[$T_LBRACE]='(\{|<%)'
__TOKEN_SYMBOL[$T_LBRACKET]='(\[|<:)'
__TOKEN_SYMBOL[$T_LPAREN]='\('
__TOKEN_SYMBOL[$T_RBRACE]='\}'
__TOKEN_SYMBOL[$T_RBRACKET]='(\]|:>)'
__TOKEN_SYMBOL[$T_RPAREN]='(\)|%>)'

__TOKEN_SYMBOL[$T_COMMENT]='\/\/.*$'
__TOKEN_SYMBOL[$T_FUNC_NAME]="__func__"

### Operators A.K.A. Punctuators (when combined with symbols)
__TOKEN_OPERATOR[$T_AMPERSAND]='&'
__TOKEN_OPERATOR[$T_ANDAND]='&&'
__TOKEN_OPERATOR[$T_AND_ASSIGN]='&='
__TOKEN_OPERATOR[$T_ARROW]='->'
__TOKEN_OPERATOR[$T_ASSIGN_OP]='='
__TOKEN_OPERATOR[$T_COLON]=':'
__TOKEN_OPERATOR[$T_COMMA]=','
__TOKEN_OPERATOR[$T_DECR]='--'
__TOKEN_OPERATOR[$T_DIV]='\/'
__TOKEN_OPERATOR[$T_DIV_ASSIGN]='\/='
__TOKEN_OPERATOR[$T_DOT]='\.'
__TOKEN_OPERATOR[$T_EQ]='=='
__TOKEN_OPERATOR[$T_ER_ASSIGN]='\^='
__TOKEN_OPERATOR[$T_ELLIPSIS]='...'
__TOKEN_OPERATOR[$T_GT]='>'
__TOKEN_OPERATOR[$T_GTE]='>='
__TOKEN_OPERATOR[$T_HASH]='(#|%:)'
__TOKEN_OPERATOR[$T_HASHHASH]='##'
__TOKEN_OPERATOR[$T_HAT]='\^'
# Only the first 31 characters of identifiers are significant
__TOKEN_OPERATOR[$T_IDENTIFIER]="(${TMP['SINGLE_LETTER']}|_)(${TMP['SINGLE_LETTER']}|${TMP['DECIMAL_DIGIT']}|_)*"
# declare -g __TOKEN_OPERATOR[$T_TYPEDEFname]="${__TOKEN_OPERATOR['IDENTIFIER']}"
__TOKEN_OPERATOR[$T_INCR]='\+\+'
__TOKEN_OPERATOR[$T_LS]='<<'
__TOKEN_OPERATOR[$T_LS_ASSIGN]='<<='
__TOKEN_OPERATOR[$T_LT]='<'
__TOKEN_OPERATOR[$T_LTE]='<='
__TOKEN_OPERATOR[$T_MINUS]='-'
__TOKEN_OPERATOR[$T_MINUS_ASSIGN]='-='
__TOKEN_OPERATOR[$T_MOD]='%'
__TOKEN_OPERATOR[$T_MOD_ASSIGN]='%='
__TOKEN_OPERATOR[$T_MULT_ASSIGN]='\*='
__TOKEN_OPERATOR[$T_NE]='!='
__TOKEN_OPERATOR[$T_NOT]='!'
__TOKEN_OPERATOR[$T_OR]='\|'
__TOKEN_OPERATOR[$T_OR_ASSIGN]='\|='
__TOKEN_OPERATOR[$T_OROR]='\|\|'
__TOKEN_OPERATOR[$T_PLUS]='\+'
__TOKEN_OPERATOR[$T_PLUS_ASSIGN]='\+='
__TOKEN_OPERATOR[$T_QUESTION]='\?'
__TOKEN_OPERATOR[$T_RS]='>>'
__TOKEN_OPERATOR[$T_RS_ASSIGN]='>>='
__TOKEN_OPERATOR[$T_SEMICOLON]=';'
__TOKEN_OPERATOR[$T_STAR]='\*'
__TOKEN_OPERATOR[$T_TILDA]='~'

### Keywords
__TOKEN_KEYWORD[$T_AUTO]='auto'
__TOKEN_KEYWORD[$T_BREAK]='break'
__TOKEN_KEYWORD[$T_CASE]='case'
__TOKEN_KEYWORD[$T_CHAR]='char'
__TOKEN_KEYWORD[$T_CONST]='const'
__TOKEN_KEYWORD[$T_CONTINUE]='continue'
__TOKEN_KEYWORD[$T_DEFAULT]='default'
__TOKEN_KEYWORD[$T_DO]='do'
__TOKEN_KEYWORD[$T_DOUBLE]='double'
__TOKEN_KEYWORD[$T_ELSE]='else'
__TOKEN_KEYWORD[$T_ENUM]='enum'
__TOKEN_KEYWORD[$T_EXTERN]='extern'
__TOKEN_KEYWORD[$T_FLOAT]='float'
__TOKEN_KEYWORD[$T_FOR]='for'
__TOKEN_KEYWORD[$T_GOTO]='goto'
__TOKEN_KEYWORD[$T_IF]='if'
__TOKEN_KEYWORD[$T_INLINE]='inline'
__TOKEN_KEYWORD[$T_INT]='int'
__TOKEN_KEYWORD[$T_LONG]='long'
__TOKEN_KEYWORD[$T_REGISTER]='register'
__TOKEN_KEYWORD[$T_RESTRICT]='restrict'
__TOKEN_KEYWORD[$T_RETURN]='return'
__TOKEN_KEYWORD[$T_SHORT]='short'
__TOKEN_KEYWORD[$T_SIGNED]='signed'
__TOKEN_KEYWORD[$T_SIZEOF]='sizeof'
__TOKEN_KEYWORD[$T_STATIC]='static'
__TOKEN_KEYWORD[$T_STRUCT]='struct'
__TOKEN_KEYWORD[$T_SWITCH]='switch'
__TOKEN_KEYWORD[$T_TYPEDEF]='typedef'
__TOKEN_KEYWORD[$T_UNION]='union'
__TOKEN_KEYWORD[$T_UNSIGNED]='unsigned'
__TOKEN_KEYWORD[$T_VOID]='void'
__TOKEN_KEYWORD[$T_VOLATILE]='volatile'
__TOKEN_KEYWORD[$T_WHILE]='while'
__TOKEN_KEYWORD[$T_BOOL]='_Bool'
__TOKEN_KEYWORD[$T_COMPLEX]='_Complex'
__TOKEN_KEYWORD[$T_IMAGINARY]='_Imaginary'

# declare temp=$(declare -p T)
# declare -gA __TOKEN_REGEX
# eval "${temp/T=/__TOKEN_REGEX=}"
__TOKEN_MAP[$T_CHARACTER_LITERAL]="CHARACTER_LITERAL"

__TOKEN_MAP[$T_CHARACTER_CONSTANT]="CHARACTER_CONSTANT"
__TOKEN_MAP[$T_FLOATING_CONSTANT]="FLOATING_CONSTANT"
__TOKEN_MAP[$T_INTEGER_CONSTANT]="INTEGER_CONSTANT"
__TOKEN_MAP[$T_STRING_CONSTANT]="STRING_CONSTANT"
__TOKEN_MAP[$T_WHITESPACE]="WHITESPACE"

__TOKEN_MAP[$T_LBRACE]="LBRACE"
__TOKEN_MAP[$T_LBRACKET]="LBRACKET"
__TOKEN_MAP[$T_LPAREN]="LPAREN"
__TOKEN_MAP[$T_RBRACE]="RBRACE"
__TOKEN_MAP[$T_RBRACKET]="RBRACKET"
__TOKEN_MAP[$T_RPAREN]="RPAREN"

__TOKEN_MAP[$T_LINE_END]="LINE_END"
__TOKEN_MAP[$T_SEMICOLON]="SEMICOLON"
__TOKEN_MAP[$T_FUNC_NAME]="FUNC_NAME"
__TOKEN_MAP[$T_COMMENT]="COMMENT"

__TOKEN_MAP[$T_AMPERSAND]="AMPERSAND"
__TOKEN_MAP[$T_ANDAND]="ANDAND"
__TOKEN_MAP[$T_AND_ASSIGN]="AND_ASSIGN"
__TOKEN_MAP[$T_ARROW]="ARROW"
__TOKEN_MAP[$T_ASSIGN_OP]="ASSIGN_OP"
__TOKEN_MAP[$T_COLON]="COLON"
__TOKEN_MAP[$T_COMMA]="COMMA"
__TOKEN_MAP[$T_DECR]="DECR"
__TOKEN_MAP[$T_DIV]="DIV"
__TOKEN_MAP[$T_DIV_ASSIGN]="DIV_ASSIGN"
__TOKEN_MAP[$T_DOT]="DOT"
__TOKEN_MAP[$T_EQ]="EQ"
__TOKEN_MAP[$T_ER_ASSIGN]="ER_ASSIGN"
__TOKEN_MAP[$T_ELLIPSIS]="ELLIPSIS"
__TOKEN_MAP[$T_GT]="GT"
__TOKEN_MAP[$T_GTE]="GTE"
__TOKEN_MAP[$T_HASH]="HASH"
__TOKEN_MAP[$T_HASHHASH]="HASHHASH"
__TOKEN_MAP[$T_HAT]="HAT"
__TOKEN_MAP[$T_IDENTIFIER]="IDENTIFIER"
__TOKEN_MAP[$T_TYPEDEFname]="TYPEDEFname"
__TOKEN_MAP[$T_INCR]="INCR"
__TOKEN_MAP[$T_LS]="LS"
__TOKEN_MAP[$T_LS_ASSIGN]="LS_ASSIGN"
__TOKEN_MAP[$T_LT]="LT"
__TOKEN_MAP[$T_LTE]="LTE"
__TOKEN_MAP[$T_MINUS]="MINUS"
__TOKEN_MAP[$T_MINUS_ASSIGN]="MINUS_ASSIGN"
__TOKEN_MAP[$T_MOD]="MOD"
__TOKEN_MAP[$T_MOD_ASSIGN]="MOD_ASSIGN"
__TOKEN_MAP[$T_MULT_ASSIGN]="MULT_ASSIGN"
__TOKEN_MAP[$T_NE]="NE"
__TOKEN_MAP[$T_NOT]="NOT"
__TOKEN_MAP[$T_OR]="OR"
__TOKEN_MAP[$T_OR_ASSIGN]="OR_ASSIGN"
__TOKEN_MAP[$T_OROR]="OROR"
__TOKEN_MAP[$T_PLUS]="PLUS"
__TOKEN_MAP[$T_PLUS_ASSIGN]="PLUS_ASSIGN"
__TOKEN_MAP[$T_QUESTION]="QUESTION"
__TOKEN_MAP[$T_RS]="RS"
__TOKEN_MAP[$T_RS_ASSIGN]="RS_ASSIGN"
__TOKEN_MAP[$T_STAR]="STAR"
__TOKEN_MAP[$T_TILDA]="TILDA"

__TOKEN_MAP[$T_AUTO]="AUTO"
__TOKEN_MAP[$T_BREAK]="BREAK"
__TOKEN_MAP[$T_CASE]="CASE"
__TOKEN_MAP[$T_CHAR]="CHAR"
__TOKEN_MAP[$T_CONST]="CONST"
__TOKEN_MAP[$T_CONTINUE]="CONTINUE"
__TOKEN_MAP[$T_DEFAULT]="DEFAULT"
__TOKEN_MAP[$T_DO]="DO"
__TOKEN_MAP[$T_DOUBLE]="DOUBLE"
__TOKEN_MAP[$T_ELSE]="ELSE"
__TOKEN_MAP[$T_ENUM]="ENUM"
__TOKEN_MAP[$T_EXTERN]="EXTERN"
__TOKEN_MAP[$T_FLOAT]="FLOAT"
__TOKEN_MAP[$T_FOR]="FOR"
__TOKEN_MAP[$T_GOTO]="GOTO"
__TOKEN_MAP[$T_IF]="IF"
__TOKEN_MAP[$T_INLINE]="INLINE"
__TOKEN_MAP[$T_INT]="INT"
__TOKEN_MAP[$T_LONG]="LONG"
__TOKEN_MAP[$T_REGISTER]="REGISTER"
__TOKEN_MAP[$T_RESTRICT]="RESTRICT"
__TOKEN_MAP[$T_RETURN]="RETURN"
__TOKEN_MAP[$T_SHORT]="SHORT"
__TOKEN_MAP[$T_SIGNED]="SIGNED"
__TOKEN_MAP[$T_SIZEOF]="SIZEOF"
__TOKEN_MAP[$T_STATIC]="STATIC"
__TOKEN_MAP[$T_STRUCT]="STRUCT"
__TOKEN_MAP[$T_SWITCH]="SWITCH"
__TOKEN_MAP[$T_TYPEDEF]="TYPEDEF"
__TOKEN_MAP[$T_UNION]="UNION"
__TOKEN_MAP[$T_UNSIGNED]="UNSIGNED"
__TOKEN_MAP[$T_VOID]="VOID"
__TOKEN_MAP[$T_VOLATILE]="VOLATILE"
__TOKEN_MAP[$T_WHILE]="WHILE"
__TOKEN_MAP[$T_BOOL]="BOOL"
__TOKEN_MAP[$T_COMPLEX]="COMPLEX"
__TOKEN_MAP[$T_IMAGINARY]="IMAGINARY"
