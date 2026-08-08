# LIVRAISON — SIGSEGV 0x4028d8 (ENUM_IMAGE) : niveau lexical des subunits imbriqués

Périmètre : TLALOC(TLALOC) sur `_standrd.ads`, SEM_PHASE, `FIX_PRE.MAKE_PREDEF_IDS`,
`LIST_ARGUMENTS'IMAGE ( ARG_NAME )`.

---

## DIAGNOSTIC (chaîne causale complète)

**Constat machine.** Au segfault, `rax = 0x10 = 16`. La séquence appelante émise est
`La 1, STANDARD.IDL.SEM_PHASE_L11.PRENAME._LIST_ARGUMENTS.use__info` ; `LI 16` ; `ADD`.
`La = Lq` (codi_x86_64.finc) : c'est le CONTENU de la variable `use__info` (frame,
niveau 1) qui est chargé. 0 + 16 = 16 : la case lue vaut 0 — `use__info` de
`_LIST_ARGUMENTS` n'a jamais été vu. ENUM_IMAGE déréférence ensuite le « doublet »
à l'adresse 16 (`LIa , , 8` → lecture de `[0x10+8]`) : SIGSEGV. Le contrat
ENUM_USE_INFO (pièges n° 29 et 87) est sain — c'est la BASE du chargement qui est fausse.

