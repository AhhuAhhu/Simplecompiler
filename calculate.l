%option noyywrap default yylineno
%{
#include "AsTree.h"
#include "calculate.tab.h"
%}

EXP	([Ee][-+]?[0-9]+)

%%

[+] {return *yytext; }
[-] {return *yytext; }
[*] {return *yytext; }
[/] {return *yytext; }
[=] {return *yytext; }
[,] {return *yytext; }
[;] {return *yytext; }
[(] {return *yytext; }
[)] {return *yytext; }
[{] {return *yytext; }
[}] {return *yytext; }



">"     { yylval.cmpfn = 1;
            return CMP; }
"<"     { yylval.cmpfn = 2;
            return CMP; }
"<>"    { yylval.cmpfn = 3;
            return CMP; }
"=="    { yylval.cmpfn = 4;
            return CMP; }
">="    { yylval.cmpfn = 5;
            return CMP; }
"<="    { yylval.cmpfn = 6;
            return CMP; }
"&&"    { return And;}
"||"    { return Or;}

"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
"int" { return INT; }
"float" { return FLOAT; }
"double" { return FLOAT; }


[a-zA-Z][a-zA-Z0-9]*  { yylval.s = &symtab[lookup(yytext)]; return Var; }

[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}? { yylval.s = &symtab[lookup(yytext)]; return NUM; }

[ \t]
[\n]
.	{ yyerror("Mystery character %c\n", *yytext); };
%%

int main()
{
    printf("> ");
    yyin=fopen("test.txt","r");
    yyparse();
    printf("Parse OK\n");
    int i=1;
    for(i=1;i<NXQ;i++) {
    printf("(%d)(%s, ",i,QuadrupleList[i].op);
    if(QuadrupleList[i].arg1)
    printf("%s, ",symtab[QuadrupleList[i].arg1].name);
    else
    printf(", ");
    if(QuadrupleList[i].arg2)
    printf("%s, ",symtab[QuadrupleList[i].arg2].name);
    else printf(", ");
    if(QuadrupleList[i].op[0]=='j')
    printf("%d )\n",QuadrupleList[i].result);
    else if(QuadrupleList[i].result)
    printf("%s )\n",symtab[QuadrupleList[i].result].name);
    else printf(" )\n");
	}
    printf("OutPutOK\n");
    fclose(yyin);
    return 0;

}
