struct symbol  		/* a variable name */
{
    char name[4];
    double value;
    int type;
    struct ast *func;	/* stmt for the function */
    struct symlist *syms; /* list of dummy args */
    int place;
};
struct symlist
{
    struct symbol *sym;
    struct symlist *next;
};


struct Quadruple
{
    char op[6];
    int arg1;
    int arg2;
    int result;
};
#define NHASH 9997


struct symbol symtab[NHASH];

struct Quadruple QuadrupleList[NHASH];

int lookup(char* sym);

struct symlist *newsymlist(struct symbol *sym, struct symlist *next);

void symlistfree(struct symlist *sl);

struct ast
{
    int nodetype;
    struct ast *l;
    struct ast *r;
    int TC;
    int FC;
    int chain;
    int place;
};


struct ast *newast(int nodetype, struct ast *l, struct ast *r);

void OutputAst(struct ast *a);

void def(struct symbol *name, struct symlist *syms, struct ast *statements);


void treefree(struct ast *a);

void yyerror(char *s, ...);

extern int yylineno;

extern int NXQ;
extern int Tempcount;
