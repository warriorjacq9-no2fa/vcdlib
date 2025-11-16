%{
#include "types.h"
#include "vcd.tab.h"
#include <string.h>
%}

%x IGNORE
%s VAR_BODY
%option yylineno
%option stack

%%
"event"         { yylval.vtype = VT_EVENT; return T_EVENT;          }
"integer"       { yylval.vtype = VT_INTEGER; return T_INTEGER;      }
"parameter"     { yylval.vtype = VT_PARAMETER; return T_PARAMETER;  }
"real"          { yylval.vtype = VT_REAL; return T_REAL;            }
"reg"           { yylval.vtype = VT_REG; return T_REG;              }
"supply0"       { yylval.vtype = VT_SUPPLY0; return T_SUPPLY0;      }
"supply1"       { yylval.vtype = VT_SUPPLY1; return T_SUPPLY1;      }
"tri"           { yylval.vtype = VT_TRI; return T_TRI;              }
"triand"        { yylval.vtype = VT_TRIAND; return T_TRIAND;        }
"trior"         { yylval.vtype = VT_TRIOR; return T_TRIOR;          }
"trireg"        { yylval.vtype = VT_TRIREG; return T_TRIREG;        }
"tri0"          { yylval.vtype = VT_TRI0; return T_TRI0;            }
"tri1"          { yylval.vtype = VT_TRI1; return T_TRI1;            }
"wand"          { yylval.vtype = VT_WAND; return T_WAND;            }
"wire"          { yylval.vtype = VT_WIRE; return T_WIRE;            }
"wor"           { yylval.vtype = VT_WOR; return T_WOR;              }

"module"        { yylval.stype = ST_MODULE; return S_MODULE;    }
"task"          { yylval.stype = ST_TASK; return S_TASK;        }
"function"      { yylval.stype = ST_FUNCTION; return S_FUNCTION;}
"begin"         { yylval.stype = ST_BEGIN; return S_BEGIN;      }
"fork"          { yylval.stype = ST_FORK; return S_FORK;        }

<VAR_BODY>"\$comment" { yy_push_state(IGNORE); return TOK_BODYCOMMENT; }
"\$comment"         { yy_push_state(IGNORE); return TOK_COMMENT;    }
"\$date"            { yy_push_state(IGNORE); return TOK_DATE;       }
"\$version"         { yy_push_state(IGNORE); return TOK_VER;        }
"\$timescale"       { return TOK_TS;        }
"\$scope"           { return TOK_SCOPE;     }
"\$upscope"         { return TOK_UPSCOPE;   }
"\$var"             { return TOK_VAR;       }
"\$enddefinitions"  { return TOK_ENDDEFS;   }
"\$dumpall"         { return TOK_DUMPALL;   }
"\$dumpoff"         { return TOK_DUMPOFF;   }
"\$dumpon"          { return TOK_DUMPON;    }
"\$dumpvars"        { return TOK_DUMPVARS;  }
"\$end"             { return TOK_END;       }
<IGNORE>"\$end"     { yy_pop_state(); return TOK_END;   }

<IGNORE>.|\n         ;
<VAR_BODY>#[0-9]+       { yylval.num = atoi(yytext + 1); return TOK_TIME;   }
<VAR_BODY>[bB][01xXzZ]+ { yylval.str = strdup(yytext + 1); return TOK_BVEC;     }
<VAR_BODY>[01xXzZ]      { yylval.ch = yytext[0]; return TOK_SCALAR;         }
\[[0-9]+\]          { return TOK_BIT;                                   }
\[[0-9]+:[0-9]+\]   { return TOK_BITS;                                  }
[0-9]+([munpf]?s)   { yylval.num = atoi(yytext); return TOK_TIMEUNIT;   }
[0-9]+              { yylval.num = atoi(yytext); return NUMBER;         }
[a-wyA-WY_!"#$%&'()*+,\-.\/:;<=>?@\[\\\]^_`{|}~]+ {
                        yylval.str = strdup(yytext);
                        return TOK_ID;
                    }
<INITIAL,VAR_BODY>[ \t\r\n]           ; // Skip whitespace
%%
void set_state(int s) {
    switch(s) {
        case 0:
            BEGIN(INITIAL);
            break;
        case 1:
            BEGIN(IGNORE);
            break;
        case 2:
            BEGIN(VAR_BODY);
            break;
    }
}
int yywrap() {
    return 1;
}