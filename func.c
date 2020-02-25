#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include "AsTree.h"

int NXQ=1;
int Tempcount=0;
static unsigned symhash(char *sym)
{
    unsigned int hash = 0;
    unsigned c;

    while(c = *sym++) hash = hash*9 ^ c;

    return hash;
}


int lookup(char* sym)
{

    struct symbol *sp = &symtab[symhash(sym)%NHASH];
    int tmp=symhash(sym)%NHASH;
    int scount = NHASH;
    while(--scount >= 0)
    {
        if(strcmp(sp->name,"") && !strcmp(sp->name, sym))
        {
            return tmp;
        }

        if(!strcmp(sp->name,""))
        {
            strcpy(sp->name,sym);
            sp->value = 0;
            sp->type = 0;
            sp->func = NULL;
            sp->syms = NULL;
            return tmp;
        }

        if(++sp >= symtab+NHASH)
            sp = symtab;
        if(++tmp >= NHASH)
            tmp = 0;
    }
    abort();

}


int NewTemp()
{
    char temp[4];
    char num[3];
    Tempcount++;
    strcpy(temp,"T");
    strcat(temp,itoa(Tempcount, num, 10));
    return lookup(temp);
}

void GEN(char* op, int arg1, int arg2, int result)
{
    strcpy(QuadrupleList[NXQ].op,op);
    QuadrupleList[NXQ].arg1 = arg1;
    QuadrupleList[NXQ].arg2 = arg2;
    QuadrupleList[NXQ].result = result;
    NXQ++;
}

int Merge(int p1, int p2)
{
    int p;
    if(!p2)
        return p1;
    else
    {
        p=p2;
        while(QuadrupleList[p].result)
            p = QuadrupleList[p].result;
        QuadrupleList[p].result=p1;
        return p2;
    }
}

void Backpatch(int p, int t)
{
    int q=p;
    while(q)
    {
        int q1 = QuadrupleList[q].result;
        QuadrupleList[q].result = t;
        q=q1;
    }
}


struct symlist *newsymlist(struct symbol *sym, struct symlist *next)
{
    struct symlist *sl = malloc(sizeof(struct symlist));
    sl->sym = sym;
    sl->next = next;
    return sl;
}

void symlistfree(struct symlist *sl)
{
    struct symlist *nsl;

    while(sl)
    {
        nsl = sl->next;
        free(sl);
        sl = nsl;
    }
}


struct ast *newast(int nodetype, struct ast *l, struct ast *r)
{
    struct ast *a = malloc(sizeof(struct ast));
    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

void OutputAst(struct ast *a)
{
    return;
    if(!a)
        return;
    switch(a->nodetype)
    {
        case 'S': printf("Statement\n"); break;
        case '=': printf("=\n"); break;
        case 'I': printf("if\n"); break;
        case 'C': printf("condition\n"); break;
        case 'W': printf("while\n"); break;
        case '+': printf("+\n"); break;
        case '-': printf("-\n"); break;
        case '*': printf("*\n"); break;
        case '/': printf("/\n"); break;
        case 'M': printf("Minus\n"); break;
        case 'B': printf("BoolExpr\n"); break;
        case 'P': printf("Compare\n"); break;
        case 'A': printf("&&\n"); break;
        case 'O': printf("||\n"); break;
        case 'N': printf("Num\n"); break;
        case 'V': printf("Variable\n"); break;
    }
    OutputAst(a->l);
    OutputAst(a->r);

}

void treefree(struct ast *a)
{
    return;
    if(a){
    treefree(a->l);
    treefree(a->r);
    free(a);}
}

void yyerror(char *s, ...)
{
  fprintf(stderr, "%d: error: ", yylineno);
  fprintf(stderr, "\n");
}
