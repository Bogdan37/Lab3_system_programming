%{
#include <iostream>
#include <string>
#include <memory>
#include "ast.hpp"

extern int yylex();
void yyerror(const char* s);

std::shared_ptr<ASTNode> root;
%}

%code requires {
    #include <string>
    #include <memory>
    struct ASTNode;
}

%union {
    std::string* str;
    ASTNode* node;
}

%token <str> NUMBER IDENT
%token TYPE_INT TYPE_FLOAT IF ELSE WHILE RETURN
%token PLUS MINUS MUL DIV ASSIGN EQ NEQ LT GT
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE

%right ASSIGN
%left EQ NEQ LT GT
%left PLUS MINUS
%left MUL DIV
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%type <node> program statement_list statement var_decl assignment if_stmt while_stmt block expr

%%

program:
    statement_list {
        root = std::make_shared<ASTNode>(NodeType::PROGRAM);
        ASTNode* curr = $1;
        while (curr) {
            root->addChild(std::shared_ptr<ASTNode>(curr));
            break;
        }
        $$ = root.get();
    }
    ;

statement_list:
    statement_list statement {
        if ($1) {
            $1->addChild(std::shared_ptr<ASTNode>($2));
            $$ = $1;
        } else {
            auto blk = new ASTNode(NodeType::BLOCK);
            blk->addChild(std::shared_ptr<ASTNode>($2));
            $$ = blk;
        }
    }
    | {
        $$ = new ASTNode(NodeType::BLOCK);
    }
    ;

statement:
      var_decl SEMICOLON    { $$ = $1; }
    | assignment SEMICOLON  { $$ = $1; }
    | if_stmt               { $$ = $1; }
    | while_stmt            { $$ = $1; }
    | block                 { $$ = $1; }
    ;

var_decl:
    TYPE_INT IDENT {
        $$ = new ASTNode(NodeType::VAR_DECL, *$2);
        delete $2;
    }
    | TYPE_INT IDENT ASSIGN expr {
        $$ = new ASTNode(NodeType::VAR_DECL, *$2);
        $$->addChild(std::shared_ptr<ASTNode>($4));
        delete $2;
    }
    ;

assignment:
    IDENT ASSIGN expr {
        $$ = new ASTNode(NodeType::ASSIGNMENT);
        $$->addChild(std::make_shared<ASTNode>(NodeType::IDENTIFIER, *$1));
        $$->addChild(std::shared_ptr<ASTNode>($3));
        delete $1;
    }
    ;

if_stmt:
    IF LPAREN expr RPAREN statement %prec LOWER_THAN_ELSE {
        $$ = new ASTNode(NodeType::IF_STMT);
        $$->addChild(std::shared_ptr<ASTNode>($3));
        $$->addChild(std::shared_ptr<ASTNode>($5));
    }
    | IF LPAREN expr RPAREN statement ELSE statement {
        $$ = new ASTNode(NodeType::IF_STMT);
        $$->addChild(std::shared_ptr<ASTNode>($3));
        $$->addChild(std::shared_ptr<ASTNode>($5));
        $$->addChild(std::shared_ptr<ASTNode>($7));
    }
    ;

while_stmt:
    WHILE LPAREN expr RPAREN statement {
        $$ = new ASTNode(NodeType::WHILE_STMT);
        $$->addChild(std::shared_ptr<ASTNode>($3));
        $$->addChild(std::shared_ptr<ASTNode>($5));
    }
    ;

block:
    LBRACE statement_list RBRACE {
        $$ = $2;
    }
    ;

expr:
      expr PLUS expr  { $$ = new ASTNode(NodeType::BINARY_EXPR, "+"); $$->addChild(std::shared_ptr<ASTNode>($1)); $$->addChild(std::shared_ptr<ASTNode>($3)); }
    | expr MINUS expr { $$ = new ASTNode(NodeType::BINARY_EXPR, "-"); $$->addChild(std::shared_ptr<ASTNode>($1)); $$->addChild(std::shared_ptr<ASTNode>($3)); }
    | expr MUL expr   { $$ = new ASTNode(NodeType::BINARY_EXPR, "*"); $$->addChild(std::shared_ptr<ASTNode>($1)); $$->addChild(std::shared_ptr<ASTNode>($3)); }
    | expr DIV expr   { $$ = new ASTNode(NodeType::BINARY_EXPR, "/"); $$->addChild(std::shared_ptr<ASTNode>($1)); $$->addChild(std::shared_ptr<ASTNode>($3)); }
    | expr LT expr    { $$ = new ASTNode(NodeType::BINARY_EXPR, "<"); $$->addChild(std::shared_ptr<ASTNode>($1)); $$->addChild(std::shared_ptr<ASTNode>($3)); }
    | expr GT expr    { $$ = new ASTNode(NodeType::BINARY_EXPR, ">"); $$->addChild(std::shared_ptr<ASTNode>($1)); $$->addChild(std::shared_ptr<ASTNode>($3)); }
    | LPAREN expr RPAREN { $$ = $2; }
    | NUMBER          { $$ = new ASTNode(NodeType::NUMBER, *$1); delete $1; }
    | IDENT           { $$ = new ASTNode(NodeType::IDENTIFIER, *$1); delete $1; }
    ;

%%

void yyerror(const char* s) {
    std::cerr << "Синтаксична помилка: " << s << std::endl;
}