#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/constantIds.sh
resetNextId

declare -gA __TOKEN_MAP

setId G_PRIMARY_EXPRESSION
setId G_IDENTIFIER
setId G_CONSTANT
setId G_INTEGER_CONSTANT
setId G_FLOAT_CONSTANT
setId G_ENUMERATION_CONSTANT
setId G_STRING
setId G_STRING_LITERAL
setId G_FUNC_NAME
setId G_EXPRESSION
setId G_ASSIGNMENT_EXPRESSION
setId G_CONDITIONAL_EXPRESSION
setId G_LOGICAL_OR_EXPRESSION
setId G_LOGICAL_AND_EXPRESSION
setId G_INCLUSIVE_OR_EXPRESSION
setId G_EXCLUSIVE_OR_EXPRESSION
setId G_AND_EXPRESSION
setId G_EQUALITY_EXPRESSION
setId G_RELATIONAL_EXPRESSION
setId G_SHIFT_EXPRESSION
setId G_ADDITIVE_EXPRESSION
setId G_MULTIPLICATIVE_EXPRESSION
setId G_CAST_EXPRESSION
setId G_UNARY_EXPRESSION
setId G_POSTFIX_EXPRESSION
setId G_PRIMARY_EXPRESSION
setId G_ARGUMENT_EXPRESSION_LIST
setId G_PTR_OP
setId G_INC_OP
setId G_DEC_OP
setId G_TYPE_NAME
setId G_SPECIFIER_QUALIFIER_LIST
setId G_TYPE_SPECIFIER
setId G_VOID
setId G_CHAR
setId G_SHORT
setId G_INT
setId G_LONG
setId G_FLOAT
setId G_DOUBLE
setId G_SIGNED
setId G_UNSIGNED
setId G_BOOL
setId G_COMPLEX
setId G_IMAGINARY
setId G_ATOMIC_TYPE_SPECIFIER
# May not need this one
setId G_ATOMIC
setId G_STRUCT_OR_UNION_SPECIFIER
setId G_STRUCT_OR_UNION
setId G_STRUCT
setId G_UNION
setId G_STRUCT_DECLARATION_LIST
setId G_STRUCT_DECLARATION
setId G_STRUCT_DECLARATOR_LIST
setId G_STRUCT_DECLARATOR
# Needs to only have constants. Might have to be done in the second pass
setId G_CONSTANT_EXPRESSION
setId G_DECLARATOR
setId G_POINTER
setId G_TYPE_QUALIFIER_LIST
setId G_TYPE_QUALIFIER
setId G_CONST
setId G_RESTRICT
setId G_VOLATILE
setId G_ATOMIC
setId G_DIRECT_DECLARATOR
setId G_STATIC
setId G_PARAMETER_TYPE_LIST
setId G_ELLIPSIS
setId G_PARAMETER_LIST
setId G_PARAMETER_DECLARATION
setId G_DECLARATION_SPECIFIERS
setId G_STORAGE_CLASS_SPECIFIER
setId G_TYPEDEF
setId G_EXTERN
setId G_STATIC
setId G_THREAD_LOCAL
setId G_AUTO
setId G_REGISTER
setId G_FUNCTION_SPECIFIER
setId G_INLINE
setId G_NORETURN
setId G_ALIGNMENT_SPECIFIER
setId G_ALIGNAS
setId G_ABSTRACT_DECLARATOR
setId G_DIRECT_ABSTRACT_DECLARATOR
setId G_IDENTIFIER_LIST
setId G_STATIC_ASSERT_DECLARATION
setId G_STATIC_ASSERT
setId G_ENUM_SPECIFIER
setId G_ENUM
setId G_ENUMERATOR_LIST
setId G_ENUMERATOR
setId G_INITIALIZER_LIST
setId G_DESIGNATION
setId G_DESIGNATOR_LIST
setId G_DESIGNATOR
setId G_INITIALIZER
setId G_UNARY_OPERATOR
setId G_AND
setId G_STAR
setId G_PLUS
setId G_MINUS
setId G_TILDA
setId G_BANG
setId G_SIZEOF
setId G_ALIGNOF
setId G_LEFT_OP
setId G_RIGHT_OP
setId G_LESS_THAN
setId G_GREATER_THAN
setId LE_OP
setId GE_OP
setId G_ASSIGNMENT_OPERATOR
setId G_ASSIGN
setId G_MUL_ASSIGN
setId G_DIV_ASSIGN
setId G_MOD_ASSIGN
setId G_ADD_ASSIGN
setId G_SUB_ASSIGN
setId G_LEFT_ASSIGN
setId G_RIGHT_ASSIGN
setId G_XOR_ASSIGN
setId G_OR_ASSIGN
setId G_ARRAY_ACCESS
setId G_DOT_ACCESS
setId G_FUNC_CALL
#'(' type_name ')' '{' initializer_list '}'
setId G_MULTIPLY
setId G_DIVIDE
setId G_MOD
setId G_ADD
setId G_SUBTRACT
setId G_EQ_OP
setId G_NE_OP
setId G_AND_OP
setId G_OR_OP
# This is the top-level of the tree
setId G_TRANSLATION_UNIT
setId G_EXTERNAL_DECLARATION
setId G_FUNCTION_DEFINITION
setId G_COMPOUND_STATEMENT
setId G_BLOCK_ITEM_LIST
setId G_BLOCK_ITEM
setId G_STATEMENT
# stuff like labels, case
setId G_LABELED_STATEMENT
setId G_CASE
setId G_DEFAULT
setId G_EXPRESSION_STATEMENT
setId G_SELECTION_STATEMENT
setId G_IF
setId G_ELSE
setId G_SWITCH
setId G_ITERATION_STATEMENT
setId G_WHILE
setId G_DO
setId G_FOR
setId G_JUMP_STATEMENT
setId G_GOTO
setId G_CONTINUE
setId G_BREAK
setId G_RETURN
setId G_DECLARATION_LIST
setId G_DECLARATION
setId G_INIT_DECLARATION_LIST
setId G_INIT_DECLARATOR


