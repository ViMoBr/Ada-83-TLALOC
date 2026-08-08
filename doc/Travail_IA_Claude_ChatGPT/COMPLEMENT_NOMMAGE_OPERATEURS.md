# COMPLÉMENT au lot opérateurs utilisateur — nommage lettré à l'APPEL

## Lecture

Diagnostic exact : le corps de l'opérateur est nommé côté PRO par
CODE_SUBPROGRAM_BODY via `LETTERED_SUBNAME` (structures l.311 : `"+"` →
`_PLUS_`), mais CODE_PROCEDURE_CALL construit le nom d'appel avec
`PRINT_NAME` brut (instructions l.676) → `CALL … ,'+'_L2`, identifiant
invalide pour fasmg, et de toute façon désaccordé du PRO. Le chemin n'avait
jamais servi : avant le lot, aucun appel d'opérateur utilisateur n'empruntait
CODE_PROCEDURE_CALL. Raccord : la même transformation des deux côtés —
LETTERED_SUBNAME est l'identité pour un identificateur normal, donc AUCUN
autre FINC ne bouge à l'octet près.

Au passage, la table de LETTERED_SUBNAME porte un typo latent sur `"="` :
`"""=\"""` (guillemet, `=`, `\`, guillemet — quatre caractères) ne peut jamais
égaler `"="` — un `"="` utilisateur (légal en Ada 83 sur type limité privé)
tomberait sur le raise « opérateur non mappé ». Bruyant, donc sans victime
silencieuse possible, mais on le corrige dans le même geste.

Note de frontière consignée : l'AGRÉGAT en opérande d'un opérateur INFIXE
levait avant le lot le PROGRAM_ERROR de CODE_AGGREGATE (contexte sans
destination) — votre contournement en notation préfixée est le bon pour le
témoin, et les checks 1-2 gardent la couverture infixe DN_USED_OP. Après le
lot, la forme infixe route par CODE_PROCEDURE_CALL qui enveloppe les
agrégats-arguments en doublets anonymes : elle devrait compiler — à
réessayer un jour hors périmètre, sans churner le témoin.

---

## COMMIT 2-ter — deux modifications

### Modification 1 — expander-instructions.adb : nom lettré à l'appel

ANCRE (texte existant, inchangé, unique) :

```ada
    PROC_ID	: TREE		:= SUBPROGRAM_ORIGIN( D( SM_DEFN, USED_NAME_ID ) );
```

BLOC À SUPPRIMER (la ligne immédiatement sous l'ancre) :

```ada
    SUB_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, PROC_ID ) );
```

BLOC DE REMPLACEMENT :

```ada
    SUB_NAME	:constant STRING	:= LETTERED_SUBNAME( PRINT_NAME( D( LX_SYMREP, PROC_ID ) ) );	-- operateur utilisateur : nom en lettres, symetrique du PRO (structures, CODE_SUBPROGRAM_BODY) ; identite pour un identificateur (OPDEF_TEST)
```

### Modification 2 — expander-utils.adb : typo de la table sur "="

ANCRE (texte existant, inchangé, unique) :

```ada
      elsif SUB_NAME = """&"""  then return "_CONC_";
```

BLOC À SUPPRIMER (la ligne immédiatement sous l'ancre) :

```ada
      elsif SUB_NAME = """=\"""   then return "_EQ_";
```

BLOC DE REMPLACEMENT :

```ada
      elsif SUB_NAME = """="""   then return "_EQ_";
```

---

## Oracles (reprendre la cascade du commit 2 au point 1)

1. T1 reconstruit. `opdef_test.adb` (version notation préfixée pour 3-4)
   compilé, ASSEMBLÉ, exécuté : `RESULTAT : 6 OK, 0 ECHECS` + `OPDEF_TEST
   PASSE`. FINC du témoin : `CALL STANDARD.OPDEF_TEST_L1. ,_PLUS__L2`
   (et `_POW__…`, `_LT__…`) — mêmes noms que les PRO correspondants ;
   opérations sur DERIV inchangées (`ADD`/`MUL`).
2. FINC des témoins existants : BIT-IDENTIQUES (LETTERED_SUBNAME = identité
   hors opérateurs ; la ligne "=" ne change aucune émission existante).
3-6. Oracles 3 à 6 du lot, inchangés (filet vert ; diff de chaîne confiné +
   trace S bit-exacte ; T2 reconstruit, visée SEM_PHASE complète sur _standrd
   jusqu'à `_DURATION` + « Ok » ; puis retrait des sondes @PD).

Documentation : au commit 3 du lot, ajouter à la fin de l'entrée du piège
n° 140 (avant la ligne `Gardien : OPDEF_TEST.`) la phrase suivante :

```
    Raccord de nommage : l'APPEL passe par LETTERED_SUBNAME comme le
    PRO (l'un sans l'autre = identifiant fasmg invalide '+'_Lnn) ;
    typo latent de la table sur "=" corrige au meme lot.
```
