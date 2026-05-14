# Mini Calculadora

## Característiques

La calculadora suporta:

- Operacions aritmètiques:
  - `+`
  - `-`
  - `*`
  - `/`
  - `%`

- Operadors relacionals:
  - `<`
  - `>`
  - `<=`
  - `>=`
  - `==`
  - `!=`

- Operadors lògics:
  - `&&`
  - `||`
  - `!`

- Assignació de variables:

```txt
x = 10;
```

- Expressions condicionals tipus ternari:

```txt
(condicio) ? expressio1 : expressio2;
```

- Comentaris d'una línia:

```txt
// Això és un comentari
```

---

# Compilació


## Compilar el projecte

```bash
make
```

Això generarà l'executable:

```txt
calc
```

---

# Executar la calculadora

## Mode interactiu

```bash
./calc
```

Exemple:

```txt
2 + 3;
5
```

---

## Executar un fitxer de test

```bash
make test
```

El `Makefile` llegeix el fitxer:

```txt
tests/test.txt
```

---
