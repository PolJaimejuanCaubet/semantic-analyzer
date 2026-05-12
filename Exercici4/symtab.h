#ifndef SYMTAB_H
#define SYMTAB_H

#define MAX_NAME    128
#define MAX_ARGS    16
#define MAX_ENTRIES 256
#define MAX_SCOPES  64

typedef enum { K_VARIABLE, K_CONSTANT, K_PREDICATE, K_FUNCTION } EntryKind;

typedef struct {
    char      name[MAX_NAME];
    EntryKind kind;
    int       arity;
    int       type;                   
    int       param_types[MAX_ARGS]; 
} Entry;

typedef struct {
    int   id;
    Entry entries[MAX_ENTRIES];
    int   count;
} Scope;

typedef struct {
    int types[MAX_ARGS];
    int count;
} TypeList;

typedef struct {
    char names[MAX_ARGS][MAX_NAME];
    int  count;
} NameList;

extern int formula_ok;

int  scope_push(void);
void scope_pop(void);
int  scope_depth(void);
void scope_pop_to(int depth);
void scope_reset(void);

void add_variable  (const char *name, int type, int lineno);
void add_constant  (const char *name, int type, int lineno);
int  get_id_type   (const char *name, int lineno);  /* returns type or 0 */
void add_variables (const NameList *nl, int type, int lineno); /* ex.4: compact list */

void add_predicate  (const char *name, const TypeList *tl, int lineno);
int  add_function   (const char *name, const TypeList *tl, int ret_type, int lineno);
int  check_function (const char *name, const TypeList *tl, int lineno);

#endif
