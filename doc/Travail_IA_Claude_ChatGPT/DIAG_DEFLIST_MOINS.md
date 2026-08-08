# DIAGNOSTIC — HEAD sur deflist vide de `"-"` (SEM_PHASE, WALK de SHORT_INTEGER)

## Lecture de l'anomalie

Le point exact : WALK atteint le premier `DN_FUNCTION_CALL` de tout le source
(le `-` unaire de `-2**15`, SLOC 15,34 du dump). Les initialisations du declare
(fix_pre l.389-398) s'évaluent avant tout : `PARAM := HEAD(LIST(GENERAL_ASSOC_S))`
(liste d'arbre, non vide au dump), puis
`BLTN_OPERATOR_ID := HEAD ( LIST ( D ( LX_SYMREP, NAME ) ) )` — la XD_DEFLIST du
symbole `"-"`, garnie par MAKE_PREDEF_IDS quelques instants plus tôt. C'est le
premier accès en LECTURE à une deflist de toute l'exécution (BOOLEAN n'en lit
aucune ; les écritures de DEFINE_ID ne sont pas encore relues). Message reçu =
celui du HEAD nu (pas le « SYMBOL NOT DEFINED » de HEAD_DEFN, pas le « PAS DE
LISTE ASSOCIEE » de LIST) : la deflist EXISTE et est VIDE — pour le symbole que
consulte l'arbre.

Points déjà établis par les pièces jointes :
- Le dump montre TOUTES les occurrences de `-` sur le MÊME nœud
  `[DN_SYMBOL_REP,P3,L30]`, créé à l'init d'IDL (idl.adb l.238,
  `STORE_SYM( """-""" )`) : la déduplication HASH_SEARCH du binaire bootstrappé
  fonctionne avec les chaînes du LEXEUR et les littéraux.
- PRINT_NAME est sain dans le bootstrappé (STANDARD/BOOLEAN/SHORT_INTEGER
  imprimés justes par DEFINE_ID).
- Non prouvé, et premier passage à l'exécution : la chaîne CONSTRUITE
  `'"' & ITEM_NAME( 1..ITEM_LENGTH ) & '"'` avec
  `ITEM_NAME := BLTN_TEXT_ARRAY ( OP_NAME )` — soit, dans l'ordre des suspects :
  (a) l'ÉLABORATION de `BLTN_TEXT_ARRAY` (agrégat nommé constant, tableau de
  STRING_3, associations dans le désordre, rembourrage `!` — cousin direct du
  piège n° 136 côté tableaux-de-tableaux) ; (b) la caténation/tranche passée à
  STORE_SYM (HASH_SEARCH la préfixe d'un octet de longueur et la convertit en
  TREEs par UNCHECKED_CONVERSION sur bornes dynamiques) ; (c) la plomberie
  d'écriture `LIST ( SYM, INSERT ( LIST ( SYM ), NEW_ID ) )`.

Un run avec trois sondes discrimine les trois. Méthode des sondes @GT/@PC/@AP
(ORACLES_TESTS) : greppables, ASCII pur, retrait final par grep. Le fichier est
CRLF/latin-1 : coller les lignes en conservant les fins de ligne de l'éditeur.

---

## COMMIT DIAG — sondes @PD dans idl-sem_phase-fix_pre.adb (2 modifications)

### Modification 1 — sonde @PD1 : ce que la boucle des opérateurs stocke

ANCRE (texte existant, inchangé, unique — l'autre `SM_OPERATOR` du fichier est
dans un `DI(...)`, texte différent) :

```ada
			SM_OPERATOR	=> OP_CLASS'POS ( OP_NAME )
```

