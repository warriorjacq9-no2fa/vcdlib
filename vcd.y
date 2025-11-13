%{
#include <stdio.h>
#include "types.h"
void yyerror(const char* s);
int yylex(void);

var_t newvar(char *type, char *name, char *id, int width)
{
    var_t v;
    v.type = type;
    v.name = name;
    v.id = id;
    v.width = width;
    return v;
    printf("New var: %s %s %s %d", type, name, id, width);
}
%}

%union {
    char *str;
    int num;
    var_t v;
    char ch;
}

%token <str> STRING
%token <num> NUMBER
%token TOK_TS TOK_DATE TOK_VER TOK_SCOPE
%token TOK_UPSCOPE TOK_VAR TOK_ENDDEFS TOK_DEFS
%token TOK_COMMENT TOK_TIMEUNIT TOK_BITS TOK_END
%token TOK_TIME TOK_BVEC TOK_SCALAR TOK_ID
%token TOK_DUMPALL TOK_DUMPOFF TOK_DUMPON
%token TOK_DUMPVARS TOK_BIT
%token event integer parameter real reg
%token supply0 supply1 tri triand trior trireg
%token tri0 tri1 wand wire wor
%token module task function begin_ fork_
%type <str> supply0 supply1 tri triand trior trireg
%type <str> tri0 tri1 wand wire wor
%type <str> module task function begin_ fork
%type <num> TOK_TIME
%type <str> TOK_BVEC TOK_SCALAR TOK_ID
%type <v> var
%type <str> var_type var_ref
%%

file:
    header body
;

body:
      body_line
    | body body_line
;

body_line:
      val_change
    | TOK_DUMPON dumps TOK_END
    | TOK_DUMPOFF dumps TOK_END
    | TOK_DUMPALL dumps TOK_END
    | TOK_DUMPVARS dumps TOK_END

header:
      header_line
    | header header_line
    | header header_end
;

header_end:
    TOK_ENDDEFS TOK_END

header_line:
      TOK_COMMENT TOK_END
    | TOK_DATE TOK_END
    | TOK_VER TOK_END
    | TOK_TS timescale TOK_END
    | TOK_SCOPE scope TOK_END
    | TOK_UPSCOPE TOK_END
    | TOK_VAR var TOK_END
;

val_change:
      TOK_BVEC TOK_ID
    | TOK_SCALAR TOK_ID

dumps:
      val_change
    | dumps val_change
;

var_ref:
      STRING
    | STRING TOK_BIT
    | STRING TOK_BITS
;

var:
    var_type NUMBER TOK_ID var_ref {
            $$ = newvar($1, $2, $3, $4);
        }
;

var_type:
      event
    | integer
    | parameter
    | real
    | reg
    | supply0
    | supply1
    | tri
    | triand
    | trior
    | trireg
    | tri0
    | tri1
    | wand
    | wire
    | wor
;

timescale:
    NUMBER TOK_TIMEUNIT
;

scope:
    scope_type TOK_ID
;

scope_type:
      module
    | task
    | function
    | begin_
    | fork_
;
%%
main() {
    yyparse();
}
yyerror(char* s) {
    printf("%s\n", s);
}