__GRAMMAR_MAP[$G_PRIMARY_EXPRESSION]="G_PRIMARY_EXPRESSION"
__GRAMMAR_MAP[$G_IDENTIFIER]="G_IDENTIFIER"
__GRAMMAR_MAP[$G_CONSTANT]="G_CONSTANT"
__GRAMMAR_MAP[$G_INTEGER_CONSTANT]="G_INTEGER_CONSTANT"
__GRAMMAR_MAP[$G_FLOAT_CONSTANT]="G_FLOAT_CONSTANT"
__GRAMMAR_MAP[$G_ENUMERATION_CONSTANT]="G_ENUMERATION_CONSTANT"
__GRAMMAR_MAP[$G_STRING]="G_STRING"
__GRAMMAR_MAP[$G_STRING_LITERAL]="G_STRING_LITERAL"
__GRAMMAR_MAP[$G_FUNC_NAME]="G_FUNC_NAME"
__GRAMMAR_MAP[$G_EXPRESSION]="G_EXPRESSION"
__GRAMMAR_MAP[$G_ASSIGNMENT_EXPRESSION]="G_ASSIGNMENT_EXPRESSION"
__GRAMMAR_MAP[$G_CONDITIONAL_EXPRESSION]="G_CONDITIONAL_EXPRESSION"
__GRAMMAR_MAP[$G_LOGICAL_OR_EXPRESSION]="G_LOGICAL_OR_EXPRESSION"
__GRAMMAR_MAP[$G_LOGICAL_AND_EXPRESSION]="G_LOGICAL_AND_EXPRESSION"
__GRAMMAR_MAP[$G_INCLUSIVE_OR_EXPRESSION]="G_INCLUSIVE_OR_EXPRESSION"
__GRAMMAR_MAP[$G_EXCLUSIVE_OR_EXPRESSION]="G_EXCLUSIVE_OR_EXPRESSION"
__GRAMMAR_MAP[$G_AND_EXPRESSION]="G_AND_EXPRESSION"
__GRAMMAR_MAP[$G_EQUALITY_EXPRESSION]="G_EQUALITY_EXPRESSION"
__GRAMMAR_MAP[$G_RELATIONAL_EXPRESSION]="G_RELATIONAL_EXPRESSION"
__GRAMMAR_MAP[$G_SHIFT_EXPRESSION]="G_SHIFT_EXPRESSION"
__GRAMMAR_MAP[$G_ADDITIVE_EXPRESSION]="G_ADDITIVE_EXPRESSION"
__GRAMMAR_MAP[$G_MULTIPLICATIVE_EXPRESSION]="G_MULTIPLICATIVE_EXPRESSION"
__GRAMMAR_MAP[$G_CAST_EXPRESSION]="G_CAST_EXPRESSION"
__GRAMMAR_MAP[$G_UNARY_EXPRESSION]="G_UNARY_EXPRESSION"
__GRAMMAR_MAP[$G_POSTFIX_EXPRESSION]="G_POSTFIX_EXPRESSION"
__GRAMMAR_MAP[$G_PRIMARY_EXPRESSION]="G_PRIMARY_EXPRESSION"
__GRAMMAR_MAP[$G_ARGUMENT_EXPRESSION_LIST]="G_ARGUMENT_EXPRESSION_LIST"
__GRAMMAR_MAP[$G_PTR_OP]="G_PTR_OP"
__GRAMMAR_MAP[$G_INC_OP]="G_INC_OP"
__GRAMMAR_MAP[$G_DEC_OP]="G_DEC_OP"
__GRAMMAR_MAP[$G_TYPE_NAME]="G_TYPE_NAME"
__GRAMMAR_MAP[$G_SPECIFIER_QUALIFIER_LIST]="G_SPECIFIER_QUALIFIER_LIST"
__GRAMMAR_MAP[$G_TYPE_SPECIFIER]="G_TYPE_SPECIFIER"
__GRAMMAR_MAP[$G_VOID]="G_VOID"
__GRAMMAR_MAP[$G_CHAR]="G_CHAR"
__GRAMMAR_MAP[$G_SHORT]="G_SHORT"
__GRAMMAR_MAP[$G_INT]="G_INT"
__GRAMMAR_MAP[$G_LONG]="G_LONG"
__GRAMMAR_MAP[$G_FLOAT]="G_FLOAT"
__GRAMMAR_MAP[$G_DOUBLE]="G_DOUBLE"
__GRAMMAR_MAP[$G_SIGNED]="G_SIGNED"
__GRAMMAR_MAP[$G_UNSIGNED]="G_UNSIGNED"
__GRAMMAR_MAP[$G_BOOL]="G_BOOL"
__GRAMMAR_MAP[$G_COMPLEX]="G_COMPLEX"
__GRAMMAR_MAP[$G_IMAGINARY]="G_IMAGINARY"
__GRAMMAR_MAP[$G_ATOMIC_TYPE_SPECIFIER]="G_ATOMIC_TYPE_SPECIFIER"
__GRAMMAR_MAP[$G_ATOMIC]="G_ATOMIC"
__GRAMMAR_MAP[$G_STRUCT_OR_UNION_SPECIFIER]="G_STRUCT_OR_UNION_SPECIFIER"
__GRAMMAR_MAP[$G_STRUCT_OR_UNION]="G_STRUCT_OR_UNION"
__GRAMMAR_MAP[$G_STRUCT]="G_STRUCT"
__GRAMMAR_MAP[$G_UNION]="G_UNION"
__GRAMMAR_MAP[$G_STRUCT_DECLARATION_LIST]="G_STRUCT_DECLARATION_LIST"
__GRAMMAR_MAP[$G_STRUCT_DECLARATION]="G_STRUCT_DECLARATION"
__GRAMMAR_MAP[$G_STRUCT_DECLARATOR_LIST]="G_STRUCT_DECLARATOR_LIST"
__GRAMMAR_MAP[$G_STRUCT_DECLARATOR]="G_STRUCT_DECLARATOR"
__GRAMMAR_MAP[$G_CONSTANT_EXPRESSION]="G_CONSTANT_EXPRESSION"
__GRAMMAR_MAP[$G_DECLARATOR]="G_DECLARATOR"
__GRAMMAR_MAP[$G_POINTER]="G_POINTER"
__GRAMMAR_MAP[$G_TYPE_QUALIFIER_LIST]="G_TYPE_QUALIFIER_LIST"
__GRAMMAR_MAP[$G_TYPE_QUALIFIER]="G_TYPE_QUALIFIER"
__GRAMMAR_MAP[$G_CONST]="G_CONST"
__GRAMMAR_MAP[$G_RESTRICT]="G_RESTRICT"
__GRAMMAR_MAP[$G_VOLATILE]="G_VOLATILE"
__GRAMMAR_MAP[$G_ATOMIC]="G_ATOMIC"
__GRAMMAR_MAP[$G_DIRECT_DECLARATOR]="G_DIRECT_DECLARATOR"
__GRAMMAR_MAP[$G_STATIC]="G_STATIC"
__GRAMMAR_MAP[$G_PARAMETER_TYPE_LIST]="G_PARAMETER_TYPE_LIST"
__GRAMMAR_MAP[$G_ELLIPSIS]="G_ELLIPSIS"
__GRAMMAR_MAP[$G_PARAMETER_LIST]="G_PARAMETER_LIST"
__GRAMMAR_MAP[$G_PARAMETER_DECLARATION]="G_PARAMETER_DECLARATION"
__GRAMMAR_MAP[$G_DECLARATION_SPECIFIERS]="G_DECLARATION_SPECIFIERS"
__GRAMMAR_MAP[$G_STORAGE_CLASS_SPECIFIER]="G_STORAGE_CLASS_SPECIFIER"
__GRAMMAR_MAP[$G_TYPEDEF]="G_TYPEDEF"
__GRAMMAR_MAP[$G_EXTERN]="G_EXTERN"
__GRAMMAR_MAP[$G_STATIC]="G_STATIC"
__GRAMMAR_MAP[$G_THREAD_LOCAL]="G_THREAD_LOCAL"
__GRAMMAR_MAP[$G_AUTO]="G_AUTO"
__GRAMMAR_MAP[$G_REGISTER]="G_REGISTER"
__GRAMMAR_MAP[$G_FUNCTION_SPECIFIER]="G_FUNCTION_SPECIFIER"
__GRAMMAR_MAP[$G_INLINE]="G_INLINE"
__GRAMMAR_MAP[$G_NORETURN]="G_NORETURN"
__GRAMMAR_MAP[$G_ALIGNMENT_SPECIFIER]="G_ALIGNMENT_SPECIFIER"
__GRAMMAR_MAP[$G_ALIGNAS]="G_ALIGNAS"
__GRAMMAR_MAP[$G_ABSTRACT_DECLARATOR]="G_ABSTRACT_DECLARATOR"
__GRAMMAR_MAP[$G_DIRECT_ABSTRACT_DECLARATOR]="G_DIRECT_ABSTRACT_DECLARATOR"
__GRAMMAR_MAP[$G_IDENTIFIER_LIST]="G_IDENTIFIER_LIST"
__GRAMMAR_MAP[$G_STATIC_ASSERT_DECLARATION]="G_STATIC_ASSERT_DECLARATION"
__GRAMMAR_MAP[$G_STATIC_ASSERT]="G_STATIC_ASSERT"
__GRAMMAR_MAP[$G_ENUM_SPECIFIER]="G_ENUM_SPECIFIER"
__GRAMMAR_MAP[$G_ENUM]="G_ENUM"
__GRAMMAR_MAP[$G_ENUMERATOR_LIST]="G_ENUMERATOR_LIST"
__GRAMMAR_MAP[$G_ENUMERATOR]="G_ENUMERATOR"
__GRAMMAR_MAP[$G_INITIALIZER_LIST]="G_INITIALIZER_LIST"
__GRAMMAR_MAP[$G_DESIGNATION]="G_DESIGNATION"
__GRAMMAR_MAP[$G_DESIGNATOR_LIST]="G_DESIGNATOR_LIST"
__GRAMMAR_MAP[$G_DESIGNATOR]="G_DESIGNATOR"
__GRAMMAR_MAP[$G_INITIALIZER]="G_INITIALIZER"
__GRAMMAR_MAP[$G_UNARY_OPERATOR]="G_UNARY_OPERATOR"
__GRAMMAR_MAP[$G_AND]="G_AND"
__GRAMMAR_MAP[$G_STAR]="G_STAR"
__GRAMMAR_MAP[$G_PLUS]="G_PLUS"
__GRAMMAR_MAP[$G_MINUS]="G_MINUS"
__GRAMMAR_MAP[$G_TILDA]="G_TILDA"
__GRAMMAR_MAP[$G_BANG]="G_BANG"
__GRAMMAR_MAP[$G_SIZEOF]="G_SIZEOF"
__GRAMMAR_MAP[$G_ALIGNOF]="G_ALIGNOF"
__GRAMMAR_MAP[$G_LEFT_OP]="G_LEFT_OP"
__GRAMMAR_MAP[$G_RIGHT_OP]="G_RIGHT_OP"
__GRAMMAR_MAP[$G_LESS_THAN]="G_LESS_THAN"
__GRAMMAR_MAP[$G_GREATER_THAN]="G_GREATER_THAN"
__GRAMMAR_MAP[$LE_OP]="LE_OP"
__GRAMMAR_MAP[$GE_OP]="GE_OP"
__GRAMMAR_MAP[$G_ASSIGNMENT_OPERATOR]="G_ASSIGNMENT_OPERATOR"
__GRAMMAR_MAP[$G_ASSIGN]="G_ASSIGN"
__GRAMMAR_MAP[$G_MUL_ASSIGN]="G_MUL_ASSIGN"
__GRAMMAR_MAP[$G_DIV_ASSIGN]="G_DIV_ASSIGN"
__GRAMMAR_MAP[$G_MOD_ASSIGN]="G_MOD_ASSIGN"
__GRAMMAR_MAP[$G_ADD_ASSIGN]="G_ADD_ASSIGN"
__GRAMMAR_MAP[$G_SUB_ASSIGN]="G_SUB_ASSIGN"
__GRAMMAR_MAP[$G_LEFT_ASSIGN]="G_LEFT_ASSIGN"
__GRAMMAR_MAP[$G_RIGHT_ASSIGN]="G_RIGHT_ASSIGN"
__GRAMMAR_MAP[$G_XOR_ASSIGN]="G_XOR_ASSIGN"
__GRAMMAR_MAP[$G_OR_ASSIGN]="G_OR_ASSIGN"
__GRAMMAR_MAP[$G_ARRAY_ACCESS]="G_ARRAY_ACCESS"
__GRAMMAR_MAP[$G_DOT_ACCESS]="G_DOT_ACCESS"
__GRAMMAR_MAP[$G_FUNC_CALL]="G_FUNC_CALL"
__GRAMMAR_MAP[$G_MULTIPLY]="G_MULTIPLY"
__GRAMMAR_MAP[$G_DIVIDE]="G_DIVIDE"
__GRAMMAR_MAP[$G_MOD]="G_MOD"
__GRAMMAR_MAP[$G_ADD]="G_ADD"
__GRAMMAR_MAP[$G_SUBTRACT]="G_SUBTRACT"
__GRAMMAR_MAP[$G_EQ_OP]="G_EQ_OP"
__GRAMMAR_MAP[$G_NE_OP]="G_NE_OP"
__GRAMMAR_MAP[$G_AND_OP]="G_AND_OP"
__GRAMMAR_MAP[$G_OR_OP]="G_OR_OP"
__GRAMMAR_MAP[$G_TRANSLATION_UNIT]="G_TRANSLATION_UNIT"
__GRAMMAR_MAP[$G_EXTERNAL_DECLARATION]="G_EXTERNAL_DECLARATION"
__GRAMMAR_MAP[$G_FUNCTION_DEFINITION]="G_FUNCTION_DEFINITION"
__GRAMMAR_MAP[$G_COMPOUND_STATEMENT]="G_COMPOUND_STATEMENT"
__GRAMMAR_MAP[$G_BLOCK_ITEM_LIST]="G_BLOCK_ITEM_LIST"
__GRAMMAR_MAP[$G_BLOCK_ITEM]="G_BLOCK_ITEM"
__GRAMMAR_MAP[$G_STATEMENT]="G_STATEMENT"
__GRAMMAR_MAP[$G_LABELED_STATEMENT]="G_LABELED_STATEMENT"
__GRAMMAR_MAP[$G_LABELED_STATEMENT]="G_LABELED_STATEMENT"
__GRAMMAR_MAP[$G_CASE]="G_CASE"
__GRAMMAR_MAP[$G_DEFAULT]="G_DEFAULT"
__GRAMMAR_MAP[$G_EXPRESSION_STATEMENT]="G_EXPRESSION_STATEMENT"
__GRAMMAR_MAP[$G_SELECTION_STATEMENT]="G_SELECTION_STATEMENT"
__GRAMMAR_MAP[$G_IF]="G_IF"
__GRAMMAR_MAP[$G_ELSE]="G_ELSE"
__GRAMMAR_MAP[$G_SWITCH]="G_SWITCH"
__GRAMMAR_MAP[$G_ITERATION_STATEMENT]="G_ITERATION_STATEMENT"
__GRAMMAR_MAP[$G_WHILE]="G_WHILE"
__GRAMMAR_MAP[$G_DO]="G_DO"
__GRAMMAR_MAP[$G_FOR]="G_FOR"
__GRAMMAR_MAP[$G_JUMP_STATEMENT]="G_JUMP_STATEMENT"
__GRAMMAR_MAP[$G_GOTO]="G_GOTO"
__GRAMMAR_MAP[$G_CONTINUE]="G_CONTINUE"
__GRAMMAR_MAP[$G_BREAK]="G_BREAK"
__GRAMMAR_MAP[$G_RETURN]="G_RETURN"
__GRAMMAR_MAP[$G_DECLARATION_LIST]="G_DECLARATION_LIST"
__GRAMMAR_MAP[$G_DECLARATION]="G_DECLARATION"
__GRAMMAR_MAP[$G_INIT_DECLARATION_LIST]="G_INIT_DECLARATION_LIST"
__GRAMMAR_MAP[$G_INIT_DECLARATOR]="G_INIT_DECLARATOR"
