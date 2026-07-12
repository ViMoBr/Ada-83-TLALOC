# PATCH F-A bis — Retour d'un type PRIVÉ à vue complète SCALAIRE

**11 juillet 2026.** Deux bugs distincts, révélés par `test_calendar` à la
recompilation des unités prédéfinies. **Sans rapport avec le patch F-A** :
F-A lève `PROGRAM_ERROR` à l'EXPANSION, ici le FINC est produit et casse à
l'ASSEMBLAGE. Deux étages différents.

---

## Symptôme

```
CALENDAR.FINC [583]:  LI STANDARD.CALENDAR._TIME.size
Error: symbol 'STANDARD.CALENDAR._TIME.size' is undefined or out of scope.
```

Cinq sites concernés dans CALENDAR (583, 1070, 1103, 1133, 1163) : toutes
les fonctions rendant `TIME`.

---

## Bug n° 1 — `CODE_RETURN` route sur la vue PRIVÉE

`expander-instructions.adb`, `CODE_RETURN`.

La branche composite est sélectionnée sur `EXPR_TYPE.TY = DN_PRIVATE`
(`TIME` est privé). La boucle interne déroule ensuite la vue :

```ada
while  TYPE_SPEC.TY = DN_L_PRIVATE  or  TYPE_SPEC.TY = DN_PRIVATE  loop
  TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
end loop;
```

…obtient `DN_FIXED` — **et continue sans revérifier**, émettant la mécanique
composite : `BLKMOV` + `LI <type>.size`.

Or **`.size` n'est émis que par le chemin record** (bloc `virtual at 0`,
`size = $`). Un fixed n'a que `SIZ` (variable *runtime*, `VAR SIZ, d`).
D'où le symbole indéfini.

**Le test de sélection porte sur la vue privée ; l'émission suppose la vue
complète composite.** Pour un privé sur record : correct. Pour un privé sur
scalaire (`TIME`) : faux.

### Pourquoi ça passait « à l'époque »

Le `else` final porte : *« Trou auparavant SILENCIEUX (cause du segfault
R6) »*. Ce durcissement a ajouté `DN_PRIVATE` / `DN_L_PRIVATE` à la liste
composite — et a **capturé `TIME` au passage**. C'est une régression du
correctif R6, restée latente parce que `test_calendar` n'est pas dans le
filet. Le patch F-A n'a fait que ramener sur ce terrain.

**⇒ À CONSIGNER : `test_calendar` doit entrer dans le filet.**

---

## Bug n° 2 — `EXP_TYPE_CHAR` ne déroule pas le privé

`codi`, `EXP_TYPE_CHAR`.

```ada
EXP_TYPE : TREE := D( SM_EXP_TYPE, EXP );
...
SIZ : NATURAL := DI( CD_IMPL_SIZE, EXP_TYPE );   -- EXP_TYPE = DN_PRIVATE !
```

Grammaire DIANA (`diana_NODES.txt:1250`), le nœud `private` porte
EXACTEMENT :

```
private =>  sm_derived, sm_is_anonymous, sm_discriminant_s,
            sm_type_spec, xd_source_name
```

**Aucun `CD_IMPL_SIZE`.** `DI` lève donc `PROGRAM_ERROR` (confirmé
mainteneur : `DI` est bruyant sur attribut absent, fonction frontend IDL).

Ce bug est **latent aujourd'hui** : le chemin scalaire de `CODE_RETURN`
n'est jamais atteint par un privé (bug n° 1 le détourne vers le composite).
Preuve *a contrario* : si le chemin scalaire avait déjà reçu un privé, `DI`
aurait planté. **Mais corriger le bug n° 1 rend ce chemin atteignable** —
il faut donc corriger les DEUX, dans cet ordre logique.

Portée réelle : **tout `S<c>` sur un type privé scalaire**, pas seulement
`TIME`.

---

## Correctif n° 1 — `codi.EXP_TYPE_CHAR`

```ada
  function		  EXP_TYPE_CHAR		( EXP :TREE )	return CHARACTER
  is			--=============--
    -- La vue complete d'un type prive peut etre SCALAIRE ( TIME est un
    -- DN_FIXED prive ).  Le noeud DN_PRIVATE ne porte PAS CD_IMPL_SIZE
    -- ( grammaire DIANA : sm_derived, sm_is_anonymous, sm_discriminant_s,
    --   sm_type_spec, xd_source_name -- et c'est tout ).  Lire CD_IMPL_SIZE
    -- dessus leve PROGRAM_ERROR dans DI.  Derouler AVANT toute lecture.
    EXP_TYPE	: TREE		:= CODI.FULL_VIEW( D( SM_EXP_TYPE, EXP ) );
  begin
    -- Les flottants sont toujours en double IEEE	754 = 64 bits = qword
    if  EXP_TYPE.TY	= DN_FLOAT  or  EXP_TYPE.TY = DN_ACCESS then return 'q'; end if;
    declare
      SIZ		: NATURAL		:= DI( CD_IMPL_SIZE, EXP_TYPE	);
    begin
    if	 SIZ <= 8		then return 'b';
    elsif	 SIZ <= 16	then return 'w';
    elsif	 SIZ <= 32	then return 'd';
    elsif	 SIZ <= 64	then return 'q';
    else return 'v';
    end if;
    end;
  end	  EXP_TYPE_CHAR;
```

Seule la ligne d'initialisation change (+ commentaire). Si `EXP_TYPE_CHAR`
est DANS `CODI`, écrire `FULL_VIEW(...)` sans le préfixe.

---

## Correctif n° 2 — `CODE_RETURN`

