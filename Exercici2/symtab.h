#ifndef SYMTAB_H
#define SYMTAB_H

#define MAX_NAME    128
#define MAX_ENTRIES 256
#define MAX_SCOPES  64

typedef enum { K_VARIABLE, K_CONSTANT, K_PREDICATE, K_FUNCTION } EntryKind;

typedef struct {
    char      name[MAX_NAME];
    EntryKind kind;
    int       arity;
} Entry;

typedef struct {
    int   id;
    Entry entries[MAX_ENTRIES];
    int   count;
} Scope;

extern int formula_ok;

int  scope_push(void);
void scope_pop(void);
int  scope_depth(void);
void scope_pop_to(int depth);
void scope_reset(void);

void add_variable (const char *name, int lineno);
void add_predicate(const char *name, int arity, int lineno);
void add_function (const char *name, int arity, int lineno);
void use_term_id  (const char *name, int lineno);

#endif
