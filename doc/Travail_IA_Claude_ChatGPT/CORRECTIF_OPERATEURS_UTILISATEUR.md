# LOT correctif — opérateurs définis par l'utilisateur émis comme prédéfinis

## Chaîne causale close (pièces : backtrace gdb, FIX_PRE.FINC, désassemblage)

Le FINC de fix_pre l.427 montre les deux `D( SM_VALUE, … )` rendant leurs TREEs
dans des doublets anonymes (protocole résultat-record, sain), puis
`Sq POWN / Sq POWX` empochant les ADRESSES de doublets restées en pile et
`CALL STANDARD.INTEGER_POW` : l'expander a émis la primitive PRÉDÉFINIE pour le
`"**"` d'UARITH (TREE × TREE), opérateur UTILISATEUR à vrai corps. N = adresse
de pile (~0x7fffffc1…, votre dump) → E astronomique dans INTEGER_POW, dont le
code est prouvé correct au désassemblage : « boucle infinie » à l'échelle
humaine. Racine : expander-expressions.adb, dispatch `DN_USED_OP →
CODE_DN_BLTN_OPERATOR_ID`, dont le garde interne accepte
`DEFN.TY = DN_OPERATOR_ID` et émet PAR NOM. Portée réelle bien au-delà du
`**` : TOUS les opérateurs d'UARITH (`+`, `-`, `*`, comparaisons — `use UARITH`
dans toute la sémantique) deviennent ADD/SUB/MUL/CEQ sur adresses de doublets —
poison SILENCIEUX partout où le spin ne se déclenche pas.

Correctif au dispatch : suivre d'abord SUBPROGRAM_ORIGIN (un RENAMES d'un
prédéfini doit rester en émission par nom, LRM 8.5) ; si l'origine reste un
DN_OPERATOR_ID — vrai corps utilisateur — router vers la voie NORMALE d'appel
de fonction (PREPARE_FUNCTION_RESULT_PLACE + CODE_PROCEDURE_CALL), celle-là
même qui réussit partout pour les appels nommés à résultat record comme
`D(...)` ; CODE_PROCEDURE_CALL ne lit que SM_DEFN et applique déjà
SUBPROGRAM_ORIGIN : agnostique sur la forme DN_USED_OP. Frontière de
non-régression à encadrer par le témoin : les opérateurs des types DÉRIVÉS
doivent RESTER en émission builtin (checks 5-6 ci-dessous, verts avant ET
après).

---

## COMMIT 1 — témoin OPDEF_TEST (posé AVANT le correctif)

Nouveau fichier, à côté des programmes de test (INDEX § 3.4). Motif : opérateurs
utilisateur sur un type record (mini-UARITH : `+`, `**` mixte record×entier,
`<`), PLUS la frontière type dérivé dont les opérateurs implicites doivent
rester prédéfinis.

### Nouveau fichier `opdef_test.adb`

```ada
with TEXT_IO; use TEXT_IO;

procedure OPDEF_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  type PAIRE is record
    A	: INTEGER;
    B	: INTEGER;
  end record;

  function "+" ( X, Y : PAIRE ) return PAIRE is
  begin
    return ( X.A + Y.A, X.B + Y.B );
  end "+";

  function "**" ( X : PAIRE; N : INTEGER ) return PAIRE is
    R	: PAIRE := X;
  begin
    for I in 2 .. N loop
      R := R + X;
    end loop;
    return R;
  end "**";

  function "<" ( X, Y : PAIRE ) return BOOLEAN is
  begin
    return X.A < Y.A;
  end "<";

  type DERIV is new INTEGER;

  procedure CHECK ( COND :BOOLEAN; NUM :INTEGER ) is
  begin
    if COND then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT( "* ECHEC test" );
      PUT( INTEGER'IMAGE( NUM ) );
      NEW_LINE;
    end if;
  end CHECK;

  U	: PAIRE;
  V	: PAIRE;
  D1	: DERIV := 6;

begin
  U := ( 3, 4 ) + ( 10, 20 );						--| "+" utilisateur record
  CHECK( U.A = 13 and U.B = 24, 1 );

  V := ( 1, 2 ) ** 5;							--| "**" utilisateur record x entier : LE motif du spin
  CHECK( V.A = 5 and V.B = 10, 2 );

  CHECK( ( 1, 9 ) < ( 2, 0 ), 3 );					--| "<" utilisateur -> BOOLEAN
  CHECK( not ( ( 5, 0 ) < ( 2, 9 ) ), 4 );

  D1 := D1 + 7;								--| operateurs IMPLICITES du type derive :
  CHECK( INTEGER( D1 ) = 13, 5 );					--| DOIVENT rester en emission predefinie,
  CHECK( D1 * 2 = 26, 6 );						--| avant COMME apres le correctif

  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "OPDEF_TEST PASSE" );
  else
    PUT_LINE( "OPDEF_TEST ECHOUE" );
  end if;

exception
  when others =>
    PUT_LINE( "OPDEF_TEST ECHOUE (EXCEPTION)" );
end OPDEF_TEST;
```

