%{
#include "vcd.tab.h"
#include <string.h>
%}

%x IB

%%
event       { return event; }
integer     { return integer; }
parameter   { return parameter; }
real        { return real; }
reg         { return reg; }

supply0     { return supply0; }
supply1     { return supply1; }
tri         { return tri; }
triand      { return triand; }
trior       { return trior; }
trireg      { return trireg; }

tri0        { return tri0; }
tri1        { return tri1; }
wand        { return wand; }
wire        { return wire; }
wor         { return wor; }

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