%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"
#include "hobj.h"

#define VERBOSE
#define SET_FLAG(f)   (flags |=  (1 << (f)))
#define CLR_FLAG(f)   (flags &= ~(1 << (f)))
#define HAS_FLAG(f)   (flags &   (1 << (f)))

void yyerror(const char* s);
int yylex();

extern int yylineno;
extern void set_state(int);

// Output objects
Object* o_vars;
Object* o_data;

Object* o_tmp;
int ctime = 0;
/* Bit  Flag
 * 0    Inside dumpall
 * 1    Inside dumpvars
 * 2    Inside dumpon
 * 3    Inside dumpoff
*/
char flags = 0;

void newscalar(char d, char* id) {
#ifdef VERBOSE 
    printf("%s: %c at #%d\n", id, d, ctime);
#endif
}

void newdata(char* d, char* id) {
    // Get the bit width to extend
    int width = 0;
    Object* var = (Object*)hobjGet(o_vars, id);
    if(var != NULL) {
        int* width_p = (int*)hobjGet(var, "width");
        if(width_p != NULL) width = *width_p;
    }
    char* data = malloc(width + 1);
    if(strlen(d) < width && width != 0) { // Do we need to extend?
        char e = (d[0] == '1' ? '0' : d[0]); // Char to extend with
        int i = 0;
        for(; i < width - strlen(d); i++) {
            data[i] = e;
        }
        strcat(data + i, d);
    } else {
        strcpy(data, d);
    }
#ifdef VERBOSE
    printf("%s: %s at #%d\n", id, data, ctime);
#endif
}

var_t newvar(var_type_t type, char *name, char *id, int width)
{
    var_t v;
    v.type = type;
    v.name = name;
    v.id = id;
    v.width = width;
    Object *vo = hobjNew(3,
        hobjVal(TYPE_STRING, "name", name),
        hobjVal(TYPE_INT, "type", &type),
        hobjVal(TYPE_INT, "width", &width)
    );
    hobjAppend(o_vars,
        hobjVal(TYPE_OBJECT, id, vo)
    );
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

%token <str> TOK_ID TOK_BVEC
%token <num> NUMBER TOK_TIME
%token <ch>  TOK_SCALAR

%token TOK_TS TOK_DATE TOK_VER TOK_SCOPE
%token TOK_UPSCOPE TOK_VAR TOK_ENDDEFS
%token TOK_COMMENT TOK_BODYCOMMENT
%token TOK_DUMPALL TOK_DUMPOFF TOK_DUMPON
%token TOK_DUMPVARS
%token TOK_END

%token TOK_TIMEUNIT TOK_BITS TOK_BIT

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
      TOK_BODYCOMMENT TOK_END
    | val_change
    | TOK_TIME { ctime = $1; }
    | TOK_DUMPON {
#ifdef VERBOSE
        printf("Dumpon\n");
#endif
    } dumps dump_end
    | TOK_DUMPOFF {
#ifdef VERBOSE
        printf("Dumpoff\n");
#endif
    } dumps dump_end
    | TOK_DUMPALL {
#ifdef VERBOSE
        printf("Dumpall\n");
#endif
    } dumps dump_end
    | TOK_DUMPVARS {
#ifdef VERBOSE
        printf("Dumpvars\n");
#endif
    } dumps dump_end
;

dump_end: TOK_END {
#ifdef VERBOSE
    printf("End\n");
#endif
    }

header:
      header_line
    | header header_line
;

header_line:
      TOK_COMMENT TOK_END
    | TOK_DATE TOK_END
    | TOK_VER TOK_END
    | TOK_TS TOK_TIMEUNIT TOK_END
    | TOK_SCOPE scope TOK_END
    | TOK_UPSCOPE TOK_END
    | TOK_VAR var TOK_END
    | TOK_ENDDEFS TOK_END { set_state(2); }
;

val_change:
      TOK_BVEC TOK_ID { newdata($1, $2); }
    | TOK_SCALAR TOK_ID { newscalar($1, $2); }
;

dumps: /* empty */
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
    o_vars = hobjNew(0);
    o_data = hobjNew(0);
    o_tmp = hobjNew(0);
    yyparse();
    //hobjPrint(o_vars, "");
}
void yyerror(const char* s) {
    fprintf(stderr, "Error: %s on line %d\n", s, yylineno);
}