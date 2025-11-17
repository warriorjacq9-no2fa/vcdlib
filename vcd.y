%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"
#include "hobj.h"

#define SET_FLAG(f)     (flags |=  (1 << (f)))
#define CLR_FLAGS()     (flags = 0)
#define HAS_FLAG(f)     (flags &   (1 << (f)))

void yyerror(const char* s);
int yylex();

extern int yylineno;
extern void set_state(int);

// Output objects
Object* o_vars;
Object* o_data;

Object* o_tmp;
int ctime = 0;
int cindex = 0;
/* Bit  Flag
 * 0    Inside dumpon   (1)
 * 1    Inside dumpoff  (2)
 * 2    Inside dumpall  (4)
 * 3    Inside dumpvars (8)
*/
char flags = 0;

void newscalar(char d, char* id) {
    char data[2];
    data[0] = d;
    data[1] = '\0';
    if(hobjGet(o_tmp, id) != NULL) {
        hobjSet(o_tmp,
            hobjVal(TYPE_STRING, id, data)
        );
    } else {
        hobjAppend(o_tmp,
            hobjVal(TYPE_STRING, id, data)
        );
    }
#ifdef VERBOSE 
    printf("%s: %s at #%d:%d\n", id, data, ctime, flags);
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
        strcpy(data + i, d);
    } else {
        strcpy(data, d);
    }
    if(hobjGet(o_tmp, id) != NULL) {
        hobjSet(o_tmp,
            hobjVal(TYPE_STRING, id, data)
        );
    } else {
        hobjAppend(o_tmp,
            hobjVal(TYPE_STRING, id, data)
        );
    }
#ifdef VERBOSE
    printf("%s: %s at #%d:%d\n", id, data, ctime, flags);
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
    | TOK_TIME {
        if ($1 != ctime) {

            /* convert ctime to string for the new timestamp key */
            char s_time[32];
            snprintf(s_time, sizeof(s_time), "%d", ctime);

            /* For each var that is missing in o_tmp, look up the most recent timestamp
            in o_data that contains that var */
            for (int i = 0; i < o_vars->count; i++) {

                /* if the current o_tmp does not have this variable */
                if (hobjGet(o_tmp, o_vars->items[i].key) == NULL) {

                    const char *var_key = o_vars->items[i].key;
                    char *val = NULL;

                    /* search backwards through o_data for the most recent timestamp
                    whose object contains this key */
                    for (int k = o_data->count - 1; k >= 0; k--) {

                        Object *prev_obj = hobjGet(o_data, o_data->items[k].key);
                        if (prev_obj == NULL)
                            continue;

                        val = hobjGet(prev_obj, var_key);
                        if (val != NULL)
                            break;  // found the most recent value
                    }

                    if (val != NULL) {
                        //printf("%s not present, using %s\n", var_key, val);
                        hobjAppend(o_tmp,
                            hobjVal(TYPE_STRING, var_key, val)
                        );
                    } else {
                        printf("%s not present and no previous value found\n", var_key);
                    }
                }
            }

            /* now append this completed object into o_data */
            hobjAppend(o_data, hobjVal(TYPE_OBJECT, s_time, hobjClone(o_tmp)));

            hobjFreeAll(o_tmp);
            o_tmp = hobjNew(0);
            ctime = $1;
            cindex++;
        }
    }
    | TOK_DUMPON {
        SET_FLAG(0);
#ifdef VERBOSE
        printf("Dumpon\n");
#endif
    } dumps dump_end
    | TOK_DUMPOFF {
        SET_FLAG(1);
#ifdef VERBOSE
        printf("Dumpoff\n");
#endif
    } dumps dump_end
    | TOK_DUMPALL {
        SET_FLAG(2);
#ifdef VERBOSE
        printf("Dumpall\n");
#endif
    } dumps dump_end
    | TOK_DUMPVARS {
        SET_FLAG(3);
#ifdef VERBOSE
        printf("Dumpvars\n");
#endif
    } dumps dump_end
;

dump_end: TOK_END {
#ifdef VERBOSE
        printf("End %d\n", flags);
#endif
        CLR_FLAGS();
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
int main(void) {
    o_vars = hobjNew(0);
    o_data = hobjNew(0);
    o_tmp = hobjNew(0);
    yyparse();
    printf("Variables: ");
    hobjPrint(o_vars, "");
    printf("Data: ");
    hobjPrint(o_data, "");
}
void yyerror(const char* s) {
    fprintf(stderr, "Error: %s on line %d\n", s, yylineno);
}