BLOC À SUPPRIMER (la ligne immédiatement sous l'ancre) :

```ada
			);
```

BLOC DE REMPLACEMENT (sans aucune caténation : si la caténation est la famille
fautive, les sondes ne doivent pas mentir) :

```ada
			);
	     PUT( "@PD1 " );
	     PUT( OP_CLASS'IMAGE( OP_NAME ) );
	     PUT( " [" );
	     PUT( ITEM_NAME );
	     PUT( "] L =" );
	     PUT( INTEGER'IMAGE( ITEM_LENGTH ) );
	     PUT( " SYM = " );
	     PUT( NODE_REP( SYM ) );
	     PUT( " " );
	     PUT_LINE( PRINT_NAME( SYM ) );
```

### Modification 2 — sonde @PD3 : relecture de la deflist de `"-"` en sortie

ANCRE (texte existant, inchangé, unique) :

```ada
         ID_LIST := NEW_ID_LIST;
```

BLOC À SUPPRIMER : (néant — insertion IMMÉDIATEMENT AVANT l'ancre)

BLOC À INSÉRER (FIND_SYM avec le LITTÉRAL, même chemin sûr que l'init d'IDL) :

```ada
         declare
	    MOINS	: TREE	:= FIND_SYM( """-""" );
         begin
	    PUT( "@PD3 " );
	    if MOINS = TREE_VOID then
	       PUT_LINE( "SYMBOLE MOINS ABSENT DE LA TABLE" );
	    elsif IS_EMPTY( LIST( MOINS ) ) then
	       PUT( NODE_REP( MOINS ) );
	       PUT_LINE( " DEFLIST VIDE" );
	    else
	       PUT( NODE_REP( MOINS ) );
	       PUT( " DEFLIST TETE = " );
	       PUT_LINE( NODE_REP( HEAD( LIST( MOINS ) ) ) );
	    end if;
         end;
```

---

## Oracle du run diagnostic

Recompiler FIX_PRE (T1), relancer `./A83.sh ./ ../_standrd.ads M` par
TLALOC(TLALOC), puis lire les 21 lignes @PD1 + la ligne @PD3. Référence attendue
pour les entrées saines, ex. OP_UNARY_MINUS :
`@PD1 OP_UNARY_MINUS [-!!] L = 1 SYM = [DN_SYMBOL_REP,P3,L30] "-"`.

Grille de décision :

1. Crochets `[...]` faux (texte d'un autre opérateur, octets parasites, ordre
   mélangé entre les 21 lignes) → l'AGRÉGAT de BLTN_TEXT_ARRAY est mal élaboré :
   famille expander « agrégat nommé de tableau de tableaux » (parent du piège
   n° 136). Chantier suivant : témoin dédié + agrégats dans types_decls.
2. Crochets justes, `L` juste, mais `SYM` sur un nœud NEUF (page tardive, pas
   P3,L30) pour les opérateurs pré-stockés → HASH_SEARCH ne retrouve pas le
   symbole quand l'argument est CONSTRUIT : famille caténation / passage de
   tranche (bornes, octet de longueur). Témoin dédié caténation+tranches.
3. @PD1 tout juste (P3,L30 pour `"-"`, deux lignes : OP_UNARY_MINUS et
   OP_MINUS) mais @PD3 `DEFLIST VIDE` → l'écriture
   `LIST( SYM, INSERT( LIST( SYM ), NEW_ID ) )` perd la valeur : famille
   INSERT / procedure LIST / DABS en écriture sur symbole.
4. @PD1 et @PD3 tous justes (`DEFLIST TETE = [DN_BLTN_OPERATOR_ID,…]`) →
   le stockage est sain et le HEAD fautif est AILLEURS que la consultation de
   l'opérateur — premier suspect alors : la liste d'assoc EN MÉMOIRE au moment
   du WALK (à confronter au dump : sonde suivante au site l.396). Me
   communiquer la sortie, on itère.
5. @PD3 `ABSENT` → table de hachage corrompue entre l'init et FIX_PRE
   (improbable ; me communiquer la sortie complète).

Dans tous les cas, joindre les 22 lignes @PD au retour. Retrait des sondes une
fois la famille close : grep @PD (même protocole que @GT/@PC/@AP).
