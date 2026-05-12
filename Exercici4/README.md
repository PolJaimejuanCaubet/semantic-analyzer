# Exercici 4 — Definició compacta de variables amb tipus a les fórmules de CP1

Extensió de l'Exercici 3 amb una notació compacta per definir múltiples variables
del mateix tipus en un sol quantificador.
Implementat amb **flex** i **bison** (C).

## Fitxers

| Fitxer | Descripció |
|--------|------------|
| `cp1.l` | Especificació lèxica (flex) — sense canvis respecte ex. 3 |
| `cp1.y` | Gramàtica estesa amb la regla `varlist` i noves alternatives a `quant_f` |
| `symtab.c/h` | Taula de símbols estesa amb `NameList` i `add_variables` |
| `Makefile` | Compilació |
| `tests/` | Jocs de prova |

## Compilació i ús

```bash
make
./cp1 formula.cp1
make test
```

## Notació compacta de variables

L'exercici 3 requeria declarar cada variable per separat:

```
forall x1:int forall x2:int forall x3:int exists x4:char exists x5:char
    (P1(x1, x2, x3) -> P2(x4, x5));
```

L'exercici 4 permet agrupar variables del mateix tipus amb comes:

```
forall x1, x2, x3:int exists x4, x5:char
    (P1(x1, x2, x3) -> P2(x4, x5));
```

Totes les variables de la llista comparteixen el tipus anotat al final.
La sintaxi antiga (una sola variable per quantificador) continua sent vàlida.

## Sistema de tipus

### Tipus bàsics

| ID | Lexema |
|----|--------|
| 1  | `bool` |
| 2  | `char` |
| 3  | `int`  |
| 4  | `real` |

### Sintaxi d'anotació de tipus

```
forall x1, x2, x3:int exists x4, x5:char (P1(x1, x2, x3) -> P2(x4, x5));
forall x1:int exists x2:real (P1(f1(x1, x2):real) -> P2(f2(x2):int));
P1( f1(a1:int):int, f2(a1, b2:char):char );
```

- **Variables (llista compacta)**: `forall x1, x2, x3:TYPE` — totes prenen el mateix tipus
- **Variables (individual)**: `forall x:TYPE` / `exists x:TYPE` — sintaxi original
- **Constants**: `a1:int` — obligatori a la primera aparició; reutilització sense tipus
- **Funcions**: `f1(args):TYPE_RETORN` — el tipus de retorn s'especifica a la primera aparició
- **Predicats**: `P1(args)` — sense tipus de retorn (sempre Boolean)

## Canvis respecte l'Exercici 3

### `symtab.h`
- Nova estructura `NameList` (array de noms + comptador) per passar llistes de variables des del parser.
- Nova funció `add_variables(const NameList *nl, int type, int lineno)`.

### `symtab.c`
- Implementació de `add_variables`: imprimeix el resum i crida `add_variable` per cada nom,
  reutilitzant tota la lògica de comprovació de redefinicions.

### `cp1.y`
- `NameList nl` afegit al `%union`.
- Nou no-terminal `varlist` (`%type <nl>`): recull `x1, x2, ...` com a llista de noms (mínim 2 IDs).
- Dues noves alternatives a `quant_f` per a `FORALL varlist COLON TYPE` i `EXISTS varlist COLON TYPE`.

## Sortida

```
Empila àmbit ID 1
3 Variables Quantificades de tipus 3:
Crea variable x1    Tipus 3
Crea variable x2    Tipus 3
Crea variable x3    Tipus 3
Empila àmbit ID 2
2 Variables Quantificades de tipus 2:
Crea variable x4    Tipus 2
Crea variable x5    Tipus 2
...
```

Fórmula correcta:   `Fórmula CP1 Correcta Línia N`
Fórmula incorrecta: `ERROR Fórmula INCORRECTA Línia N`

### Comprovacions semàntiques (heretades de l'ex. 3)

| Error | Missatge |
|-------|---------|
| Variable lliure | `ERROR semàntic. Variable LLIURE: x Línea N` |
| Variable re-quantificada | `Redefinició Variable Quantificada x` |
| Predicat aritat | `Redefinició Predicat P amb aritat M a aritat N` |
| Predicat tipus paràmetre | `Redefinició Predicat P amb aritat N. Terme I definit com T1 i redefinit a T2` |
| Funció aritat | `Redefinició Funció f amb aritat M a aritat N` |
| Funció tipus paràmetre | `Redefinició Funció f amb aritat N. Terme I definit com T1 i redefinit a T2` |
| Funció sense tipus retorn | `Definició de funció f sense tipus` |
| Constant redefinida | `Redefinició de constant a de tipus T1 a nou tipus: T2` |
| Constant sense tipus | `Constant sense tipus: a` |
