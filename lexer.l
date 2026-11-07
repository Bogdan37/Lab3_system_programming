%{
#include <string>
#include <memory>
#include <iostream>
#include "ast.hpp"
#include "parser.tab.hpp"

int yylex();
%}

%option noyywrap

DIGIT       [0-9]+
IDENTIFIER  [a-zA-Z_][a-zA-Z0-9_]*
WS          [ \t\r\n]+

%%

"int"           { return TYPE_INT; }
"float"         { return TYPE_FLOAT; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"return"        { return RETURN; }

{DIGIT}         { yylval.str = new std::string(yytext); return NUMBER; }
{IDENTIFIER}    { yylval.str = new std::string(yytext); return IDENT; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MUL; }
"/"             { return DIV; }
"="             { return ASSIGN; }
"=="            { return EQ; }
"!="            { return NEQ; }
"<"             { return LT; }
">"             { return GT; }

";"             { return SEMICOLON; }
","             { return COMMA; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }

{WS}            { }
"//".*          { }

.               { std::cerr << "Невідомий символ: " << yytext << std::endl; }

%%