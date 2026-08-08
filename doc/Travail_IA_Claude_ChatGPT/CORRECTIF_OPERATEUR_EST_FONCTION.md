# LOT correctif — « un opérateur EST une fonction » : épilogue RTD et chemins frères

## Chaîne causale close (segfault 0x406f6a du témoin, rax = 8)

Le FINC de `_PLUS__L5` finit par **`RTD prm_siz`** — l'épilogue de PROCÉDURE,
qui dépile AUSSI le slot-résultat — là où toute fonction émet `RTD prm_siz-8`
(INTEGER_POW, MK…). Après l'appel, le sommet de pile est le `LI _PAIRE.size`
de la préparation de destination : **8** (PAIRE = 2 × INTEGER 32 bits), que le
`La` déréférence — votre relevé au registre près (rax = 8, `mov (%rax),%rax`).
L'émetteur d'épilogue teste `SOURCE_NAME.TY = DN_FUNCTION_ID` : un corps
d'opérateur (DN_OPERATOR_ID) reçoit l'épilogue de procédure. La collision ANON
(lot précédent, suffixe NEW_LABEL) était réelle mais MASQUÉE par ce trou plus
profond du même territoire.

Audit systématique de la famille — tout test `DN_FUNCTION_ID` sans
`DN_OPERATOR_ID` dans les émetteurs (`grep DN_FUNCTION_ID expander*.adb |
grep -v DN_OPERATOR_ID`) : huit sites, quatre innocents (unités de
bibliothèque ×2 — un opérateur ne peut pas en être une —, un commentaire,
REGIONS_PATH déjà corrigé), et QUATRE coupables, corrigés d'un seul lot :
l'épilogue des corps réels (structures), l'épilogue des corps synthétisés
(declarations), le chemin d'appel PRÉFIXÉ `PKG."<"(…)` de CODE_SELECTED —
vos checks 3-4 seraient tombés dessus dès le segfault levé (retombée « PAS
FAIT » silencieuse) — et l'exclusion d'appel sélectionné des initialisations.

---

## COMMIT — 4 modifications

### Modification 1 — expander-structures.adb : épilogue des corps réels

ANCRE (texte existant, inchangé, unique) :

```ada
      if  CODI.NO_SUBP_PARAMS = FALSE  then  PUT( tab & "prm_siz" );
```

