#include <stdio.h>
#include <string.h>
#include "symtab.h"

static Scope stack[MAX_SCOPES];
static int   top     = -1;
static int   next_id = 0;

int formula_ok = 1;

/* ── scope management ──────────────────────────────────────────────────────── */

int scope_push(void)
{
    if (top + 1 >= MAX_SCOPES) { fprintf(stderr, "Error: massa àmbits\n"); return -1; }
    top++;
    stack[top].id    = next_id;
    stack[top].count = 0;
    printf("Empila àmbit ID %d\n", next_id);
    return next_id++;
}

void scope_pop(void)
{
    if (top < 0) return;
    printf("Desempila àmbit ID %d\n", stack[top].id);
    top--;
}

int scope_depth(void) { return top; }

void scope_pop_to(int depth)
{
    while (top > depth) scope_pop();
}

void scope_reset(void)
{
    top     = -1;
    next_id = 0;
}

/* ── internal lookup ───────────────────────────────────────────────────────── */

static Entry *lookup(const char *name)
{
    for (int i = top; i >= 0; i--)
        for (int j = 0; j < stack[i].count; j++)
            if (strcmp(stack[i].entries[j].name, name) == 0)
                return &stack[i].entries[j];
    return NULL;
}

static Entry *define_here(const char *name, EntryKind kind, int arity)
{
    Scope *s = &stack[top];
    if (s->count >= MAX_ENTRIES) { fprintf(stderr, "Error: àmbit ple\n"); return NULL; }
    Entry *e = &s->entries[s->count++];
    strncpy(e->name, name, MAX_NAME - 1);
    e->name[MAX_NAME - 1] = '\0';
    e->kind  = kind;
    e->arity = arity;
    return e;
}

/* ── public semantic actions ───────────────────────────────────────────────── */

void add_variable(const char *name, int lineno)
{
    Entry *e = lookup(name);
    if (e && e->kind == K_VARIABLE) {
        formula_ok = 0;
        printf("ERROR Semàntic Línia %d\n", lineno);
        printf("Redefinició Variable Quantificada %s\n", name);
        return;
    }
    define_here(name, K_VARIABLE, 0);
    printf("Crea variable %s\n", name);
}

void add_predicate(const char *name, int arity, int lineno)
{
    Entry *e = lookup(name);
    if (e == NULL) {
        define_here(name, K_PREDICATE, arity);
        printf("Crea predicat %s\tAritat %d\n", name, arity);
    } else if (e->arity != arity) {
        formula_ok = 0;
        printf("ERROR Semàntic Línia %d\n", lineno);
        printf("Redefinició Predicat %s amb aritat %d a aritat %d\n",
               name, e->arity, arity);
    }
}

void add_function(const char *name, int arity, int lineno)
{
    Entry *e = lookup(name);
    if (e == NULL) {
        define_here(name, K_FUNCTION, arity);
        printf("Crea predicat %s\tAritat %d\n", name, arity);
    } else if (e->arity != arity) {
        formula_ok = 0;
        printf("ERROR Semàntic Línia %d\n", lineno);
        printf("Redefinició Funcio %s amb aritat %d a nova aritat %d\n",
               name, e->arity, arity);
    }
}

/* An unqualified ID in term position is either a bound variable (found in scope)
   or a constant.  Names matching x[0-9]+ that are NOT in scope are free variables. */
static int is_var_name(const char *n)
{
    if (n[0] != 'x' || n[1] == '\0') return 0;
    for (int i = 1; n[i]; i++)
        if (n[i] < '0' || n[i] > '9') return 0;
    return 1;
}

void use_term_id(const char *name, int lineno)
{
    if (lookup(name)) return;          /* bound variable or known constant */

    if (is_var_name(name)) {
        formula_ok = 0;
        printf("ERROR semàntic. Variable LLIURE: %s  Línea %d\n", name, lineno);
        /* define here so duplicate occurrences don't fire again */
        define_here(name, K_CONSTANT, 0);
    } else {
        define_here(name, K_CONSTANT, 0);   /* new constant – silent */
    }
}