**Pourquoi la case vaut 0.** La preuve est dans le FINC appelant lui-même : les locales
de MAKE_PREDEF_IDS sont émises `LVA 2, ...`. Or la chaîne statique réelle est
SEM_PHASE (niveau 1) → FIX_PRE (niveau 2) → MAKE_PREDEF_IDS (niveau 3).
FIX_PRE a donc été compilé au niveau 1 — le niveau de son PARENT. À l'exécution,
son `LINK 1` écrase `display[1]` (l'entrée de SEM_PHASE, où vivent les
`use__info` des types de PRENAME, correctement élaborés à l'entrée de SEM_PHASE).
`La 1, ..use__info` lit alors le frame tout neuf de FIX_PRE : zéro.

**Racine dans l'expander.** `CODE_COMPILATION_UNIT` (expander-structures.adb) fait
`CODI.CUR_LEVEL := 0;` pour TOUTE unité, y compris `DN_SUBUNIT`. C'est juste pour un
subunit de bibliothèque (parent = package IDL, sans frame : PAR_PHASE, LIB_PHASE,
SEM_PHASE, IDL_MAN... — d'où des phases antérieures saines), faux dès que le parent
porte un frame : tous les `idl-sem_phase-*.adb` (subunits de la PROCÉDURE SEM_PHASE)
sont compilés un cran trop haut. Le canal de correction existe déjà : l'invariant
« CD_LEVEL d'un id de sous-programme = niveau d'EXÉCUTION de son corps » est posé
par l'unité parente au stub (CODE_SUBPROGRAM_BODY, branche première définition,
après INC_LEVEL) et à la spec (CODE_SUBPROG_ENTRY_DECL, après INC_LEVEL), et il
traverse la bibliothèque — exactement comme CD_LABEL, dont l'appariement
CALL(parent)/PRO(subunit) dépend déjà. Il manque : (a) le poseur symétrique pour les
STUBS de package (pas de frame → niveau du contexte englobant), (b) le consommateur
à l'entrée d'un DN_SUBUNIT.

**Portée.** Corrige d'un coup la même famille latente dans TOUS les subunits de
SEM_PHASE : les sous-programmes des corps de package séparés (MAKE_NOD, DEF_UTIL,
UARITH, SET_UTIL, REQ_UTIL, FIX_WITH, SEM_GLOB, UNIV_OPS...) sont aujourd'hui au
niveau 1 au lieu de 2 et écraseraient `display[1]` au premier accès montant —
MAKE_ARGUMENT_ID (MAKE_NOD) est appelé deux lignes après le site du segfault.
`idl-par_phase-set_dflt` (subunit de PAR_PHASE) passe de 1 à 2 : correct, à couvrir
par l'oracle de trace bit-exacte. Les subunits directs d'IDL sont inchangés
(niveau recalculé = niveau actuel).

---

## COMMIT 1 — témoin SUBLVL_TEST (auto-jugeant, posé AVANT le correctif)

Trois NOUVEAUX fichiers, à côté des programmes de test existants (INDEX § 3.4).
Reproduit le motif exact : procédure de bibliothèque portant un énuméré + un objet,
un subunit de sous-programme et un subunit de corps de package qui font des accès
montants, dont un `'IMAGE` en initialisation (le site FIX_PRE). `test_subunit.adb`
existant ne couvre que le cas parent-sans-frame, resté sain — d'où ce témoin distinct.

### Nouveau fichier `sublvl_test.adb`

```ada
with TEXT_IO; use TEXT_IO;

procedure SUBLVL_TEST is

  type FEU is ( VERT, ORANGE, ROUGE );

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;
  COMPTE	: INTEGER := 41;

  package COEUR is
    procedure BATTRE;
  end COEUR;

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

  package body COEUR is separate;

  procedure INTERNE is separate;

begin
  INTERNE;								--| subunit de sous-programme : niveau parent + 1
  COEUR.BATTRE;								--| subunit de corps de package : niveau du contexte
  CHECK( COMPTE = 43, 5 );
  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "SUBLVL_TEST PASSE" );
  else
    PUT_LINE( "SUBLVL_TEST ECHOUE" );
  end if;
end SUBLVL_TEST;
```

### Nouveau fichier `sublvl_test-interne.adb`

```ada
separate( SUBLVL_TEST )
procedure INTERNE is
  IMG	: constant STRING := FEU'IMAGE( ORANGE );			--| le site exact du segfault : 'IMAGE d'un enumere du parent, en initialisation
begin
  CHECK( IMG = "ORANGE", 1 );
  CHECK( FEU'POS( ROUGE ) = 2, 2 );
  CHECK( COMPTE = 41, 3 );						--| lecture montante d'objet du parent
  COMPTE := COMPTE + 1;							--| ecriture montante
end INTERNE;
```

### Nouveau fichier `sublvl_test-coeur.adb`

```ada
separate( SUBLVL_TEST )
package body COEUR is

  procedure BATTRE is
    IMG	: constant STRING := FEU'IMAGE( VERT );
  begin
    CHECK( IMG = "VERT", 4 );
    COMPTE := COMPTE + 1;
  end BATTRE;

end COEUR;
```

### Oracle du commit 1

- Validation du juge (dépendances assumées) : compilé gnat, exécuter →
  `RESULTAT : 5 OK, 0 ECHECS` puis `SUBLVL_TEST PASSE`.
- Compilé T1 (TLALOC-gnat), ordre : `sublvl_test.adb` puis les deux subunits →
  **ROUGE attendu** : SIGSEGV à l'élaboration de `IMG` dans INTERNE, même signature
  que `_standrd` (déréférencement autour de 0x10 dans ENUM_IMAGE, `rax` = petite
  constante = 0 + `LI 16`). Rouge = preuve que le témoin juge bien la famille.
- Lecture croisée du FINC du témoin : `PRO INTERNE_*` suivi de `ELB 1` (au lieu
  de `ELB 2`) — trace directe de la miscompilation.

---

## COMMIT 2 — correctif : niveau de départ des subunits (expander-structures.adb)

Deux modifications, même fichier. Reconstruire l'expander puis TOUTE la chaîne
(make_ada_comp.sh) : tous les FINC sont régénérés.

### Modification 2.1 — poseur : CD_LEVEL au stub d'un corps de package

ANCRE (texte existant, inchangé, unique) :

```ada
      if  PACK_BODY.TY = DN_STUB  then
```

BLOC À SUPPRIMER (immédiatement sous l'ancre — le `FULL_UNIT_NAME` discrimine
de la branche stub des sous-programmes, qui porte `FULL_NAME`) :

```ada
        declare
	UNIT_FILE_NAME	:constant STRING	:= PRINT_NAME( D( XD_LIB_NAME, THE_COMPILATION_UNIT ) );
	FULL_UNIT_NAME	:constant STRING	:= UNIT_FILE_NAME( UNIT_FILE_NAME'FIRST .. UNIT_FILE_NAME'LAST-4 )
```

BLOC DE REMPLACEMENT :

```ada
        DI( CD_LEVEL, PACK_DEF, INTEGER( CODI.CUR_LEVEL ) );					-- niveau d'execution du contenu du corps separe (un package n'ouvre pas de frame) ; lu par CODE_COMPILATION_UNIT a la compilation du subunit -- meme canal bibliotheque que CD_LABEL
        declare
	UNIT_FILE_NAME	:constant STRING	:= PRINT_NAME( D( XD_LIB_NAME, THE_COMPILATION_UNIT ) );
	FULL_UNIT_NAME	:constant STRING	:= UNIT_FILE_NAME( UNIT_FILE_NAME'FIRST .. UNIT_FILE_NAME'LAST-4 )
```

Note : `PACK_DEF = D( SM_FIRST, PACK_ID )` (déjà déclaré en tête de
CODE_PACKAGE_BODY) = l'id de SPEC — le même nœud que retrouvera le subunit par
`SM_FIRST`. Rien à poser côté sous-programmes : le stub (branche « première
définition » de CODE_SUBPROGRAM_BODY, après INC_LEVEL) et la spec
(CODE_SUBPROG_ENTRY_DECL) posent DÉJÀ CD_LEVEL = niveau d'exécution du corps.

### Modification 2.2 — consommateur : entrée d'unité DN_SUBUNIT

ANCRE (texte existant, inchangé, unique) :

```ada
      CODE_PACKAGE_BODY( UNIT_ALL_DECL );
```

BLOC À SUPPRIMER (deux lignes plus bas, la branche complète) :

```ada
    when  DN_SUBUNIT		=>
      CODE_SUBUNIT_BODY( D( AS_SUBUNIT_BODY, UNIT_ALL_DECL )  );
```

BLOC DE REMPLACEMENT :

```ada
    when  DN_SUBUNIT		=>
			--| Niveau de depart du subunit : reprendre le niveau enregistre par
			--| l'unite PARENTE sur la premiere declaration (stub ou spec), meme
			--| canal bibliotheque que CD_LABEL.  Invariant : CD_LEVEL d'un id de
			--| sous-programme = niveau d'EXECUTION de son corps (pose apres
			--| INC_LEVEL) ; CD_LEVEL d'un package separe = niveau du contexte du
			--| stub (pose par CODE_PACKAGE_BODY, sans frame).  Demarrer a 0
			--| n'etait juste que pour les subunits de bibliotheque (parent sans
			--| frame) : un subunit de SOUS-PROGRAMME (idl-sem_phase-*.adb) se
			--| compilait un cran trop haut et son LINK ecrasait le display du
			--| parent -- segfault ENUM_IMAGE de FIX_PRE (La 1, use__info -> 0).
      declare
        SUB_BODY		: TREE	:= D( AS_SUBUNIT_BODY, UNIT_ALL_DECL );
        FIRST_DECL_ID	: TREE	:= D( SM_FIRST, D( AS_SOURCE_NAME, SUB_BODY ) );
      begin
        if  SUB_BODY.TY = DN_SUBPROGRAM_BODY  then
	CODI.CUR_LEVEL := DI( CD_LEVEL, FIRST_DECL_ID ) - 1;					-- l'INC_LEVEL du corps retablira CD_LEVEL ; -1 sur une valeur non posee (0) => CONSTRAINT_ERROR : bruyant
        elsif  SUB_BODY.TY = DN_PACKAGE_BODY  then
	CODI.CUR_LEVEL := DI( CD_LEVEL, FIRST_DECL_ID );					-- pas de frame propre : niveau du contexte du stub
        else
	CODI.TROU( "CODE_COMPILATION_UNIT subunit non couvert", SUB_BODY );			-- task body separe : hors corpus, refus bruyant
        end if;
        CODE_SUBUNIT_BODY( SUB_BODY );
      end;
```

### Oracles du commit 2 (dans l'ordre)

1. **SUBLVL_TEST vert** (compilé T1 reconstruit) : `RESULTAT : 5 OK, 0 ECHECS` +
   `SUBLVL_TEST PASSE`. Lecture FINC : `PRO INTERNE_*` … `ELB 2`, et dans INTERNE
   `La 1, …_FEU.use__info` inchangé (CD_LEVEL du type reste 1 — seul le LINK bouge).
2. **Non-régression gratuite par diff FINC des témoins** : aucun témoin du filet ne
   contient de subunit → les FINC de ENUM_TEST, REC_ARR_TEST, IO_TEST, FLOAT_TEST,
   DIRECT_IO_TEST, SECV1, TTAIL1 régénérés doivent être BIT-IDENTIQUES à l'avant-commit.
   Tout octet de différence = collatéral, stop.
3. **Diff FINC du compilateur** confiné à : `idl-sem_phase-*.FINC` et
   `idl-par_phase-set_dflt.FINC` (constantes de niveau des LVA/L*/S*/ELB/LINK/UNLINK,
   décalées de +1). Les `idl-*.FINC` directs (par_phase, lib_phase, idl_man,
   page_man…) et `_STANDRD.FINC` : zéro octet.
4. **Trace S bit-exacte maintenue** : run S de null_prog gnat vs bootstrappé,
   normalisation CRLF (piège n° 137), diff vide — couvre le changement de niveau
   de SET_DFLT.
5. **Cible** : `./A83.sh ./ ../_standrd.ads M` par TLALOC(TLALOC) — plus de SIGSEGV
   à `ENUM_IMAGE` ; MAKE_PREDEF_IDS se termine (les quatre boucles 'IMAGE :
   LIST_ARGUMENTS, OPTIMIZE, SUPPRESS, INTERFACE_ARGUMENTS, puis DEFINED_ATTRIBUTES
   et OP_CLASS passent par MAKE_NOD, désormais au bon niveau) ; entrée dans WALK.
   La suite de SEM_PHASE peut révéler d'autres familles : hors périmètre de ce lot.

---

## COMMIT 3 — documentation (insertions pures, aucun bloc supprimé)

### Modification 3.1 — PIEGES.md, ajout en fin de fichier

ANCRE (dernière entrée existante, dernière ligne du fichier) :

```
    jour). (session 7 aout)
```

BLOC À SUPPRIMER : (néant — insertion sous l'ancre)

BLOC À INSÉRER :

```
138. **CUR_LEVEL := 0 en tete de TOUTE unite — faux pour un subunit
    dont le parent porte un frame.** Un subunit de la PROCEDURE
    SEM_PHASE se compilait au niveau de son parent ; a l'execution son
    LINK ecrasait display[parent] et tout acces montant lisait le
    frame du subunit (use__info = 0, ENUM_IMAGE derefere 0+16 :
    SIGSEGV 0x4028d8). Sain par accident pour les subunits de
    bibliotheque (parent package, base 0) — PAR/LIB_PHASE passaient.
    Canal de correction : CD_LEVEL de la premiere declaration (stub /
    spec), qui traverse la bibliotheque comme CD_LABEL ; poseur ajoute
    au stub de package (pas de frame : niveau du contexte). Signature
    gdb : registre = petite constante exacte d'un LI de la sequence
    appelante (ici 0x10) = base nulle + offset. Gardien : SUBLVL_TEST.
    (session 7 aout, lot subunits)
```

### Modification 3.2 — ORACLES_TESTS.md, nouvelle entrée témoin

ANCRE (titre de section existant) :

```
### Sondes @GT/@PC/@AP (hors filet, outil de diagnostic bootstrap)
```

BLOC À SUPPRIMER : (néant — insertion AVANT l'ancre)

BLOC À INSÉRER :

```
### SUBLVL_TEST (lot subunits, 7 aout 2026, 5 assertions)

Trois unites : sublvl_test.adb + subunit de sous-programme (INTERNE) +
subunit de corps de package (COEUR). Couvre : niveau lexical des
subunits a parent PORTEUR DE FRAME — 'IMAGE d'enumere du parent en
initialisation (site FIX_PRE du bootstrap), lectures/ecritures
montantes d'objet, appel montant (CHECK), sous-programme d'un corps
de package separe. Ordre de compilation : parent puis subunits.
Attendu : « RESULTAT : 5 OK, 0 ECHECS / SUBLVL_TEST PASSE ».
Gardien du piege n 138 ; a repasser apres toute retouche de
CODE_COMPILATION_UNIT, des stubs ou du couple LINK/display.

```

---

## Rappels d'application

- Tabulations : les blocs ci-dessus reproduisent les tabulations réelles des
  sources (mélange espaces d'indentation + tabulations internes) ; coller tel quel.
- Ordre : commit 1 (rouge constaté) → commit 2 (vert + oracles 2-5) → commit 3.
- Après le lot : les sondes @GT/@PC/@AP restent en place (protocole du premier
  run W, inchangé).
