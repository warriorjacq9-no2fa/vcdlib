%{
#include <stdio.h>
#include "types.h"
void yyerror(const char* s);
int yylex();

var_t newvar(var_type_t type, char *name, char *id, int width)
{
    var_t v;
    v.type = type;
    v.name = name;
    v.id = id;
    v.width = width;
    return v;
    printf("New var: %d %s %s %d", type, name, id, width);
}
%}

%union {
    char *str;
    int num;
    var_t v;
    var_type_t vtype;
    char ch;
}

%token <str> STRING
%token <num> NUMBER
%token TOK_TS TOK_DATE TOK_VER TOK_SCOPE
%token TOK_UPSCOPE TOK_VAR TOK_ENDDEFS TOK_DEFS
%token TOK_COMMENT TOK_TIMEUNIT TOK_BITS TOK_END
%token <num> TOK_TIME
%token <str> TOK_BVEC TOK_SCALAR TOK_ID
%token TOK_DUMPALL TOK_DUMPOFF TOK_DUMPON
%token TOK_DUMPVARS TOK_BIT
%token <vtype> T_EVENT T_INTEGER T_PARAMETER T_REAL T_REG
%token <vtype> T_SUPPLY0 T_SUPPLY1 T_TRI T_TRIAND T_TRIOR T_TRIREG
%token <vtype> T_TRI0 T_TRI1 T_WAND T_WIRE T_WOR
%token module task function begin_ fork_
%type <v> var
%type <str> var_ref
%type <vtype> var_type
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
            $$ = newvar($1, $4, $3, $2);
        }
;

var_type:
      T_EVENT
    | T_INTEGER
    | T_PARAMETER
    | T_REAL
    | T_REG
    | T_SUPPLY0
    | T_SUPPLY1
    | T_TRI
    | T_TRIAND
    | T_TRIOR
    | T_TRIREG
    | T_TRI0
    | T_TRI1
    | T_WAND
    | T_WIRE
    | T_WOR
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
void main(void) {
    yyparse();
}
void yyerror(const char* s) {
    printf("%s\n", s);
}