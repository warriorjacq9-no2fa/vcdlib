%{
#define YYSTYPE int
#include <stdio.h>
%}

%token TOK_NUM
%token TOK_END
%token TOK_KW

%%
block: TOK_KW '\n' TOK_END;
header: block { $$ = $1; }
    | block header { $$ = $1 $2; }
file: header { printf("%d\n", $1); }
%%