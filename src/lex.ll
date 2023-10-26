%{
    #include <fstream>
    #include <stdio.h>
    #include "driver.hh"
    #include "parser.tab.hh"
    #include "auxilary.hh"
    using namespace std;

    // Code run each time a pattern is matched.
    # define YY_USER_ACTION  loc.columns (yyleng);
%}

%option noyywrap nounput noinput batch debug


/* Declare token defination as follow */

DIGIT [0-9]+
COMMENTS #[^#]*#
SPACE [ \t]
IGNORE ({SPACE}|{COMMENTS})
char_id_start [_a-zA-Z]
char_id [_a-zA-Z0-9]
ID {char_id_start}{char_id}*
DATATYPE1 "int"|"double"|"string"|"bool"|"date"|"time"
DATATYPE2 "cell"|"range"|"array"|"table"|"formula"
DATATYPE {DATATYPE1}|{DATATYPE2}
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

    /* reserved keywords */
"class" {
    auto token = yy::parser::make_CLASS(loc);
    drv.handleToken(token);
    return token;
}
"if" {
    auto token = yy::parser::make_IF(loc);
    drv.handleToken(token);
    return token;
}
"else" {
    auto token = yy::parser::make_ELSE(loc);
    drv.handleToken(token);
    return token;
}
"void" {
    auto token = yy::parser::make_VOID(loc);
    drv.handleToken(token);
    return token;
}
"while" {
    auto token = yy::parser::make_WHILE(loc);
    drv.handleToken(token);
    return token;
}
"fun" {
    auto token = yy::parser::make_FUN(loc);
    drv.handleToken(token);
    return token;
}
"return" {
    auto token = yy::parser::make_RETURN(loc);
    drv.handleToken(token);
    return token;
}
"returns" {
    auto token = yy::parser::make_RETURNS(loc);
    drv.handleToken(token);
    return token;
}
"break" {
    auto token = yy::parser::make_BREAK(loc);
    drv.handleToken(token);
    return token;
}
"continue" {
    auto token = yy::parser::make_CONTINUE(loc);
    drv.handleToken(token);
    return token;
}
"main" {
    auto token = yy::parser::make_MAIN(loc);
    drv.handleToken(token);
    return token;
}
    /* datatype */
{DATATYPE} {
    auto token = yy::parser::make_DATATYPE(yytext,loc);
    drv.handleToken(token);
    return token;
}
    /* operators */
{ARITHMETIC} {
    auto token = yy::parser::make_ARITHMETIC(yytext,loc);
    drv.handleToken(token);
    return token;
}
{bi_OP} {
    auto token = yy::parser::make_BIOP(yytext,loc);
    drv.handleToken(token);
    return token;
}
{uni_OP} {
    auto token = yy::parser::make_UNIOP(yytext,loc);
    drv.handleToken(token);
    return token;
}
{EQUAL} {
    auto token = yy::parser::make_EQUAL(loc);
    drv.handleToken(token);
    return token;
}
    /* Punctuator */
{open_square_brac} {
    auto token = yy::parser::make_OPEN_SQUARE_BRAC(loc);
    drv.handleToken(token);
    return token;
}
{close_square_brac} {
    auto token = yy::parser::make_CLOSE_SQUARE_BRAC(loc);
    drv.handleToken(token);
    return token;
}
{colon} {
    auto token = yy::parser::make_COLON(loc);
    drv.handleToken(token);
    return token;
}
{dot} {
    auto token = yy::parser::make_DOT(loc);
    drv.handleToken(token);
    return token;
}
{semiColon} {
    auto token = yy::parser::make_SEMICOLON(loc);
    drv.handleToken(token);
    return token;
}
{comma} {
    auto token = yy::parser::make_COMMA(loc);
    drv.handleToken(token);
    return token;
}
{open_curly} {
    auto token = yy::parser::make_OPEN_CURLY(loc);
    drv.handleToken(token);
    return token;
}
{close_curly} {
    auto token = yy::parser::make_CLOSE_CURLY(loc);
    drv.handleToken(token);
    return token;
}
{open_parenthesis} {
    auto token = yy::parser::make_OPEN_PARENTHESIS(loc);
    drv.handleToken(token);
    return token;
}
{close_parenthesis} {
    auto token = yy::parser::make_CLOSE_PARENTHESIS(loc);
    drv.handleToken(token);
    return token;
}
    /* constant */
{DIGIT} {
    auto token = yy::parser::make_DIGIT(stoi(yytext), loc);
    drv.handleToken(token);
    return token;
}
    /* identifiers */
{ID} {
    auto token = yy::parser::make_ID(yytext, loc);
    drv.handleToken(token);
    return token;
}
    /* comments and spaces */
{IGNORE} {
    loc.step();
}
    /* newline */
\n {loc.lines (yyleng); loc.step();}
    /* error handling */
. {throw yy::parser::syntax_error(loc, "invalid character: " + string(yytext));}
    /* EOF */
<<EOF>>    return yy::parser::make_YYEOF (loc);
%%

void driver::scan_begin ()
{
    yy_flex_debug = trace_scanning;
    if (file.empty ())
        yyin = stdin;
    else if (!(yyin = fopen (file.c_str (), "r")))
    {
        std::cerr << "cannot open " << file << ": " << strerror (errno) << '\n';
        exit (EXIT_FAILURE);
    }
}


void driver::scan_end ()
{
    fclose (yyin);
}


