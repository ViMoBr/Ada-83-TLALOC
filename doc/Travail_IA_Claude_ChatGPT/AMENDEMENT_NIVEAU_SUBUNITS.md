# AMENDEMENT — lot subunits : le schéma DIANA n'a pas de cd_level sur package_id

Constat (FINC joint + diana_NODES.txt) : `dn_package_id` ne porte PAS l'attribut
`cd_level` (seuls variable/constant/param/iteration_id et procedure/function/
operator_id le portent). Le poseur de la modification 2.1 fait donc lever
PROGRAM_ERROR par l'accesseur DIANA (idl.adb:314) au stub de COEUR — le FINC
s'arrête après `endPRO CHECK` sur `!! PROCEDURE D : PAS D ATTRIBUT CD_LEVEL`.
Le nœud `stub` n'offre aucune case (lx_srcpos seul). Correction : ne RIEN
stocker pour les packages ; leur niveau (pas de frame) = celui du sous-programme
englobant le plus proche, retrouvé en remontant `XD_REGION` — motif déjà présent
(IS_IN_CURRENT_GENERIC, et TREE_VOID/"STANDARD" discriminés dans
CODE_PACKAGE_BODY). Pour une chaîne de packages jusqu'à la bibliothèque, la
remontée atteint TREE_VOID → 0 : comportement inchangé pour `test_subunit`
(parent = package de bibliothèque), oracle de confinement des FINC préservé.
La branche sous-programme (CD_LEVEL - 1) reste telle quelle : le canal existe
dans le schéma et le témoin a bien jugé rouge avant commit.

Les trois modifications s'appliquent à l'état APRÈS le commit 2 livré.

---

## COMMIT 2-bis — expander-structures.adb (même fichier, 3 modifications)

### Modification 1 — retrait du poseur illégal (CODE_PACKAGE_BODY)

ANCRE (texte existant, inchangé, unique) :

```ada
      if  PACK_BODY.TY = DN_STUB  then
```

BLOC À SUPPRIMER (la ligne ajoutée par la modification 2.1) :

```ada
        DI( CD_LEVEL, PACK_DEF, INTEGER( CODI.CUR_LEVEL ) );					-- niveau d'execution du contenu du corps separe (un package n'ouvre pas de frame) ; lu par CODE_COMPILATION_UNIT a la compilation du subunit -- meme canal bibliotheque que CD_LABEL
```

BLOC DE REMPLACEMENT : (néant — suppression pure ; la branche stub redevient
exactement son état d'origine)

### Modification 2 — commentaire de la branche DN_SUBUNIT (mise en accord)

ANCRE (texte existant, inchangé, unique) :

```ada
			--| canal bibliotheque que CD_LABEL.  Invariant : CD_LEVEL d'un id de
```

BLOC À SUPPRIMER :

```ada
			--| INC_LEVEL) ; CD_LEVEL d'un package separe = niveau du contexte du
			--| stub (pose par CODE_PACKAGE_BODY, sans frame).  Demarrer a 0
```

BLOC DE REMPLACEMENT :

```ada
			--| INC_LEVEL).  Un package separe n'a PAS de cd_level (schema DIANA :
			--| dn_package_id n'en porte aucun) ; sans frame, son niveau = celui du
			--| sous-programme englobant le plus proche (remontee XD_REGION, les
			--| packages sont transparents ; TREE_VOID = bibliotheque).  Demarrer a 0
```

### Modification 3 — branche package : remontée de région au lieu du CD_LEVEL

ANCRE (texte existant, inchangé, unique) :

```ada
        if  SUB_BODY.TY = DN_SUBPROGRAM_BODY  then
```

BLOC À SUPPRIMER (deux lignes plus bas, la branche elsif complète) :

```ada
        elsif  SUB_BODY.TY = DN_PACKAGE_BODY  then
	CODI.CUR_LEVEL := DI( CD_LEVEL, FIRST_DECL_ID );					-- pas de frame propre : niveau du contexte du stub
```

BLOC DE REMPLACEMENT :

```ada
        elsif  SUB_BODY.TY = DN_PACKAGE_BODY  then
	declare
	  REGION : TREE := D( XD_REGION, FIRST_DECL_ID );
	begin
	  while  REGION /= TREE_VOID  and then  REGION.TY = DN_PACKAGE_ID  loop		-- packages transparents (y compris STANDARD -> TREE_VOID ensuite)
	    REGION := D( XD_REGION, REGION );
	  end loop;
	  if  REGION = TREE_VOID  then
	    CODI.CUR_LEVEL := 0;								-- chaine de packages jusqu'a la bibliotheque : cas test_subunit, inchange
	  elsif  REGION.TY = DN_PROCEDURE_ID  or  REGION.TY = DN_FUNCTION_ID
	     or  REGION.TY = DN_OPERATOR_ID  then
	    CODI.CUR_LEVEL := DI( CD_LEVEL, REGION );						-- niveau d'execution du frame du sous-programme = niveau de ses declarations
	  else
	    CODI.TROU( "CODE_COMPILATION_UNIT region de subunit package", REGION );		-- generique / task : hors corpus, refus bruyant
	  end if;
	end;
```

---

## Oracles du commit 2-bis (remplacent l'oracle 1 du commit 2 ; les 2-5 demeurent)

1. **Compilation du parent complète** : `./a83.sh ./ ./sublvl_test.ada W` sans
   PROGRAM_ERROR ; le FINC va jusqu'au `endPRO` de SUBLVL_TEST et ne contient
   aucune ligne `!!`.
2. **SUBLVL_TEST vert** : parent + les deux subunits compilés, édition, exécution →
   `RESULTAT : 5 OK, 0 ECHECS` + `SUBLVL_TEST PASSE`. Lecture FINC des subunits :
   `PRO INTERNE_*` … `ELB 2` ; dans COEUR, `PRO BATTRE_*` … `ELB 2` (déclaré au
   niveau 1, corps à 2) ; `La 1, …_FEU.use__info` partout.
3. Oracles 2 à 5 du commit 2 inchangés — en particulier : FINC de
   `test_subunit-the_subpack` (parent package de bibliothèque, remontée → TREE_VOID
   → 0) bit-identique à l'avant-lot.

---

## Retouche du COMMIT 3 (si non encore appliqué, corriger le texte du piège 138)

ANCRE (dans le bloc à insérer livré précédemment) :

```
    bibliotheque (parent package, base 0) — PAR/LIB_PHASE passaient.
```

BLOC À SUPPRIMER :

```
    Canal de correction : CD_LEVEL de la premiere declaration (stub /
    spec), qui traverse la bibliotheque comme CD_LABEL ; poseur ajoute
    au stub de package (pas de frame : niveau du contexte).
```

BLOC DE REMPLACEMENT :

```
    Canal de correction : CD_LEVEL de la premiere declaration (stub /
    spec) pour un SOUS-PROGRAMME — il traverse la bibliotheque comme
    CD_LABEL. Un package separe n'a PAS de cd_level dans le schema
    DIANA (dn_package_id : cd_compiled seul ; toute pose leve
    PROGRAM_ERROR idl.adb:314) : son niveau se RECALCULE par remontee
    XD_REGION jusqu'au sous-programme englobant (packages
    transparents, TREE_VOID = bibliotheque -> 0).
```
