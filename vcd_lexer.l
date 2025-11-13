%{
#include "vcd.tab.h"
#include <string.h>
%}

%%
"\\$date"           { return TOK_DATE;      }
"\\$version"        { return TOK_VER;       }
"\\$timescale"      { return TOK_TS;        }
"\\$scope"          { return TOK_SCOPE;     }
"\\$upscope"        { return TOK_UPSCOPE;   }
"\\$var"            { return TOK_VAR;       }
"\\$enddefinitions" { return TOK_ENDDEFS;   }
"\\$definitions"    { return TOK_DEF;       }

#[0-9]+             { yylval.num = atoi(yytext + 1); return TOK_TIME;   }
[bB][01xXzZ]+       { yylval.str = strdup(yytext); return TOK_BVAL;     }
[01xXzZ]            { yylval.ch = yytext[0]; return TOK_SCALAR;         }

[a-zA-Z0-9_!\"#$%&'()*+,\-./:;<=>?@\[\\\]^_`{|}~]+ {
                        yylval.str = strdup(yytext);
                        return TOK_ID:
                    }