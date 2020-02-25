%{
#  include <stdio.h>
#  include <stdlib.h>
#  include "AsTree.h"
%}

%union {
  struct ast *a;
  double doublevalue;
  struct symbol *s;		/* which symbol */
  struct symlist *sl;
  int cmpfn;
}

%token <s> Var
%token <s> NUM

%token IF ELSE WHILE FLOAT INT

%left 	Or
%left	And
%nonassoc  	Not
%nonassoc <cmpfn> CMP
%left  '+' '-'
%left  '*' '/'
%left  NEG
%nonassoc UMINUS

%type <a> StatementSet
%type <a> Statement
%type <a> IE
%type <a> CondStElse
%type <a> Expr
%type <a> explist
%type <a> AssS
%type <a> ConditionS
%type <a> Condition
%type <a> Condition1
%type <a> Condition2
%type <a> CircleS
%type <a> W1
%type <a> WED
%type <a> DecS


%type <sl> symlist
%start Program

%%


Program: /* nothing */
  | Program Statement {
    OutputAst($2);
    treefree($2);}
;

StatementSet: /* nothing */ {
    $$ = NULL; }
   | Statement StatementSet {
    if($1==NULL){
        $$=$2;
     }else{
     $$=newast('S',$1,$2);}}
;

Statement : AssS ';' {
    $$=$1;
    $$->chain=0;}
    | ConditionS {
    $$=$1;
    Backpatch($1->chain,NXQ); }
    | CircleS {
    $$=$1;
    Backpatch($1->chain,NXQ); }
    | DecS {
    $$=$1;}
;

AssS : Var '=' Expr {
    $$=newast('=',NULL,$3);
    GEN("=",$3->place,0,lookup($1->name));}
    | Var '(' explist ')' {
    $$ = $3;}
;


ConditionS :IE '{' Statement '}' {
            $$=newast('I',$1,$3);
            $$->chain = Merge($1->chain, $3->chain); }
          | CondStElse '{' Statement '}' {
            $$=newast('I',$1,$3);
            $$->chain = Merge($1->chain, $3->chain); }
;

IE: IF Condition{
    $$=newast('C',NULL,$2);
    Backpatch($2->TC, NXQ);
    $$->chain=$2->FC; }
;

CondStElse: IE '{'Statement '}' ELSE{
            $$=newast('C',$1,$3);
			int q=NXQ;
			GEN("j", 0, 0, 0);
			Backpatch($1->chain, NXQ);
			$$->chain = Merge($3->chain, q); }
;

CircleS : WED '{' StatementSet '}'{
    $$=newast('W',$1,$3);
    Backpatch($3->chain,$1->place);
    GEN("j",0,0,$1->place);
    $$->chain =$1->chain;
}
;
WED : W1 Condition {
    $$=newast('C',$1,$2);
    Backpatch($2->TC,NXQ);
    $$->chain=$2->FC;
    $$->place=$1->place; }
;
W1 :WHILE{
    $$=newast('W',NULL,NULL);
    $$->place=NXQ;}
;

DecS : INT Var ';' {
       $2->type = 1; }
     | FLOAT Var ';'{
       $2->type = 2; }
;

Expr: Expr '+' Expr           { $$ = newast('+', $1, $3);
                                $$->place=NewTemp();
                                GEN("+",$1->place,$3->place,$$->place); }
    | Expr '-' Expr           { $$ = newast('-', $1, $3);
                                $$->place=NewTemp();
                                GEN("-",$1->place,$3->place,$$->place); }
    | Expr '*' Expr           { $$ = newast('*', $1, $3);
                                $$->place=NewTemp();
                                GEN("*",$1->place,$3->place,$$->place); }
    | Expr '/' Expr           { $$ = newast('/', $1, $3);
                                $$->place=NewTemp();
                                GEN("/",$1->place,$3->place,$$->place); }
    | '(' Expr ')'            { $$ = $2; }
    | '-' Expr %prec UMINUS   { $$ = newast('M', $2, NULL);
                                $$->place=NewTemp();
                                GEN("-", $2->place, 0, $$->place); }
    | NUM                     {
                                $$=newast('N',NULL,NULL);
                                $$->place = lookup($1->name);}
    | Var                     {
                                $$=newast('V',NULL,NULL);
                                $$->place = lookup($1->name);
                                }
;

Condition: Condition1 Condition    { $$=newast('B',$1,$2);
                                     $$->TC = $2->TC;$$->FC=Merge($1->FC,$2->FC);}
    | Condition2 Condition         { $$=newast('B',$1,$2);
                                     $$->FC = $2->FC;$$->TC=Merge($1->TC,$2->TC);}
    | '!' Condition           { $$=newast('B',NULL,$2);
                                $$->TC = $2->FC;
                                $$->FC = $2->TC;}
    | Expr                    {
                                $$=$1;
                                $$->TC = NXQ;
                                $$->FC = NXQ+1;
                                GEN("jnz", $1->place, 0, 0);
                                GEN("j", 0, 0, 0); }
    | Expr CMP Expr           {
                                $$=newast('P',$1,$3);
                                $$->TC = NXQ;
                                $$->FC = NXQ+1;
                                if($2==1)
                                GEN("j>", $1->place, $3->place, 0);
                                else if($2==2)
                                GEN("j<", $1->place, $3->place, 0);
                                else if($2==3)
                                GEN("j<>", $1->place, $3->place, 0);
                                else if($2==4)
                                GEN("j==", $1->place, $3->place, 0);
                                else if($2==5)
                                GEN("j>=", $1->place, $3->place, 0);
                                else if($2==6)
                                GEN("j<=", $1->place, $3->place, 0);
                                GEN("j", 0, 0, 0);}
    | '(' Condition ')'       { $$=$2;
                                $$->TC = $2->TC;
                                $$->FC = $2->FC;}
;

Condition1 :Condition And { $$=newast('A',NULL,$1);
                            Backpatch($1->TC, NXQ);
                            $$->FC = $1->FC; }
;
Condition2 :Condition Or { $$=newast('O',NULL,$1);
                           Backpatch($1->FC, NXQ);
                           $$->TC = $1->TC;}
;

explist: Expr
    | Expr ',' explist{
    $$ = newast('L', $1, $3); }
;

symlist: INT Var          {}
    | INT Var ',' symlist {}
;


%%
