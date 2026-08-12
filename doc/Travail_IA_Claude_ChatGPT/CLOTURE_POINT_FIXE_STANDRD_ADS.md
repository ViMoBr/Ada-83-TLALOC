# CLÔTURE — point fixe atteint sur _standrd.ads

## Le juge a parlé

    18 932 octets = 18 932 octets, cmp muet :
    FINC( TLALOC(TLALOC), _standrd.ads ) ≡ FINC( TLALOC(gnat), _standrd.ads )
    À L'OCTET PRÈS (fins de ligne CRLF près).

Le compilateur bootstrappé exécute PAR, SEM et EXPANDER sur _standrd.ads et
émet exactement ce que le compilateur de référence émet. PACKV_TEST 6/6 vert
confirme le patch alignement (rouge d'avant-patch non capturé : le dire tel
quel au journal). C'est la clôture de la campagne ouverte au segfault
0x4028d8.

---

## COMMIT 1 — retrait des sondes @PN (idl-sem_phase-fix_pre.adb)

ANCRE (texte existant, inchangé, unique) :

```ada
         ID_LIST := NEW_ID_LIST;
```

BLOC À SUPPRIMER (les treize lignes immédiatement AU-DESSUS de l'ancre —
le bloc @PN inséré au diagnostic, entre le bloc @PD3 et l'ancre) :

```ada
         declare
	    use UARITH;
	    PA	: TREE	:= U_VALUE( "2147483648" );
	    PB	: TREE	:= U_VALUE( "2" ) ** U_VALUE( "31" );
	    PC	: TREE	:= U_VALUE( "2" ) ** U_VALUE( "31" ) - U_VALUE( "1" );
         begin
	    PUT( "@PN1 " );
	    PUT_LINE( PRINT_NUM( PA ) );
	    PUT( "@PN2 " );
	    PUT_LINE( PRINT_NUM( PB ) );
	    PUT( "@PN3 " );
	    PUT_LINE( PRINT_NUM( PC ) );
         end;
```

BLOC DE REMPLACEMENT : (néant — suppression pure)

Enchaîner avec le retrait des sondes @PD1 et @PD3 : instructions déjà
livrées (lot agrégats, COMMIT 2, modifications 2.1 et 2.2). Oracle commun :
`grep -rn "@PD\|@PN" *.adb` vide ; recompilation de fix_pre ; le run W sur
_standrd.ads rejoue SANS lignes de sonde et le FINC produit reste
bit-identique à la référence.

---

## COMMIT 2 — documentation restante (ORACLES_TESTS.md)

Les entrées AGGSTR_TEST et OPDEF_TEST ont leurs textes dans les lots
respectifs ; les pièges 139 à 143 aussi. Restent trois entrées de témoins à
ajouter — même ancre que les précédentes :

ANCRE (titre de section existant) :

```
### Sondes @GT/@PC/@AP (hors filet, outil de diagnostic bootstrap)
```

BLOC À SUPPRIMER : (néant — insertion AVANT l'ancre)

BLOC À INSÉRER :

```
### RECSTR_TEST et RECSTR2_TEST (lot chiffres longs, 8-9 aout 2026, 4+6 assertions)

Deux unites jumelles : recstr_test.adb (SQUELETTE de RECURSE_DOUBLETS --
recursion sans parametre, variable montante mutee, deux constantes STRING
locales d'appels, recursion en tete de catenation chainee) et
recstr2_test.adb (la CHAIR : tranches pleines de constantes en catenation,
agregat STRING'(1..COMPL => '0') a bornes dynamiques et VIDES, SHORT
represente 16 bits, mod 10_000, donnees de 2147483647). Historique :
VERTS D'ORIGINE tous deux -- ce sont les temoins qui ont DISCULPE PRINT_NUM
et retourne le soupcon vers UARITH/alignement (piege n 143). Attendu :
« 4 OK / RECSTR_TEST PASSE » et « 6 OK / RECSTR2_TEST PASSE ». A repasser
apres toute retouche des catenations, des constantes dynamiques, des
tranches ou de CO_VAR.

### PACKV_TEST (lot alignement packe, 9 aout 2026, 6 assertions)

Une unite : packv_test.adb. Record pragma PACK au motif VECTOR d'UNIV_OPS
(L, S, tableau packe d'UD 16 bits) : ecriture indexee chiffre a chiffre,
relecture, copie record entiere, non-aliasing apres copie, egalites de
tranches packees. Gardien du piege n 143 (STATIC_TYPE_ALIGN_BYTES et
pragma PACK). Historique : pose APRES le patch (rouge d'avant-patch non
capture -- constate vert 6/6 sur T1 patche). Attendu : « RESULTAT : 6 OK,
0 ECHECS / PACKV_TEST PASSE ». A repasser apres toute retouche de
STATIC_TYPE_ALIGN_BYTES, du layout des records packes, de STATOFS ou du
chantier n 117.

```

---

## COMMIT 3 — journal (JOURNAL_SESSIONS.md, ajout en fin de fichier)

BLOC À INSÉRER (ancre : fin de fichier, sous la dernière session) :

```
## Sessions 8-9 aout 2026 -- campagne du segfault 0x4028d8 : POINT FIXE
## ATTEINT SUR _standrd.ads

Juge final : FINC(TLALOC(TLALOC)) IDENTIQUE A L'OCTET PRES a
FINC(TLALOC(gnat)) sur _standrd.ads -- 18 932 octets, CRLF pres, cmp muet.
Le bootstrappe execute PAR + SEM + EXPANDER complets sur la spec standard.

Familles closes, dans l'ordre de la chaine (pieges 138 a 143) :
138 subunits a parent porteur de frame (CUR_LEVEL, canal CD_LEVEL +
    remontee XD_REGION) -- gardien SUBLVL_TEST ;
139 agregat de tableau DE tableaux, composante non-agregat en voie
    scalaire (garde de profondeur EMIT_ONE_COMP) -- gardien AGGSTR_TEST ;
140 operateurs UTILISATEUR emis comme predefinis (dispatch DN_USED_OP) +
    trois raccords de nommage (appel lettre, REGIONS_PATH, table "=") ;
141 collision des doublets anonymes sur infixe (suffixe NEW_LABEL --
    lecon : le nommage positionnel ne peut pas separer une expression de
    son operande gauche) ;
142 UN OPERATEUR EST UNE FONCTION : epilogue RTD prm_siz-8 + appel
    prefixe + init selectionne (recensement grep au piege) -- gardien
    OPDEF_TEST 1-8 ;
143 STATIC_TYPE_ALIGN_BYTES et pragma PACK (patch V.M. ; desaccord
    type-info/consommateurs A CITER ICI apres les 4 greps du lot) --
    gardien PACKV_TEST ; PRINT_NUM disculpee par RECSTR_TEST et
    RECSTR2_TEST (verts d'origine, au filet).

Lecons de methode gravees : deux familles peuvent partager un symptome
(141 masquee par 142) -- re-deriver la chaine causale a chaque crash ; une
boucle infinie while-decrementante = parametre astronomique = chercher le
site d'appel ; un alignement ne corrompt jamais seul -- nommer le
desaccord.

Sondes @PD et @PN retirees. Suivant en file : segfault de _standrd.adb
(corps de la bibliotheque standard), meme protocole.
```

---

## Reste en file (dans l'ordre)

1. Les 4 greps du désaccord align (lot précédent) → compléter le journal et
   le piège n° 143 avec le nombre exact qui a changé.
2. Vérification miroir STATOFS/117 (l'en-tête de la fonction l'exige).
3. _standrd.adb : reprendre au segfault avec le rapport gdb habituel
   (adresse, registres, backtrace + carte hexa_show, FINC appelant/appelé).