BLOC À SUPPRIMER (la ligne immédiatement sous l'ancre) :

```ada
        if  SOURCE_NAME.TY = DN_FUNCTION_ID  then
```

BLOC DE REMPLACEMENT :

```ada
        if  SOURCE_NAME.TY = DN_FUNCTION_ID  or  SOURCE_NAME.TY = DN_OPERATOR_ID  then		-- OPDEF_TEST, segfault rax=8 : un OPERATEUR est une fonction -- epilogue prm_siz-8, le slot resultat reste a l'appelant
```

### Modification 2 — expander-declarations.adb : épilogue des corps synthétisés

ANCRE (texte existant, inchangé, unique — la ligne de CODE émettant
prm_siz-8, tab + 4 espaces) :

```ada
	    PUT_LINE( tab & "RTD" & tab & "prm_siz-8" );
```

BLOC À SUPPRIMER (la ligne immédiatement AU-DESSUS de l'ancre) :

```ada
	  if  SOURCE_NAME.TY = DN_FUNCTION_ID  then
```

BLOC DE REMPLACEMENT :

```ada
	  if  SOURCE_NAME.TY = DN_FUNCTION_ID  or  SOURCE_NAME.TY = DN_OPERATOR_ID  then	-- symetrie avec l'epilogue des corps reels (un operateur est une fonction)
```

### Modification 3 — expander-expressions.adb : appel préfixé PKG."op"(…)

ANCRE (texte existant, inchangé, unique) :

```ada
        elsif  DESIGNATOR_DEFN.TY = DN_FUNCTION_ID
```

BLOC À SUPPRIMER : l'ancre elle-même (cette seule ligne — le `then` de la
ligne suivante est conservé).

BLOC DE REMPLACEMENT :

```ada
        elsif  DESIGNATOR_DEFN.TY = DN_FUNCTION_ID
	or else  DESIGNATOR_DEFN.TY = DN_OPERATOR_ID						-- OPDEF_TEST 3-4 : appel PREFIXE d'un operateur utilisateur (OPDEF_TEST."<"(..)) -- sinon retombee "PAS FAIT" silencieuse
```

### Modification 4 — expander-declarations.adb : init par appel sélectionné

ANCRE (texte existant, inchangé, unique) :

```ada
	  elsif  ( INIT_EXP.TY = DN_SELECTED
```

BLOC À SUPPRIMER (la ligne immédiatement sous l'ancre) :

```ada
		  and then  D( SM_DEFN, D( AS_DESIGNATOR, INIT_EXP ) ).TY /= DN_FUNCTION_ID )
```

BLOC DE REMPLACEMENT :

```ada
		  and then  D( SM_DEFN, D( AS_DESIGNATOR, INIT_EXP ) ).TY /= DN_FUNCTION_ID
		  and then  D( SM_DEFN, D( AS_DESIGNATOR, INIT_EXP ) ).TY /= DN_OPERATOR_ID )
```

---

## Oracles (dans l'ordre)

1. T1 reconstruit. OPDEF_TEST : `RESULTAT : 8 OK, 0 ECHECS` + `OPDEF_TEST
   PASSE` — cette fois les huit, y compris 3-4 (préfixés) et 7-8 (collision,
   suffixe déjà posé). FINC du témoin : `RTD	prm_siz-8` dans `_PLUS__L5`,
   `_POW__L8`, `_LT__L13` ; contrôle doublons ANON toujours vide.
2. FINC des témoins hors OPDEF_TEST : BIT-IDENTIQUES (aucun opérateur
   utilisateur, aucun appel préfixé d'opérateur, aucun init sélectionné
   d'opérateur ailleurs dans le filet).
3. Filet vert ; chaîne régénérée, diff confiné aux unités à opérateurs
   utilisateur ; trace S null_prog bit-exacte.
4. T2 reconstruit : `./A83.sh ./ ../_standrd.ads M` — visée : listing des
   déclarations complet jusqu'à `_DURATION` + « Ok » (SEM_PHASE bootstrappée
   COMPLÈTE sur _standrd). Puis retrait des sondes @PD.

---

## Documentation — PIEGES.md, ajout en fin de fichier (après le n° 141)

ANCRE : la dernière ligne du fichier (entrée n° 141).

BLOC À SUPPRIMER : (néant — insertion sous l'ancre)

BLOC À INSÉRER :

```
142. **UN OPERATEUR EST UNE FONCTION : tout test DN_FUNCTION_ID d'un
    emetteur doit inclure DN_OPERATOR_ID.** Cinquieme et sixieme faces
    du territoire du piege n 140 : l'epilogue RTD testait
    DN_FUNCTION_ID seul -- un corps d'operateur recevait RTD prm_siz
    (epilogue de PROCEDURE), le slot resultat etait depile, et le La
    de l'appelant dereferencait le LI de taille reste au sommet
    (segfault rax = 8 = _PAIRE.size, temoin OPDEF). Trois freres
    corriges au meme lot : epilogue des corps synthetises, appel
    PREFIXE PKG."op"(..) de CODE_SELECTED (retombee silencieuse), init
    par appel selectionne. Recensement mecanique de la famille :
    grep DN_FUNCTION_ID expander*.adb | grep -v DN_OPERATOR_ID --
    a repasser apres tout nouveau test de genre de sous-programme ;
    les seuls survivants legitimes sont les unites de bibliotheque
    (un operateur ne peut pas en etre une). Lecon jumelle du n 141 :
    la collision ANON etait reelle mais MASQUEE par ce trou -- deux
    familles peuvent partager un meme symptome, corriger la premiere
    ne dispense pas de re-deriver la chaine causale sur le crash
    suivant. Gardien : OPDEF_TEST 1-8 complet. (session 8 aout)
```
