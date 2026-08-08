# COMPLÉMENT 2 au lot opérateurs utilisateur — chemins de régions à travers un corps d'opérateur

## Lecture

Troisième face du même nommage, côté CHEMINS : REGIONS_PATH (expander-utils.adb)
imprime chaque composante de région en `PRINT_NAME` brut, et son test de
suffixe d'étiquette ne connaît que DN_PROCEDURE_ID / DN_FUNCTION_ID. Pour une
variable déclarée DANS le corps d'un opérateur (le `L_SPREAD` du bloc de
`"<"` d'UARITH), la composante sort `'<'` — nom invalide pour fasmg ET sans le
suffixe `_L<n>` — alors que le namespace physique ouvert par le PRO est
`_LT__L<n>` (nom lettré + étiquette, CODE_SUBPROGRAM_BODY). Chemin jamais
exercé avant le lot : aucun corps d'opérateur utilisateur n'était appelé, donc
jamais traversé par un accès chemin-complet. Deux raccords dans la même
procédure : LETTERED_SUBNAME sur la composante (identité pour un
identificateur — aucun autre chemin ne bouge), et DN_OPERATOR_ID ajouté au
test d'étiquette (operator_id porte cd_label, même canal que
procedure/function).

---

## COMMIT 2-quater — expander-utils.adb, REGIONS_PATH (2 modifications)

### Modification 1 — composante en nom lettré

ANCRE (texte existant, inchangé, unique) :

```ada
    REGION	: TREE		:= D( XD_REGION, ID );
```

BLOC À SUPPRIMER (la ligne immédiatement sous l'ancre) :

```ada
    RGN_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, REGION ) );
```

BLOC DE REMPLACEMENT :

```ada
    RGN_NAME	:constant STRING	:= LETTERED_SUBNAME( PRINT_NAME( D( LX_SYMREP, REGION ) ) );	-- region = corps d'OPERATEUR utilisateur : composante en lettres (_LT_...), accordee au PRO ; identite sinon (OPDEF_TEST)
```

### Modification 2 — suffixe d'étiquette pour une région opérateur

ANCRE (texte existant, inchangé, unique — l'occurrence de la branche
générique a une expression interne différente) :

```ada
        PUT( '_' & LABEL_STR( LABEL_TYPE( DI( CD_LABEL, REGION ) ) ) );
```

BLOC À SUPPRIMER (la ligne immédiatement AU-DESSUS de l'ancre) :

```ada
      if  REGION.TY = DN_PROCEDURE_ID  or  REGION.TY = DN_FUNCTION_ID  then
```

BLOC DE REMPLACEMENT :

```ada
      if  REGION.TY = DN_PROCEDURE_ID  or  REGION.TY = DN_FUNCTION_ID
      or else  REGION.TY = DN_OPERATOR_ID  then
```

---

## Oracles

1. T1 reconstruit ; chaîne régénérée ; `./comp_ada_comp.sh A` passe
   IDL-SEM_PHASE-UARITH.FINC et tout le reste. Contrôle direct des résidus :
   `grep -n "\.'" *.FINC` et `grep -n "'" IDL-SEM_PHASE-UARITH.FINC` — plus
   aucune composante de chemin entre apostrophes ; les chemins des variables
   des corps d'opérateurs lisent `…UARITH._LT__L<n>.BLOCK__2.L_SPREAD_disp`,
   accordés aux PRO.
2. FINC des témoins du filet : BIT-IDENTIQUES sauf OPDEF_TEST (seul témoin à
   variables dans des corps d'opérateurs — ses chemins internes changent,
   c'est attendu et à constater au diff).
3. Cascade inchangée : OPDEF_TEST 6/6 ; filet vert ; diff de chaîne confiné +
   trace S bit-exacte ; T2 reconstruit → `_standrd.ads` M, visée listing
   complet jusqu'à `_DURATION` + « Ok » ; puis retrait des sondes @PD.

Documentation : pour le commit 3 du lot, remplacer la phrase de raccord
donnée au complément précédent par celle-ci (elle couvre les trois faces) :

```
    Raccord de nommage EN TROIS FACES, toutes accordees au PRO lettre :
    l'APPEL (CODE_PROCEDURE_CALL), le CHEMIN de regions (REGIONS_PATH :
    composante lettree + suffixe _L<n> etendu a DN_OPERATOR_ID), et la
    table elle-meme (typo latent sur "=" corrige). L'un sans l'autre =
    identifiant fasmg invalide ('+'_Lnn, chemin .'<'.) au premier corps
    d'operateur reellement appele ou traverse.
```
