# Exercici 2 — Anàlisi semàntica de les fórmules de CP1

Analitzador lèxic, sintàctic i semàntic per a fórmules de la lògica de predicats de primer ordre (CP1).
Implementat amb **flex** (anàlisi lèxica) i **bison** (anàlisi sintàctica + semàntica), generant codi C.

## Fitxers

| Fitxer | Descripció |
|--------|------------|
| `cp1.l` | Especificació lèxica (flex) |
| `cp1.y` | Gramàtica i accions semàntiques (bison) |
| `symtab.c/h` | Taula de símbols amb pila d'àmbits |
| `Makefile` | Compilació |
| `tests/` | Jocs de prova |

## Compilació i ús

```bash
make          # genera l'executable cp1
./cp1 formula.cp1
./cp1 < formula.cp1
make test     # executa tots els tests
```

## Característiques implementades

### Anàlisi lèxica
- Paraules reservades: `forall`, `exists`, `and`, `or`
- Operadors: `->` (implica), `<->` (bicondicional), `!` / `¬` (negació)
- Identificadors: `[a-zA-Z_][a-zA-Z0-9_]*`
- Comentaris de línia: `// ...`

### Gramàtica (precedència de menor a major)
1. `<->` i `->` (associatiu esquerra)
2. `or` (associatiu esquerra)
3. `and` (associatiu esquerra)
4. `forall` / `exists` (associatiu dreta)
5. `!` / `¬` (associatiu dreta)

### Taula de símbols
- Pila d'àmbits: cada fórmula empila un àmbit global (ID 0); cada quantificador empila el seu propi àmbit.
- Els IDs d'àmbit es reinicien a 0 en cada fórmula nova.
- Les entrades (variables, constants, predicats, funcions) es cerquen de l'àmbit interior cap a l'exterior.

### Comprovacions semàntiques
| Error | Descripció |
|-------|------------|
| Variable lliure | Nom `x<digits>` usat com a terme però no quantificat |
| Redefinició de predicat | Mateix nom amb aritat diferent |
| Redefinició de funció | Mateixa funció amb aritat diferent |
| Redefinició de variable | Variable ja quantificada en àmbit actiu |

### Convenció de noms
- **Variables**: noms de la forma `x` seguit de dígits (ex: `x1`, `x2`)
- **Constants**: qualsevol altre identificador minúscul (ex: `a1`, `b2`, `c1`)
- **Predicats**: identificadors que comencen per majúscula (ex: `P1`, `P2`)
- **Funcions**: identificadors de la forma `f<digits>` (ex: `f1`, `f2`)

## Sortida

Per a cada fórmula s'imprimeix:
- Les operacions de la taula de símbols (Empila àmbit, Crea variable, Crea predicat, Desempila àmbit)
- `Fórmula CP1 Correcta Línia N` si és semànticament correcta
- `ERROR Fórmula INCORRECTA Línia N` amb els missatges d'error si no ho és

## Exemples

```
$ ./cp1 tests/test_correct.cp1
Empila àmbit ID 0
Empila àmbit ID 1
Crea variable x1
Empila àmbit ID 2
Crea variable x2
Crea predicat P1    Aritat 2
Crea predicat P2    Aritat 1
Desempila àmbit ID 2
Desempila àmbit ID 1
Desempila àmbit ID 0
Fórmula CP1 Correcta Línia 2
...
```