### Oracle du commit 1

- gnat : `RESULTAT : 6 OK, 0 ECHECS` + `OPDEF_TEST PASSE`.
- T1 actuel : **ROUGE attendu** sur les checks 1-4 (valeurs poubelle, exception,
  ou blocage au check 2 — dans ce dernier cas interrompre : le rouge est
  constaté). Les checks 5-6 (dérivé) doivent être VERTS dès aujourd'hui : ils
  bornent la frontière que le correctif ne doit pas franchir.
- Lecture FINC du témoin : aux sites `+`/`**`/`<` sur PAIRE, présence d'ADD /
  CALL INTEGER_POW / CLT sur les adresses — la signature de la famille.

---

## COMMIT 2 — correctif expander-expressions.adb (1 modification)

ANCRE (texte existant, inchangé, unique) :

```ada
    elsif  NAME.TY = DN_USED_OP  then
```

BLOC À SUPPRIMER (la ligne immédiatement sous l'ancre) :

```ada
      CODE_DN_BLTN_OPERATOR_ID;
```

BLOC DE REMPLACEMENT :

```ada
      declare
        OP_DEFN	: TREE	:= D( SM_DEFN, NAME );
      begin
        if  OP_DEFN.TY = DN_OPERATOR_ID  then
	OP_DEFN := SUBPROGRAM_ORIGIN( OP_DEFN );						-- renames d'un predefini : viser l'origine (LRM 8.5)
        end if;
        if  OP_DEFN.TY = DN_OPERATOR_ID  then
			--| OPDEF_TEST (8/08, bootstrap _standrd, spin INTEGER_POW sur le
			--| 2**15 de SHORT_INTEGER) : un operateur DEFINI PAR L'UTILISATEUR
			--| (DN_OPERATOR_ID a vrai corps -- "**" d'UARITH sur TREE) etait
			--| emis comme le PREDEFINI homonyme : CALL STANDARD.INTEGER_POW
			--| recevait des @doublets (N = adresse de pile -> E astronomique),
			--| et +,-,*,comparaisons d'UARITH devenaient ADD/SUB/MUL/CEQ sur
			--| adresses -- poison silencieux de toute la semantique. Voie
			--| normale d'appel : meme protocole (resultat record en doublet
			--| anonyme) que les appels nommes comme D(...) ;
			--| CODE_PROCEDURE_CALL ne lit que SM_DEFN et refait l'origine.
			--| Les operateurs IMPLICITES des types derives restent en
			--| emission par nom (branche else), gardes par OPDEF_TEST 5-6.
	PREPARE_FUNCTION_RESULT_PLACE( OP_DEFN, FUNCTION_CALL );
	INSTRUCTIONS.CODE_PROCEDURE_CALL( FUNCTION_CALL, NAME );
        else
	CODE_DN_BLTN_OPERATOR_ID;								-- predefini, ou renommage d'un predefini
        end if;
      end;
```

### Oracles du commit 2 (dans l'ordre)

1. T1 reconstruit (gnat). OPDEF_TEST recompilé par T1 : `6 OK, 0 ECHECS` +
   `OPDEF_TEST PASSE`. FINC du témoin : `+`/`**`/`<` sur PAIRE → `CALL` vers
   les labels des corps utilisateur avec doublets résultat ; les opérations sur
   DERIV → `ADD`/`MUL` prédéfinis, INCHANGÉS à l'octet près par rapport à
   l'avant-commit.
2. FINC des témoins existants régénérés (ENUM_TEST, REC_ARR_TEST, IO_TEST,
   FLOAT_TEST, DIRECT_IO_TEST, SECV1, TTAIL1, SUBLVL_TEST, AGGSTR_TEST) :
   BIT-IDENTIQUES — aucun n'utilise d'opérateur utilisateur. Tout écart =
   collatéral, stop et examen.
3. Filet complet vert (exécution).
4. Chaîne complète régénérée : diff des FINC du compilateur confiné aux unités
   à opérateurs utilisateur (attendu : idl-sem_phase.FINC et ses subunits —
   UARITH est partout dans la sémantique ; consigner la liste exacte au
   journal). Trace S de null_prog gnat/bootstrappé : toujours bit-exacte après
   normalisation CRLF.
5. T2 reconstruit : `./A83.sh ./ ../_standrd.ads M` — plus de spin à
   SHORT_INTEGER ; visée : le listing complet des déclarations jusqu'à
   `_DURATION` puis « Ok », comme TLALOC(gnat) — SEM_PHASE bootstrappée
   COMPLÈTE sur _standrd. Familles suivantes possibles au-delà (LIB/expander
   de T2) : hors périmètre.
6. Après constat : appliquer le COMMIT 2 du lot précédent (retrait des sondes
   @PD, instructions déjà livrées), toujours en attente.

---

## COMMIT 3 — documentation

### Modification 3.1 — PIEGES.md, ajout en fin de fichier

ANCRE : la dernière ligne du fichier (l'entrée n° 139 du lot agrégats,
finissant par `(session 8 aout)`).

BLOC À SUPPRIMER : (néant — insertion sous l'ancre)

BLOC À INSÉRER :

```
140. **Operateur DEFINI PAR L'UTILISATEUR emis comme le predefini
    homonyme.** Le dispatch DN_USED_OP envoyait tout a
    CODE_DN_BLTN_OPERATOR_ID, dont le garde acceptait DN_OPERATOR_ID :
    emission PAR NOM ("**" -> CALL INTEGER_POW, "+" -> ADD...) sur les
    @doublets des operandes records. Symptome bootstrap : spin
    d'INTEGER_POW (N = adresse de pile, E astronomique, code de la
    boucle PROUVE correct au desassemblage) au 2**15 de SHORT_INTEGER ;
    et poison SILENCIEUX de tous les +,-,*,comparaisons d'UARITH.
    Discrimination posee au dispatch : SUBPROGRAM_ORIGIN d'abord (un
    renames d'un predefini reste par nom), puis DN_OPERATOR_ID a vrai
    corps -> voie normale d'appel de fonction (protocole D(...)).
    Frontiere : les operateurs IMPLICITES des types derives restent
    par nom -- gardes par OPDEF_TEST 5-6. Lecon de methode : une
    boucle "infinie" while-decrementante = parametre d'entree
    astronomique = chercher le SITE D'APPEL, pas la boucle.
    Gardien : OPDEF_TEST. (session 8 aout)
```

### Modification 3.2 — ORACLES_TESTS.md, nouvelle entrée témoin

ANCRE (titre de section existant) :

```
### Sondes @GT/@PC/@AP (hors filet, outil de diagnostic bootstrap)
```

BLOC À SUPPRIMER : (néant — insertion AVANT l'ancre)

BLOC À INSÉRER :

```
### OPDEF_TEST (lot operateurs utilisateur, 8 aout 2026, 6 assertions)

Une unite : opdef_test.adb. Couvre : operateurs definis par l'utilisateur
sur type record ("+" binaire, "**" mixte record x entier -- le motif du spin
UARITH --, "<" vers BOOLEAN, resultats records en doublets anonymes) ET la
frontiere des operateurs IMPLICITES d'un type derive d'INTEGER (checks 5-6),
qui doivent rester en emission predefinie. Attendu : « RESULTAT : 6 OK,
0 ECHECS / OPDEF_TEST PASSE ». Historique : rouge 1-4 avant correctif
(emission par nom sur @doublets), 5-6 verts des l'origine. Gardien du piege
n 140 ; a repasser apres toute retouche du dispatch DN_USED_OP, de
CODE_DN_BLTN_OPERATOR_ID, de SUBPROGRAM_ORIGIN ou du protocole d'appel
de fonction.

```

Ordre du lot : commit 1 (rouge 1-4 / vert 5-6 constaté) → commit 2 (oracles
1-6) → commit 3.
