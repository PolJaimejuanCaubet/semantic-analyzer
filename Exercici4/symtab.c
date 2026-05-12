#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "symtab.h"

static Scope stack[MAX_SCOPES];
static int   top     = -1;
static int   next_id = 0;

int formula_ok = 1;


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

int  scope_depth(void) { return top; }
void scope_pop_to(int d) { while (top > d) scope_pop(); }
void scope_reset(void)   { top = -1; next_id = 0; }


static Entry *lookup(const char *name)
{
    for (int i = top; i >= 0; i--)
        for (int j = 0; j < stack[i].count; j++)
            if (strcmp(stack[i].entries[j].name, name) == 0)
                return &stack[i].entries[j];
    return NULL;
}

static Entry *define_here(const char *name, EntryKind kind, int arity, int type)
{
    Scope *s = &stack[top];
    if (s->count >= MAX_ENTRIES) { fprintf(stderr, "Error: àmbit ple\n"); return NULL; }
    Entry *e = &s->entries[s->count++];
    strncpy(e->name, name, MAX_NAME - 1);
    e->name[MAX_NAME - 1] = '\0';
    e->kind  = kind;
    e->arity = arity;
    e->type  = type;
    memset(e->param_types, 0, sizeof(e->param_types));
    return e;
}

static int is_var_name(const char *n)
{
    if (n[0] != 'x' || n[1] == '\0') return 0;
    for (int i = 1; n[i]; i++)
        if (n[i] < '0' || n[i] > '9') return 0;
    return 1;
}


void add_variable(const char *name, int type, int lineno)
{
    Entry *e = lookup(name);
    if (e && e->kind == K_VARIABLE) {
        formula_ok = 0;
        printf("ERROR Semàntic Línia %d\n", lineno);
        printf("Redefinició Variable Quantificada %s\n", name);
        return;
    }
    Entry *ne = define_here(name, K_VARIABLE, 0, type);
    if (ne) printf("Crea variable %s\tTipus %d\n", name, type);
}


void add_variables(const NameList *nl, int type, int lineno)
{
    printf("%d Variables Quantificades de tipus %d:\n", nl->count, type);
    for (int i = 0; i < nl->count; i++)
        add_variable(nl->names[i], type, lineno);
}



void add_constant(const char *name, int type, int lineno)
{
    Entry *e = lookup(name);
    if (e == NULL) {
        Entry *ne = define_here(name, K_CONSTANT, 0, type);
        if (ne) printf("Crea constant %s\tTipus %d\n", name, type);
    } else if (e->kind == K_CONSTANT) {
        if (e->type != type) {
            formula_ok = 0;
            printf("ERROR semàntic Línia %d\n", lineno);
            printf("Redefinició de constant %s de tipus %d a nou tipus: %d\n",
                   name, e->type, type);
        }
    }
}


int get_id_type(const char *name, int lineno)
{
    Entry *e = lookup(name);
    if (e != NULL) return e->type;   

    if (is_var_name(name)) {
        formula_ok = 0;
        printf("ERROR semàntic. Variable LLIURE: %s  Línea %d\n", name, lineno);
    } else {
        formula_ok = 0;
        printf("ERROR semàntic Línia %d\n", lineno);
        printf("Constant sense tipus: %s\n", name);
    }
    define_here(name, K_CONSTANT, 0, 0);
    return 0;
}


void add_predicate(const char *name, const TypeList *tl, int lineno)
{
    int arity      = tl ? tl->count : 0;
    const int *pts = tl ? tl->types : NULL;

    Entry *e = lookup(name);
    if (e == NULL) {
        Entry *ne = define_here(name, K_PREDICATE, arity, 0);
        if (ne && pts)
            for (int i = 0; i < arity; i++) ne->param_types[i] = pts[i];
        printf("Crea predicat %s\tAritat %d\n", name, arity);
        return;
    }
    if (e->arity != arity) {
        formula_ok = 0;
        printf("ERROR Semàntic Línia %d\n", lineno);
        printf("Redefinició Predicat %s amb aritat %d a aritat %d\n",
               name, e->arity, arity);
        return;
    }
    for (int i = 0; i < arity; i++) {
        int old_t = e->param_types[i];
        int new_t = pts ? pts[i] : 0;
        if (old_t != 0 && new_t != 0 && old_t != new_t) {
            formula_ok = 0;
            printf("ERROR Semàntic Línia %d\n", lineno);
            printf("Redefinició Predicat %s amb aritat %d. Terme %d definit com %d i redefinit a %d\n",
                   name, arity, i, old_t, new_t);
            return;
        }
    }
}


int add_function(const char *name, const TypeList *tl, int ret_type, int lineno)
{
    int arity      = tl ? tl->count : 0;
    const int *pts = tl ? tl->types : NULL;

    Entry *e = lookup(name);
    if (e == NULL) {
        Entry *ne = define_here(name, K_FUNCTION, arity, ret_type);
        if (ne && pts)
            for (int i = 0; i < arity; i++) ne->param_types[i] = pts[i];
        printf("Crea funció %s\tAritat %d Tipus retorn %d\n", name, arity, ret_type);
        return ret_type;
    }
    if (e->arity != arity) {
        formula_ok = 0;
        printf("ERROR Semàntic Línia %d\n", lineno);
        printf("Redefinició Funció %s amb aritat %d a aritat %d\n",
               name, e->arity, arity);
        return e->type;
    }
    for (int i = 0; i < arity; i++) {
        int old_t = e->param_types[i];
        int new_t = pts ? pts[i] : 0;
        if (old_t != 0 && new_t != 0 && old_t != new_t) {
            formula_ok = 0;
            printf("ERROR Semàntic Línia %d\n", lineno);
            printf("Redefinició Funció %s amb aritat %d. Terme %d definit com %d i redefinit a %d\n",
                   name, arity, i, old_t, new_t);
            return e->type;
        }
    }
    return e->type;
}

int check_function(const char *name, const TypeList *tl, int lineno)
{
    int arity      = tl ? tl->count : 0;
    const int *pts = tl ? tl->types : NULL;

    Entry *e = lookup(name);
    if (e == NULL) {
        /* first occurrence without return type: error */
        formula_ok = 0;
        printf("ERROR Semàntic Línia %d\n", lineno);
        printf("Definició de funció %s sense tipus\n", name);
        define_here(name, K_FUNCTION, arity, 0);
        return 0;
    }
    if (e->arity != arity) {
        formula_ok = 0;
        printf("ERROR Semàntic Línia %d\n", lineno);
        printf("Redefinició Funció %s amb aritat %d a aritat %d\n",
               name, e->arity, arity);
        return e->type;
    }
    for (int i = 0; i < arity; i++) {
        int old_t = e->param_types[i];
        int new_t = pts ? pts[i] : 0;
        if (old_t != 0 && new_t != 0 && old_t != new_t) {
            formula_ok = 0;
            printf("ERROR Semàntic Línia %d\n", lineno);
            printf("Redefinició Funció %s amb aritat %d. Terme %d definit com %d i redefinit a %d\n",
                   name, arity, i, old_t, new_t);
            return e->type;
        }
    }
    return e->type;
}
