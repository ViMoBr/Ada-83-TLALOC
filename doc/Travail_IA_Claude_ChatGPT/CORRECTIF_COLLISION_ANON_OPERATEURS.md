# LOT correctif — collision des doublets anonymes sur les appels d'opérateurs infixes

## Chaîne causale close (pièces : segfault_0x45825b.md)

Le FINC de BLOCK__18 porte la preuve à trois exemplaires : `VAR ANON_427_24_*`
émis DEUX FOIS (branche `**`), de même `ANON_421_27` (branche `-` binaire) et
`ANON_424_24` (branche `*`). Cause structurelle : les doublets anonymes sont
nommés `ANON_<ligne>_<col>` par ANONYMOUS_NAME_AT sur le NŒUD D'APPEL — or un
appel d'opérateur INFIXE porte la position de l'expression entière, qui est
EXACTEMENT celle de son opérande GAUCHE. Quand cet opérande gauche est lui-même
un appel de fonction à résultat record (`D(SM_VALUE,PARAM) ** …`, col 24 pour
les deux), le lieu-résultat de l'opérateur et celui de l'opérande gauche
reçoivent le MÊME nom de VAR dans le même namespace. fasmg, multi-passes, lie
les références d'un symbole redéfini de façon dégénérée : l'@ qui descend dans
`D_L16` comme V est nul, et le `La` de DABS sur VAL (`-0x18`, `mov (%rax),%rax`
avec rax = 0) segfaulte — exactement votre relevé. Territoire ouvert par le lot
opérateurs : l'ancien chemin builtin n'allouait aucun doublet-résultat, la
collision ne pouvait pas exister.

Correctif : quand `AS_NAME` du nœud d'appel est un `DN_USED_OP`, nommer le
doublet-résultat sur la position du LEXÈME de l'opérateur — unique par
construction, distincte de tout opérande. Tous les autres appels gardent leur
nom actuel : FINC hors opérateurs bit-identiques. OPDEF_TEST ne déclenchait pas
la collision (opérandes gauches = agrégats, enveloppés sous un autre nommage) :
deux checks l'étendent au motif exact — opérande gauche = APPEL DE FONCTION.

---

## COMMIT 1 — extension du témoin OPDEF_TEST (3 modifications, AVANT correctif)

### Modification 1.1 — fonction MK

ANCRE (texte existant, inchangé, unique) :

```ada
  type DERIV is new INTEGER;
```

