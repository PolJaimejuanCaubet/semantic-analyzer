# Exercici 3 — Definició i gestió de tipus a les fórmules de CP1

Extensió de l'Exercici 2 amb un sistema de tipus estàtic per a les fórmules de CP1.
Implementat amb **flex** i **bison** (C).

## Fitxers

| Fitxer | Descripció |
|--------|------------|
| `cp1.l` | Especificació lèxica (flex) — afegeix `:` i tipus |
| `cp1.y` | Gramàtica i accions semàntiques amb tipus (bison) |
| `symtab.c/h` | Taula de símbols amb tipus per a cada entrada |
| `Makefile` | Compilació |
| `tests/` | Jocs de prova |

## Compilació i ús

```bash
make
./cp1 formula.cp1
make test
```

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
forall x1:int exists x2:real (P1(x1, x2) -> P2(x2));
P1( f1(a1:int):int, f2(a1, b2:char):char );
```

- **Variables** (quantificadors): `forall x:TYPE` / `exists x:TYPE` — obligatori
- **Constants**: `a1:int` — obligatori a la primera aparició; reutilització sense tipus
- **Funcions**: `f1(args):TYPE_RETORN` — el tipus de retorn s'especifica a la primera aparició
- **Predicats**: `P1(args)` — sense tipus de retorn (sempre Boolean)

### Comprovacions semàntiques

| Error | Missatge |
|-------|---------|
| Variable lliure | `ERROR semàntic. Variable LLIURE: x Línea N` |
| Predicat aritat | `Redefinició Predicat P amb aritat M a aritat N` |
| Predicat tipus paràmetre | `Redefinició Predicat P amb aritat N. Terme I definit com T1 i redefinit a T2` |
| Funció aritat | `Redefinició Funció f amb aritat M a aritat N` |
| Funció tipus paràmetre | `Redefinició Funció f amb aritat N. Terme I definit com T1 i redefinit a T2` |
| Funció sense tipus retorn | `Definició de funció f sense tipus` |
| Constant redefinida | `Redefinició de constant a de tipus T1 a nou tipus: T2` |
| Constant sense tipus | `Constant sense tipus: a` |
| Variable re-quantificada | `Redefinició Variable Quantificada x` |

## Sortida

```
Crea variable x1    Tipus 3
Crea constant a1    Tipus 3
Crea funció f1      Aritat 2 Tipus retorn 4
Crea predicat P1    Aritat 2
```

Fórmula correcta:  `Fórmula CP1 Correcta Línia N`
Fórmula incorrecta: `ERROR Fórmula INCORRECTA Línia N`
