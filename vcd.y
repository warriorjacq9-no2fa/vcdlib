%{
#include <stdio.h>
#include <stdlib.h>
#include "types.h"
#include "hobj.h"
void yyerror(const char* s);
int yylex();

extern int yylineno;
extern void set_state(int);

Object* root;

var_t newvar(var_type_t type, char *name, char *id, int width)
{
    var_t v;
    v.type = type;
    v.name = name;
    v.id = id;
    v.width = width;
    printf("New var: %s %s[%d] '%s'\n", vtype_lt[type], name, width, id);
    hobj
    return v;
}
%}

%define parse.error detailed
%union {
    char *str;
    int num;
    var_t v;
    var_type_t vtype;
    scope_type_t stype;
    char ch;
}

%token <str> TOK_ID
%token <num> NUMBER
%token TOK_TS TOK_DATE TOK_VER TOK_SCOPE
%token TOK_UPSCOPE TOK_VAR TOK_ENDDEFS TOK_DEFS
%token TOK_COMMENT TOK_TIMEUNIT TOK_BITS TOK_END
%token <num> TOK_TIME
%token <str> TOK_BVEC
%token <ch>  TOK_SCALAR
%token TOK_DUMPALL TOK_DUMPOFF TOK_DUMPON
%token TOK_DUMPVARS TOK_BIT
%token <vtype> T_EVENT T_INTEGER T_PARAMETER T_REAL T_REG
%token <vtype> T_SUPPLY0 T_SUPPLY1 T_TRI T_TRIAND T_TRIOR T_TRIREG
%token <vtype> T_TRI0 T_TRI1 T_WAND T_WIRE T_WOR
%token <stype> S_MODULE S_TASK S_FUNCTION S_BEGIN S_FORK
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
      TOK_COMMENT TOK_END
    | val_change
    | TOK_TIME
    | TOK_DUMPON dumps TOK_END
    | TOK_DUMPOFF dumps TOK_END
    | TOK_DUMPALL dumps TOK_END
    | TOK_DUMPVARS dumps TOK_END
;

header:
      header_line
    | header header_line
    | header header_end
;

header_end:
    TOK_ENDDEFS TOK_END { set_state(2); }
;

header_line:
      TOK_COMMENT TOK_END
    | TOK_DATE TOK_END
    | TOK_VER TOK_END
    | TOK_TS TOK_TIMEUNIT TOK_END
    | TOK_SCOPE scope TOK_END
    | TOK_UPSCOPE TOK_END
    | TOK_VAR var TOK_END
;

val_change:
      TOK_BVEC TOK_ID { printf("%s = %s\n", $2, $1); }
    | TOK_SCALAR TOK_ID { printf("%s = %c\n", $2, $1); }
;

dumps: // Empty
    | val_change
    | dumps val_change
;

var_ref:
      TOK_ID
    | TOK_ID TOK_BIT
    | TOK_ID TOK_BITS
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

scope:
    scope_type TOK_ID
;

scope_type:
      S_MODULE
    | S_TASK
    | S_FUNCTION
    | S_BEGIN
    | S_FORK
;
%%
void main(void) {
    root = hobjNew(0);
    yyparse();
}
void yyerror(const char* s) {
    printf("Error: %s on line %d\n", s, yylineno);
}