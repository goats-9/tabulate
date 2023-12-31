%{
#include <fstream>
#include <map>
#include <stdio.h>
#include "tabulate.hh"
#include "parser.tab.hh"
using namespace std;

// Code run each time a pattern is matched.
# define YY_USER_ACTION  loc.columns (yyleng);

map<string,string> biOp_to_func = {
    {"==","EQ"},
    {"!=","NE"},
    {">","GT"},
    {"<","LT"},
    {">=","GTE"},
    {"<=","LTE"},
    {"AND","AND"},
    {"OR","OR"},
    {"XOR","XOR"}
};
map<string,string> uniOp_to_func = {
    {"NOT","NOT"},
    {"-","UniMinus"},
    {"~","NOT"},
    {"TYPEOF","TYPEOF"}
};
%}

%option noyywrap nounput noinput batch debug


/* Declare token defination as follow */

RESERVED "any"|"time"|"shape"|"range"|"date"|"pos"|"state"|"uni_err"|"bi_err"|"split"|"disp_error"|"__funcMap"|"__funcParams"|"__memMap"|"__copyConstruct"|"__runnerCode"
DIGIT [0-9]
INT -?{DIGIT}*
DOUBLE ({DIGIT}+\.{DIGIT}*)|({DIGIT}*\.{DIGIT}+)
STRING \"([^"]*\\\")*[^"]*\"
BOOL "true"|"false"
DATE {DIGIT}{1,4}-{DIGIT}{1,2}-{DIGIT}{1,2}
TIME {DIGIT}{1,2}{colon}{DIGIT}{1,2}{colon}{DIGIT}{1,2}
RANGE {DIGIT}+{colon}{DIGIT}+(~{DIGIT}*)?
COMMENTS #[^#]*#
SPACE [ \t]
char_id_start [_a-zA-Z]
char_id [_a-zA-Z0-9]
ID {char_id_start}{char_id}*
/* DATATYPE1 "int"|"double"|"string"|"bool"|"date"|"time" */
/* DATATYPE2 "cell"|"range"|"array"|"table"|"formula" */
/* DATATYPE {DATATYPE1}|{DATATYPE2} */
ARITHMETIC "ADD"|"SUB"|"MUL"|"DIV"|"MOD"|"POW"|"BOR"|"BAND"|"BXOR"|"BNOT"|"BLS"|"BRS"
bi_OP "=="|"!="|">"|"<"|">="|"<="|"AND"|"OR"|"XOR"
uni_OP "NOT"|"-"|"~"|"TYPEOF"
EQUAL "="
open_square_brac "["
close_square_brac "]"
colon ":"
dot "."
semiColon ";"
comma ","
open_curly "{"
close_curly "}"
open_parenthesis "("
close_parenthesis ")"

%%
%{
    // location
    yy::location& loc = drv.location;
    // Code run each time yylex is called.
    loc.step ();
%}
    /*
    Add token defination below
    Some tokens are added for reference
    */

    /* Restructed reserved keywords */
{RESERVED} {
    throw yy::parser::syntax_error(loc, "cannot use reserved keyword: " + string(yytext));
}

    /* reserved keywords */
