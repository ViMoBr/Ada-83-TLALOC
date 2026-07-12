# MISE À JOUR DE CONTEXTE — PILIER CHECKS RUNTIME (9–11 juillet 2026)

Blocs à coller, un par fichier cible. La note complète v1.4 est livrée
à part (NOTE_MODELE_CHECKS_v1.md) : elle REMPLACE la version du dépôt.

---

## 1. ETAT_PILIERS.md

### 1a. AJOUTER un bloc pilier (section des piliers clos) :

```
## Pilier CHECKS RUNTIME — PÉRIMÈTRE 1 CLOS (11 juillet 2026)

Amont du pilier 11 : comparer-et-brancher vers deux trampolines
uniques (ce_raise_/ne_raise_, wrapper FAS). Checks livrés et jugés :
gamme scalaire aux SEPT sites (affectation, init de déclaration,
param in, return, conversion, qualification, corps générique partagé
via GFP/_ENUM_USE_INFO), longueurs des logiques composites
(dette D3-contrôle SOLDÉE), index (quatre variantes de CODE_INDEXED),
division par zéro (/, mod, rem → NUMERIC_ERROR, fidélité LRM 83).
Commutateur global CODI.CHECKS_ENABLED — défaut TRUE, RÉGIME
PERMANENT ; OFF réservé au tri des fossiles. Élision : sous-type =
type de base (comparaison de nœuds) + garde n° 80 (sous-types
anonymes) + statique prouvé. Témoins : CHK_TEST0/1, CHK_LEN0,
CHK_IDX0, CHK_DIV0, CHK_ANON0, CHK_CSTPRM0/1/2, CHK_PREDEF0.
Filet + ACVC verts checks ON et OFF. Note : NOTE_MODELE_CHECKS v1.4.

Campagne de fossiles associée (voir PIEGES n° 80–84) : IDENT_* de
l'ACVC ressuscités (n° 81, actuels constants fantômes — trois
familles), oscillation fasmg BT/BF soldée (n° 82, tous sauts rel32),
amorçage STANDARD réparé (n° 83, LINK 0 avant _STANDRD), lecture des
formels génériques in-out réparée (n° 84, adaptateurs INADR/OUTADR
branchés côté lecture).

DETTES PÉRIMÈTRE 2 (consignées, note §8) : overflow (NUMERIC_ERROR
après chaque op — coût), STORAGE_ERROR (bump allocator), gamme
fixed/float (bornes fixed élaborées SCALÉES : comparaison directe
possible), discriminants (avec pilier 3.7 bis), null access sur .all,
checks d'élaboration (PROGRAM_ERROR), copy-back des out (6.4.1 côté
retour), contraintes ANONYMES d'objet (n° 80-a), pragma SUPPRESS,
élision d'index statique (affaire de l'optimiseur futur).
```

### 1b. Dans la ligne « Option A — checks runtime ... le mécanisme les
attend » : REMPLACER par « Option A — FAITE (pilier checks clos) ».

---

## 2. PIEGES.md — vérifier que les cinq entrées y sont
(livrées au fil des sessions ; les recoller sinon) :

- n° 80 + son RECTIFICATIF (livraisons FOSSILE-80 et RECTIFICATIF-80B)
- n° 81 + appendice composites/privés (FOSSILE-81, -81BIS, -81TER)
- n° 82 (LIVRAISON_CONVERGENCE_BT_BF, M4)
- n° 83 (LIVRAISON_PIEGE-83_LINK0, M3)
- n° 84 (LIVRAISON_FOSSILE-84, M4)

### AJOUTER en appendice du n° 71 (le dump avant l'hypothèse) :

```
  Appendice n° 71 (11 juillet, E-D6) : la règle vaut aussi pour les
  IDIOMES : un idiome LLIR donné DE MÉMOIRE ou en paraphrase au lieu
  d'une citation de l'émetteur a coûté une session de débogage (le
  « La GFP » de GENERIC_FIRST_LAST perdu dans le résumé — pile
  décalée d'un cran). Citer l'émetteur, jamais le résumer. Corollaire
  du n° 71 : quatre sur quatre.
```

### AJOUTER en appendice du n° 80 (leçon de triage, si pas déjà collée
avec le rectificatif) :

```
  Leçon de triage (n° 80/81) : quand une cause plus profonde est
  découverte, RÉ-AUDITER ce que chaque hypothèse antérieure explique
  encore. Une dette fantôme (80-b) a vécu un jour de trop faute de ce
  ré-audit.
```

---

## 3. ORACLES_TESTS.md — bloc à coller (témoins permanents du pilier)

