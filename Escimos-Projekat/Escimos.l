%option noyywrap yylineno

%{
   #include <string.h>
   #include "Escimos.tab.h"
   #include "defs.h"
   extern YYSTYPE yylval;
%}

%%

[ \t\n]+             { /* skip */ }


"int"                { yylval.i = INT;  return _TYPE; }
"unsigned"           { yylval.i = UINT; return _TYPE; }
"vacant"	     { yylval.i = VACANT; return _TYPE; }
"if"                 { return _IF; }
"else"               { return _ELSE; }
"return"             { return _RETURN; }
"fun"                { return _FUN; } 
"para" 		     { return _PARA; } 
"switch" 	     { return _SWITCH; }
"break"		     { return _BREAK; }
"otherwise"	     { return _OTHERWISE; }
"case" 		     { return _CASE; }

"("                  { return _LPAREN; }
")"                  { return _RPAREN; }
"{"                  { return _LBRACKET; }
"}"                  { return _RBRACKET; }
";"                  { return _SEMICOLON; }
"="                  { return _ASSIGN; }
","		     { return _COMMA; }
"++" 		     { return _INC; }
":"                  { return _COLON; }
"=>"	 	     { return _POINTER; } 



"+"                  { yylval.i = ADD; return _AROP; }
"-"                  { yylval.i = SUB; return _AROP; }
"*" 		     { yylval.i = MUL; return _AROP; }
"/"		     { yylval.i = DIV; return _AROP; }


"<"                  { yylval.i = LT; return _RELOP; }
">"                  { yylval.i = GT; return _RELOP; }
"<="                 { yylval.i = LE; return _RELOP; }
">="                 { yylval.i = GE; return _RELOP; }
"=="                 { yylval.i = EQ; return _RELOP; }
"!="                 { yylval.i = NE; return _RELOP; }

[a-zA-Z][a-zA-Z0-9]* { yylval.s = strdup(yytext); 
                       return _ID; }
[+-]?[0-9]{1,10}     { yylval.s = strdup(yytext); 
                       return _INT_NUMBER;}
[0-9]{1,10}[uU]      { yylval.s = strdup(yytext); 
                       yylval.s[yyleng-1] = 0;
                       return _UINT_NUMBER;}

\/\/.*               { /* skip */ }


"/*" { /*blok komentar, stackoverflow*/
       int c1 = 0, c2 = input();
       for(;;) {
         if(c2 == EOF) break;
         if(c1 == '*' && c2 == '/')
           break;
         c1 = c2;
         c2 = input();
       }
     }

.                    { printf("line %d: LEXICAL ERROR on char %c\n", yylineno, *yytext);}
%%