BLOC À SUPPRIMER : (néant — insertion AU-DESSUS de l'ancre)

BLOC À INSÉRER :

```ada
  function MK ( A, B : INTEGER ) return PAIRE is
  begin
    return ( A, B );
  end MK;

```

### Modification 1.2 — variable W

ANCRE (texte existant, inchangé, unique) :

```ada
  V	: PAIRE;
```

BLOC À SUPPRIMER : (néant — insertion SOUS l'ancre)

BLOC À INSÉRER :

```ada
  W	: PAIRE;
```

### Modification 1.3 — checks 7-8 : opérande gauche = appel de fonction

ANCRE (texte existant, inchangé, unique) :

```ada
  PUT( "RESULTAT :" );
```

BLOC À SUPPRIMER : (néant — insertion AU-DESSUS de l'ancre)

BLOC À INSÉRER :

```ada
  W := MK( 2, 3 ) + MK( 10, 10 );					--| gauche = APPEL : position(expression) = position(MK) -> collision ANON
  CHECK( W.A = 12 and W.B = 13, 7 );

  W := MK( 1, 1 ) ** 4;							--| le motif exact du segfault 0x45825b (fix_pre l.427)
  CHECK( W.A = 4 and W.B = 4, 8 );

```

### Oracle du commit 1

- gnat : `RESULTAT : 8 OK, 0 ECHECS` + `OPDEF_TEST PASSE`.
- T1 actuel : **ROUGE attendu** sur 7-8 (valeurs poubelle, exception, segfault
  ou échec d'assemblage — toute forme de rouge vaut constat). Lecture FINC :
  `VAR ANON_l_c_*` en DOUBLE aux deux sites — la signature.

---

## COMMIT 2 — expander-expressions.adb, PREPARE_FUNCTION_RESULT_PLACE (3 modifications)

### Modification 2.1 — source de nommage ANON_SRC

ANCRE (texte existant, inchangé, unique) :

```ada
    RET_NAME	: TREE	:= D( AS_NAME, FUNC_SPEC );	 -- nom du type de retour (DN_FUNCTION_SPEC)
```

BLOC À SUPPRIMER (les deux lignes immédiatement sous l'ancre) :

```ada
    RET_TS	: TREE	:= TREE_VOID;
  begin
```

BLOC DE REMPLACEMENT :

```ada
    RET_TS	: TREE	:= TREE_VOID;
    ANON_SRC	: TREE	:= CALL_NODE;
  begin
        if  D( AS_NAME, CALL_NODE ).TY = DN_USED_OP  then
	ANON_SRC := D( AS_NAME, CALL_NODE );							-- OPDEF_TEST 7-8 / segfault 0x45825b : appel d'OPERATEUR infixe -- la position de l'expression = celle de l'operande GAUCHE ; si celui-ci est un appel a resultat record, VAR ANON_l_c emis en DOUBLE dans le namespace (fasmg multi-passes : cellule degeneree, @ nul dans DABS). Nommer le doublet-resultat sur le LEXEME de l'operateur : position unique par construction.
        end if;
```

### Modification 2.2 — branche record

ANCRE (texte existant, inchangé, unique — noter les deux espaces après
ANON_STR) :

```ada
	  ANON_STR  : constant STRING := ANONYMOUS_NAME_AT( CALL_NODE );
```

BLOC À SUPPRIMER : l'ancre elle-même (cette ligne).

BLOC DE REMPLACEMENT :

```ada
	  ANON_STR  : constant STRING := ANONYMOUS_NAME_AT( ANON_SRC );
```

### Modification 2.3 — branche tableau contraint

ANCRE (texte existant, inchangé, unique — tabulations internes, distincte de
la précédente) :

```ada
	    ANON_STR	: constant STRING	:= ANONYMOUS_NAME_AT( CALL_NODE );
```

BLOC À SUPPRIMER : l'ancre elle-même (cette ligne).

BLOC DE REMPLACEMENT :

```ada
	    ANON_STR	: constant STRING	:= ANONYMOUS_NAME_AT( ANON_SRC );
```

### Oracles du commit 2 (dans l'ordre)

1. T1 reconstruit. OPDEF_TEST : `8 OK, 0 ECHECS` + `OPDEF_TEST PASSE`. FINC du
   témoin : plus aucun `VAR ANON_*` en double (contrôle :
   `grep "^VAR	ANON" OPDEF_TEST.FINC | sort | uniq -d` vide) ; les
   doublets-résultat des opérateurs portent la position du lexème (colonne de
   `+` / `**`), distincte de celle des MK.
2. FINC des témoins du filet HORS OPDEF_TEST : BIT-IDENTIQUES (ANON_SRC =
   CALL_NODE pour tout appel non-opérateur). Filet complet vert.
3. Chaîne régénérée : diff confiné aux unités à opérateurs utilisateur
   (sem_phase et subunits) ; contrôle global des doublons :
   `for f in *.FINC; do grep "^VAR	ANON" $f | sort | uniq -d; done` vide.
   Trace S null_prog bit-exacte.
4. T2 reconstruit : `./A83.sh ./ ../_standrd.ads M` — plus de segfault DABS à
   SHORT_INTEGER ; visée : listing des déclarations complet jusqu'à
   `_DURATION` + « Ok » (SEM_PHASE bootstrappée complète). Puis retrait des
   sondes @PD (instructions déjà livrées).

---

## COMMIT 3 — documentation

### Modification 3.1 — PIEGES.md, ajout en fin de fichier

ANCRE : la dernière ligne du fichier (entrée n° 140, lot opérateurs).

BLOC À SUPPRIMER : (néant — insertion sous l'ancre)

BLOC À INSÉRER :

```
141. **Doublet anonyme nomme par position source : COLLISION sur un
    appel d'operateur infixe.** La position d'une expression infixe =
    celle de son operande GAUCHE ; si cet operande est un appel a
    resultat record, PREPARE_FUNCTION_RESULT_PLACE emettait DEUX
    VAR ANON_l_c homonymes dans le namespace -- fasmg multi-passes lie
    les references de facon degeneree, @ nul propage dans D/DABS,
    segfault 0x45825b (La sur VAL). Invisible avant le piege n 140 :
    le chemin builtin n'allouait pas de doublet-resultat d'operateur.
    Le LEXEME n'offre pas d'issue : LX_SRCPOS du DN_USED_OP = debut
    d'expression = position de l'operande gauche (verifie au FINC).
    Unicite par SUFFIXE hors position : ANON_l_c_L<n> via NEW_LABEL
    (deterministe), pour les seuls lieux-resultat d'operateurs.
    AUDITS RECOMMANDES : (a)
    PREPARE_ARRAY_RESULT_PLACE garde CALL_NODE -- un operateur
    utilisateur rendant un tableau NON contraint recollisionnerait
    (hors corpus) ; (b) defense assembleur : faire aboyer la macro VAR
    de codi sur une redefinition dans le meme namespace -- la
    collision etait un silence fasmg. Gardien : OPDEF_TEST 7-8.
    (session 8 aout)
```

### Modification 3.2 — ORACLES_TESTS.md, entrée OPDEF_TEST

ANCRE (dans l'entrée livrée au lot opérateurs) :

```
Attendu : « RESULTAT : 6 OK,
0 ECHECS / OPDEF_TEST PASSE ».
```

BLOC À SUPPRIMER : l'ancre elle-même (ces deux lignes).

BLOC DE REMPLACEMENT :

```
Etendu (lot collision ANON) : checks 7-8, operande gauche = APPEL de
fonction a resultat record (MK(..) + MK(..), MK(..) ** 4) -- gardiens
du piege n 141. Attendu : « RESULTAT : 8 OK, 0 ECHECS / OPDEF_TEST
PASSE ».
```

Ordre du lot : commit 1 (rouge 7-8 constaté) → commit 2 (oracles 1-4) →
commit 3.