**Principe : dérouler le privé UNE FOIS EN TÊTE, faire porter TOUS les
tests de branche sur la vue complète.** Cela élimine la classe entière du
bug, au lieu de rattraper un cas.

### (a) En tête de `STORE_FUNCTION_RESULT`

```ada
        declare
          EXPR_TYPE		: TREE		:= D ( SM_EXP_TYPE, EXP );
	-- Vue COMPLETE : un type prive peut cacher un scalaire ( TIME = DN_FIXED
	-- prive ), un record, un tableau...  Router sur la vue PRIVEE envoyait
	-- TIME sur le chemin composite ( BLKMOV + symbole .size ), or .size
	-- n'est emis que par le chemin record ( bloc " virtual at 0 " ) : un
	-- fixed n'a que SIZ ( runtime ).  D'ou " symbol .size undefined ".
          FULL_TYPE		: TREE		:= CODI.FULL_VIEW( EXPR_TYPE );
        begin

	if  CODI.DEBUG  then
	  PUT_LINE( "; CODE_RETURN : EXPR TYPE = " & NODE_NAME'IMAGE( EXPR_TYPE.TY )
		  & "  VUE COMPLETE = " & NODE_NAME'IMAGE( FULL_TYPE.TY ) );
	end if;
```

### (b) Tous les tests portent sur `FULL_TYPE`

- `if EXPR_TYPE.TY in CLASS_SCALAR ...`     → `if FULL_TYPE.TY in CLASS_SCALAR ...`
- `elsif EXPR_TYPE.TY = DN_ARRAY ...`       → `elsif FULL_TYPE.TY = DN_ARRAY ...`
- `elsif EXPR_TYPE.TY = DN_ENUM_LITERAL_S`  → `elsif FULL_TYPE.TY = ...`
- la branche composite devient :

```ada
	elsif  FULL_TYPE.TY = DN_RECORD
	or     FULL_TYPE.TY = DN_CONSTRAINED_RECORD
	then
```

  (`DN_L_PRIVATE` / `DN_PRIVATE` **disparaissent de la liste** : ils ne
  peuvent plus apparaître, `FULL_VIEW` les a déroulés.)

### (c) Dans la branche composite, la boucle `while` DISPARAÎT

```ada
	  declare
	    TYPE_SPEC	: TREE	:= FULL_TYPE;			-- deja deroule
	  begin
	    -- ( la boucle " while DN_L_PRIVATE or DN_PRIVATE " est SUPPRIMEE :
	    --   FULL_VIEW l'a faite en tete, une fois pour toutes )

	    if  TYPE_SPEC.TY = DN_CONSTRAINED_RECORD  then	-- pilier 3.7 : vue contrainte -> base
	      TYPE_SPEC := D( SM_BASE_TYPE, TYPE_SPEC );	-- (symbole .size de la vue anonyme inexistant)
	    end if;
	    ...
```

### (d) Le `else` bruyant reste, et gagne en précision

```ada
	else
	-- Trou auparavant SILENCIEUX (cause du segfault R6 : result__ofs jamais
	-- rempli, BLKMOV appelant depuis un pointeur non initialise).
	-- Refus bruyant (piege n 53).
	  PUT_LINE( "; CODE_RETURN : type de retour non gere "
		& NODE_NAME'IMAGE( EXPR_TYPE.TY )
		& " ( vue complete " & NODE_NAME'IMAGE( FULL_TYPE.TY ) & " )" );
	  raise PROGRAM_ERROR;
	end if;
```

---

## Propriétés

1. **Le chemin scalaire fonctionne maintenant sur `TIME`** : `CODE_EXP` +
   `S<c>` avec `<c>` = `'q'` (grâce au correctif n° 1 : `CD_IMPL_SIZE` = 64
   sur la vue complète `DN_FIXED`). Plus de `BLKMOV`, plus de `.size`.

2. **Aucun comportement composite correct n'est changé** : un privé sur
   record déroule vers `DN_RECORD` et prend exactement la même branche
   qu'avant.

3. **`CODE_RANGE_CHECK` : VÉRIFIÉ SÛR, rien à faire.** Le chemin scalaire
   l'appelle sur le sous-type de retour, qui pour `TIME` est le sous-type
   PRIVÉ. Mais son premier test est :

   ```ada
   if  TYPE_SPEC.TY /= DN_INTEGER  and  TYPE_SPEC.TY /= DN_ENUMERATION  then
     return;                    -- fixed/float : perimetre 2
   end if;
   ```

   Un `DN_PRIVATE` sort immédiatement, **avant tout accès `D(...)`** — pas
   de `PROGRAM_ERROR`. Et même déroulé, `TIME` est `DN_FIXED` → même sortie
   (périmètre 2 des checks). Aucun `FULL_VIEW` à ajouter ici.

   **Dette à consigner** : quand le check de gamme fixed arrivera (F-F,
   périmètre 2), ce `return` s'ouvrira — et il faudra ALORS un `FULL_VIEW`
   en tête de `CODE_RANGE_CHECK`, sinon `TIME` y entrera en vue privée.
   **À inscrire dans la note fixed §5, étape F-F.**

---

## Ce que ce patch NE corrige PAS

Trois lignes sous le site d'erreur, dans `CALENDAR.FINC` :

```
; CODE CONVERSION SOURCE DN_FIXED TARGET DN_FIXED
; FIXED to FIXED a faire
```

C'est le trou **F-C** de la note fixed (§1.2). **Même correctement routé,
`CLOCK` ne rendra pas une valeur juste** : la conversion fixed→fixed n'est
pas implémentée. Le `.size` était le symptôme visible ; le pilier fixed
reste cassé en dessous.

Ordre de bataille : ce patch rend `test_calendar` ASSEMBLABLE. F-C le rendra
JUSTE.