"this" {
    auto token = yy::parser::make_THIS(loc);
    drv.handleToken(token,yytext);
    return token;
}
"constructor" {
    auto token = yy::parser::make_CONSTRUCTOR(loc);
    drv.handleToken(token,yytext);
    return token;
}
"new" {
    auto token = yy::parser::make_NEW(loc);
    drv.handleToken(token,yytext);
    return token;
}
"let" {
    auto token = yy::parser::make_LET(loc);
    drv.handleToken(token,yytext);
    return token;
}
"const" {
    auto token = yy::parser::make_CONST(loc);
    drv.handleToken(token,yytext);
    return token;
}
"struct" {
    auto token = yy::parser::make_STRUCT(loc);
    drv.handleToken(token,yytext);
    return token;
}
"if" {
    auto token = yy::parser::make_IF(loc);
    drv.handleToken(token,yytext);
    return token;
}
"else" {
    auto token = yy::parser::make_ELSE(loc);
    drv.handleToken(token,yytext);
    return token;
}
"void" {
    auto token = yy::parser::make_VOID(loc);
    drv.handleToken(token,yytext);
    return token;
}
"while" {
    auto token = yy::parser::make_WHILE(loc);
    drv.handleToken(token,yytext);
    return token;
}
"fun" {
    auto token = yy::parser::make_FUN(loc);
    drv.handleToken(token,yytext);
    return token;
}
"return" {
    auto token = yy::parser::make_RETURN(loc);
    drv.handleToken(token,yytext);
    return token;
}
"break" {
    auto token = yy::parser::make_BREAK(loc);
    drv.handleToken(token,yytext);
    return token;
}
"continue" {
    auto token = yy::parser::make_CONTINUE(loc);
    drv.handleToken(token,yytext);
    return token;
}
    /* datatype */
    /* 
    {DATATYPE} {
        auto token = yy::parser::make_DATATYPE(yytext,loc);
        drv.handleToken(token,yytext);
        return token;
    } 
    */

    /* operators */
    /*
    {ARITHMETIC} {
        auto token = yy::parser::make_ARITHMETIC(yytext,loc);
        drv.handleToken(token,yytext);
        return token;
    } 
    */
{bi_OP} {
    auto token = yy::parser::make_BIOP(biOp_to_func[yytext],loc);
    drv.handleToken(token,yytext);
    return token;
}
{uni_OP} {
    auto token = yy::parser::make_UNIOP(uniOp_to_func[yytext],loc);
    drv.handleToken(token,yytext);
    return token;
}
{EQUAL} {
    auto token = yy::parser::make_EQUAL(loc);
    drv.handleToken(token,yytext);
    return token;
}

    /* Punctuator */
{open_square_brac} {
    auto token = yy::parser::make_OPEN_SQUARE_BRAC(loc);
    drv.handleToken(token,yytext);
    return token;
}
{close_square_brac} {
    auto token = yy::parser::make_CLOSE_SQUARE_BRAC(loc);
    drv.handleToken(token,yytext);
    return token;
}
{colon} {
    auto token = yy::parser::make_COLON(loc);
    drv.handleToken(token,yytext);
    return token;
}
{dot} {
    auto token = yy::parser::make_DOT(loc);
    drv.handleToken(token,yytext);
    return token;
}
{semiColon} {
    auto token = yy::parser::make_SEMICOLON(loc);
    drv.handleToken(token,yytext);
    return token;
}
{comma} {
    auto token = yy::parser::make_COMMA(loc);
    drv.handleToken(token,yytext);
    return token;
}
{open_curly} {
    auto token = yy::parser::make_OPEN_CURLY(loc);
    drv.handleToken(token,yytext);
    return token;
}
{close_curly} {
    auto token = yy::parser::make_CLOSE_CURLY(loc);
    drv.handleToken(token,yytext);
    return token;
}
{open_parenthesis} {
    auto token = yy::parser::make_OPEN_PARENTHESIS(loc);
    drv.handleToken(token,yytext);
    return token;
}
{close_parenthesis} {
    auto token = yy::parser::make_CLOSE_PARENTHESIS(loc);
    drv.handleToken(token,yytext);
    return token;
}
    /* constant */
{INT} {
    auto token = yy::parser::make_INT(yytext, loc);
    drv.handleToken(token,yytext);
    return token;
}
{STRING} {
    auto token = yy::parser::make_STRING(yytext, loc);
    drv.handleToken(token,yytext);
    return token;
}
{BOOL} {
    auto token = yy::parser::make_BOOL(yytext, loc);
    drv.handleToken(token,yytext);
    return token;
}
{DOUBLE} {
    auto token = yy::parser::make_DOUBLE(yytext, loc);
    drv.handleToken(token,yytext);
    return token;
}
{TIME} {
    auto token = yy::parser::make_TIME("\"" + string(yytext) + "\"", loc);
    drv.handleToken(token,yytext);
    return token;
}    
{DATE} {
    auto token = yy::parser::make_DATE("\"" + string(yytext) + "\"", loc);
    drv.handleToken(token,yytext);
    return token;
}
{RANGE} {
    auto token = yy::parser::make_RANGE("\"" + string(yytext) + "\"", loc);
    drv.handleToken(token,yytext);
    return token;
}

    /* identifiers */
{ID} {
    auto token = yy::parser::make_ID(yytext, loc);
    drv.handleToken(token,yytext);
    return token;
}
    /* spaces */
{SPACE} {
    loc.step();
}
    /* comments */
{COMMENTS} {
    int lines_in_comment = 0;
    int col_length = 0;
    for (int i=0;i<yyleng;i++)
    {
        if (yytext[i] == '\n')
        {
            lines_in_comment++;
            col_length = 0;
        }
        else
        {
            col_length++;
        }
    }
    loc.lines(lines_in_comment);
    if (lines_in_comment > 0)
    {
        loc.columns(col_length);
    }
    loc.step();
}
    /* newline */
\n {loc.lines (yyleng); loc.step();}
    /* error handling */
. {
    throw yy::parser::syntax_error(loc, "invalid character: " + string(yytext));
}
    /* EOF */
<<EOF>>    return yy::parser::make_YYEOF (loc);
%%