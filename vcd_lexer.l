%{
#include "types.h"
#include "vcd.tab.h"
#include <string.h>
%}

%x IB

%%
"event"      { yylval.vtype = VT_EVENT;    return T_EVENT; }
"integer"    { yylval.vtype = VT_INTEGER;  return T_INTEGER; }
"parameter"  { yylval.vtype = VT_PARAMETER; return T_PARAMETER; }
"real"  { yylval.vtype = VT_REAL; return T_REAL; }
"reg"  { yylval.vtype = VT_REG; return T_REG; }
"supply0"  { yylval.vtype = VT_SUPPLY0; return T_SUPPLY0; }
"supply1"  { yylval.vtype = VT_SUPPLY1; return T_SUPPLY1; }
"tri"  { yylval.vtype = VT_TRI; return T_TRI; }
"triand"  { yylval.vtype = VT_TRIAND; return T_TRIAND; }
"trior"  { yylval.vtype = VT_TRIOR; return T_TRIOR; }
"trireg"  { yylval.vtype = VT_TRIREG; return T_TRIREG; }
"tri0"  { yylval.vtype = VT_TRI0; return T_TRI0; }
"tri1"  { yylval.vtype = VT_TRI1; return T_TRI1; }
"wand"  { yylval.vtype = VT_WAND; return T_WAND; }
"wire"  { yylval.vtype = VT_WIRE; return T_WIRE; }
"wor"  { yylval.vtype = VT_WOR; return T_WOR; }

module      { return module; }
task        { return task; }
function    { return function; }
begin       { return begin_; }  /* avoid C macro conflicts */
fork        { return fork_; }
"\$comment"         { BEGIN(IB); return TOK_COMMENT;    }
"\$date"            { BEGIN(IB); return TOK_DATE;       }
"\$version"         { BEGIN(IB); return TOK_VER;        }
"\$timescale"       { BEGIN(IB); return TOK_TS;         }
"\$scope"           { BEGIN(IB); return TOK_SCOPE;      }
"\$upscope"         { return TOK_UPSCOPE;   }
"\$var"             { return TOK_VAR;       }
"\$enddefinitions"  { return TOK_ENDDEFS;   }
"\$definitions"     { return TOK_DEFS;      }
"\$dumpall"         { return TOK_DUMPALL;   }
"\$dumpoff"         { return TOK_DUMPOFF;   }
"\$dumpon"          { return TOK_DUMPON;    }
"\$dumpvars"        { return TOK_DUMPVARS;  }
"\$end"             { return TOK_END;       }
<IB>"\$end"         { BEGIN(INITIAL); return TOK_END;   }

<IB>.|\n            ;
\[[0-9]+\]          { yylval.num = atoi(yytext + 1); return TOK_BIT;    }
\[[0-9]+:[0-9]+\]   { return TOK_BITS;                                  }
.|[munpf]s          { return TOK_TIMEUNIT;                              }
#[0-9]+             { yylval.num = atoi(yytext + 1); return TOK_TIME;   }
[bB][01xXzZ]+       { yylval.str = strdup(yytext); return TOK_BVEC;     }
[01xXzZ]            { yylval.ch = yytext[0]; return TOK_SCALAR;         }
[a-zA-Z0-9_!"#$%&'()*+,\-./:;<=>?@\[\\\]^_`{|}~]+ {
                        yylval.str = strdup(yytext);
                        return TOK_ID;
                    }
<INITIAL>[ \t\r\n]           ; // Skip whitespace
%%
int yywrap() {
    return 1;
}