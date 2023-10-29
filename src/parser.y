%skeleton "lalr1.cc"
%require "3.8.1"
%header 

%define api.token.raw

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%language "C++" 

%code requires{
#include <iostream>
namespace tabulate
{
    class driver;
}
#include "tabulate/types.hh"
}

// The parsing context
%param { tabulate::driver& drv }

%locations

%define parse.trace
%define parse.error detailed
%define parse.lac full

%code {
#include "tabulate.hh"
}

// reserved keywords
%token
    CLASS "class"
    IF "if"
    ELSE "else"
    VOID "void"
    WHILE "while"
    FUN "fun"
    RETURN "return"
    RETURNS "returns"
    BREAK "break"
    CONTINUE "continue"

// punctuators
%token  
    EQUAL "=" 
    COLON ":" 
    SEMICOLON ";"
    DOT "." 
    COMMA ","
    OPEN_SQUARE_BRAC "[" 
    CLOSE_SQUARE_BRAC "]"
    OPEN_CURLY "{"
    CLOSE_CURLY "}"
    OPEN_PARENTHESIS "("
    CLOSE_PARENTHESIS ")"

// identifiers
%token
    <std::string> ID "identifier"

// operators
%left
    <std::string> BIOP "binary operator"
%right
    <std::string> UNIOP "unary operator"

// constant
%token
    <int> INT "integer"
    <std::string> STRING "string"
    <bool> BOOL "boolean"
    <double> DOUBLE "double"
    <tabulate::date> DATE "date"
    <tabulate::time> TIME "time"

%nterm <int> program

%%
// start symbol
%start S;

// Write grammar rules below

S: 
    program {
        drv.result = $1 ;
    }
    ;

program:
    INT program {
        $$ = $1 + $2 ;
    }
    |
    INT {
        $$ = $1 ;
    }

//type constants
constant: INT | STRING | BOOL | DOUBLE | DATE | TIME ;

//expressions & operators
expression:
    ID
    | UNIOP expression
    | expression BIOP expression
    | OPEN_PARENTHESIS expression CLOSE_PARENTHESIS
    ;

//declaration & assignment
declaration_stmt: declaration SEMICOLON ;
declaration: constant variable_list ;
variable_list: ID
             | ID COMMA variable_list ;
expression_stmt: variable_list EQUAL expression SEMICOLON ;

//general statements
statement: expression_stmt
         | IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement
         | IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement ELSE statement
         | WHILE OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement
         | BREAK SEMICOLON
         | CONTINUE SEMICOLON
         | return_stmt
         | OPEN_CURLY program CLOSE_CURLY
         ;
return_stmt: RETURN ID SEMICOLON ;
statement_list: /* empty */
              | statement_list statement
              ; 
compound_statement: OPEN_CURLY statement_list CLOSE_CURLY ;

//function declarations
function_declaration: FUN ID OPEN_PARENTHESIS parameter_list CLOSE_PARENTHESIS RETURNS constant SEMICOLON ;
parameter_list: /* empty */
              | parameter
              | parameter COMMA parameter_list ;
parameter: ID COLON constant ;
function_definition: FUN ID OPEN_PARENTHESIS parameter_list CLOSE_PARENTHESIS RETURNS constant compound_statement ;

//function calls
function_call: ID OPEN_PARENTHESIS argument_list CLOSE_PARENTHESIS ;
argument_list: /* empty */
             | expression
             | expression COMMA argument_list ;
%%

void yy::parser::error (const location_type& l, const std::string& m)
{
    std::cerr << l << ": " << m << '\n';
}