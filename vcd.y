%{
#include <stdio.h>

void yyerror(const char* s);
int yylex(void);

typedef struct {
    char *name;
    char *id;
    int width;
} var_t;
%}

%union {
    char *str;
    int num;
}

%token TOK_TS TOK_DATE TOK_VER TOK_SCOPE TOK_UPSCOPE TOK_VAR TOK_ENDDEFS TOK_DEFS TOK_END
%token TOK_TIME TOK_BVAL TOK_SCALAR TOK_ID
%type <num> TOK_TIME
%type <str> TOK_BVAL TOK_SCALAR TOK_ID

%%

file:
    header defs change
    ;

header:
      header_line
    | header '\n' header_line
    ;

header_line:
      TOK_DATE .* TOK_END
    | TOK_VER str TOK_END
    | TOK_TS str TOK_END
    | TOK_SCOPE 

%%