```
## Témoins du pilier CHECKS (permanents au filet, checks ON)

CHK_TEST0  — gamme d'affectation (E-A) : 1..5 OK, 6 sentinelle
             CONSTRAINT_ERROR, $? = 1. Contre-épreuve OFF : 2,3,4 KO.
CHK_LEN0   — LEN_G=LEN_D (E-B) : 1..4 OK (dont tranches et tableaux
             nuls), 5 sentinelle CONSTRAINT_ERROR, $? = 1.
CHK_IDX0   — index (E-C) : 1..9 OK (quatre variantes, multi-dim,
             négatif, descripteur), 10 sentinelle, $? = 1.
CHK_TEST1  — gamme six sites (E-D) : 1..5 OK, 6a OK T = 9, 7 OK,
             8 sentinelle CONSTRAINT_ERROR, $? = 1. 6b consigne : la
             violation générique hors bornes reste à outiller.
CHK_DIV0   — division par zéro (E-E) : 1..4 OK (NUMERIC_ERROR et PAS
             CONSTRAINT_ERROR — juge de Q7), 5 sentinelle
             NUMERIC_ERROR, $? = 1.
CHK_ANON0  — piège n° 80 : 1..4 OK, 5 OK-dette (violation anonyme
             SILENCIEUSE — si cette section change, dette soldée ou
             régression : mettre à jour témoin et note).
CHK_CSTPRM0/1/2 — fossile n° 81 (scalaires/composites/privés en
             actuel) : toutes lignes OK, $? = 0.
CHK_PREDEF0 — bornes prédéfinies via use-info + BOOLEAN'IMAGE
             (pièges n° 80-rectif et n° 83) :
             INTEGER -2147483648/2147483647, CHARACTER 0/127,
             BOOLEAN 0/1, IMAGE TRUE FALSE, $? = 0.

Sondes RETIRÉES du filet (diagnostic une-fois, archivées) :
CHK_ANON1/2/2B/3, CHK_DUMP0.
```

---

## 4. JOURNAL_SESSIONS.md — entrée à coller

```
## Sessions 9–11 juillet 2026 — Pilier CHECKS RUNTIME : ouvert, CLOS

Méthode intégrale : note d'arbitrage AVANT code (v1 → v1.4), dump
E-0 (piège 71 : 3/3 — bornes fixed rationnelles non scalées,
placeholder DN_ENUMERATION même pour actuel entier), étapes-témoins
E-A..E-F, livraisons ancrées, règle de tri des fossiles appliquée en
vraie grandeur.

Construit : trampolines ce_raise_/ne_raise_, CODE_RANGE_CHECK
(élisions par nœuds), CHECKS_ENABLED (régime permanent ON), checks
gamme (7 sites), LEN composites (dette D3 soldée), index (4
variantes), division par zéro (Q7 : NUMERIC_ERROR, fidélité 83).

Campagne de fossiles (5, tous par témoins à VALEURS) :
n° 80 sous-type anonyme → base (garde d'élision ; dette 80-b
RECTIFIÉE — leçon de ré-audit) ; n° 81+bis+ter actuels constants
fantômes (scalaires, composites, privés — IDENT_* de l'ACVC inertes
depuis l'origine, ressuscités ; else bruyant : deux prises en 24 h) ;
n° 82 oscillation rel8/rel32 BT/BF sous alignements (tous sauts
rel32, le « 4 octets de NOP » historique expliqué) ; n° 83 pile
d'évaluation pré-LINK sur la VARzone (LINK 0 avant _STANDRD ;
BOOLEAN'LAST et 'IMAGE guéris) ; n° 84 adaptateurs INADR/OUTADR
jamais appelés côté lecture (génériques in-out réellement
fonctionnels pour la première fois).

État final : filet complet + ACVC A2–A8 verts checks ON ET OFF,
auto-compilation verte (FINC ; assemblage bootstrap rendu viable par
n° 81). Le pilier a coûté ~15 livraisons et payé cinq fossiles que
rien d'autre ne pouvait voir : « la sécurité Ada n'était pas une
lourdeur, c'était un révélateur ».
```

---

## 5. LLIR_AJOUTS — bloc à coller (conventions nouvelles)

```
## Pilier checks (juillet 2026)

- ce_raise_ / ne_raise_ : trampolines uniques par exécutable (wrapper,
  région inatteignable) — posent l'identité prédéfinie et BRA
  exc_raise_. Sites : BT/BF STANDARD.ce_raise_ (ou ne_raise_).
- Idiome de check scalaire (valeur PRÉSERVÉE au sommet) :
  DUP ; <borne FST> ; CLT ; BT ce_raise_ ; DUP ; <borne LST> ; CGT ;
  BT ce_raise_ — effet de pile net nul, insérable entre évaluation et
  consommation. Bornes par la MÊME séquence que l'usage voisin
  (frame _SUBTYPE.FST/LST, descripteur .FST_n, use-info via GFP).
- Division par zéro : DUP ; LI 0 ; CEQ ; BT ne_raise_ avant DIV/MODI/
  REMI utilisateur.
- BT et BF : rel32 SYSTÉMATIQUE (comme BRA) — piège n° 82. Le retour
  du rel8 appartient à un futur optimiseur MONOTONE.
- Ordre wrapper : LINK 0, loc_siz AVANT include _STANDRD.FINC
  (piège n° 83).
- Règle générale (arbitrage Q2) : LLIR EXPLICITE maximale dans les
  FINC, pas de macro d'abréviation — matériau de l'optimiseur futur.
```

---

## 6. INDEX_DEPOT — lignes à ajouter

```
NOTE_MODELE_CHECKS_v1.md   — note du pilier checks, v1.4 finale
chk_test0/1, chk_len0, chk_idx0, chk_div0, chk_anon0,
chk_cstprm0/1/2, chk_predef0 — témoins permanents du pilier checks
(oracles dans ORACLES_TESTS). Sondes archivées : chk_anon1/2/2b/3,
chk_dump0.
```
