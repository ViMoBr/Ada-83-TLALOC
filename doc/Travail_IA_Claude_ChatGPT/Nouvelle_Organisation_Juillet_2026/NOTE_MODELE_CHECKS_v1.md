# NOTE DE MODÈLE D'EXÉCUTION — CHECKS RUNTIME (LRM 11.1) — v1.1 ARBITRÉE

**9–10 juillet 2026 — pilier OUVERT, arbitrages Q1–Q4 CLOS (mainteneur).**
Aval entièrement fourni par le pilier 11 (NOTE_MODELE_EXCEPTIONS_v3) :
identité des prédéfinies, EXCEPTIONS_CURRENT, `exc_raise_`, sentinelle —
tout est jugé. Ce pilier ne construit que l'AMONT : décider où comparer
quoi, et brancher. Restent ouvertes : Q5–Q7 (§9), à trancher au DUMP de
CHK_DUMP0 (dump fourni par le mainteneur).

## 1. Stratégie : comparer-et-brancher vers UN trampoline par prédéfinie

Un check = une séquence de comparaison LLIR ordinaire + un branchement
conditionnel vers un trampoline unique par exception prédéfinie, posé par le
wrapper FAS à côté d'`exc_raise_` (région inatteignable, prévu dès le pilier
11 : « BRA 5 octets, dimensionné pour les checks »). Le trampoline factorise
le LCA + Sa + BRA (≥ 15 octets) ; chaque site ne paie que ses comparaisons
et ses BT.

```
ce_raise_:                                    ; posé par CREATE_FAS_MAIN_FILE
        LCA   STANDARD.CONSTRAINT_ERROR__exc.data_ptr
        Sa    0, EXCEPTIONS_CURRENT_disp
        BRA   exc_raise_
ne_raise_:                                    ; idem, NUMERIC_ERROR
```

Aucune photographie d'état, aucun contexte : le check ne fait que POSER
l'identité et sauter — le déroulage du pilier 11 fait tout le reste. Un check
qui saute depuis n'importe quelle profondeur d'expression est couvert par
l'invariant de frontière d'instruction (la restauration R13/R14 balaie les
temporaires de l'expression interrompue — même argument que le raise).

## 2. Répartition doctrinale (« codi = machine à pile », inchangée)

- **_standrd.adb** : RIEN à ajouter. Les prédéfinies existent (pilier 11).
- **codi_x86_64.finc** : RIEN. Pas de macro CHK (Q2 close) : le code de
  check reste de la LLIR EXPLICITE dans le FINC — règle générale posée par
  le mainteneur : maximiser le code visible en LLIR en vue d'une éventuelle
  passe d'optimisation future (une macro opacifierait ce qu'un optimiseur
  devrait revoir : checks redondants, bornes déjà comparées).
- **Wrapper (CREATE_FAS_MAIN_FILE)** : gagne `ce_raise_` et `ne_raise_`.
- **Expander** : émet les comparaisons en LLIR ordinaire ; CODI gagne un
  commutateur global `CHECKS_ENABLED` (§7). Tout label de check fabriqué
  par LABEL_STR des deux côtés (piège 76).

## 3. L'idiome canonique (range check, valeur préservée)

Conventions machine confirmées (mainteneur) : les fetch de codi sont des
**movsx signés** ; les empilements aux stores sont **push adresse puis push
data** (pop data, pop address), comme pour les LI. Conséquences :

1. La valeur contrôlée est AU SOMMET à tout site de store, direct ou
   indirect — l'idiome s'insère entre évaluation et consommation SANS
   OVER/SWAP, identique sur toutes les branches d'affectation.
2. Valeur et bornes passant par les MÊMES fetch movsx, la comparaison
   signée CLT/CGT est cohérente par construction : même représentation
   64 bits des deux côtés, quelle que soit la taille de stockage.

```
        DUP                                   ; valeur (au sommet, préservée)
        L<s>  <lvl>, <path>_<SUBTYPE>.FST     ; borne basse du SOUS-TYPE
        CLT                                   ; val < FST ?
        BT    ce_raise_
        DUP
        L<s>  <lvl>, <path>_<SUBTYPE>.LST
        CGT                                   ; val > LST ?
        BT    ce_raise_
```

Points d'appui existants : les bornes de tout sous-type scalaire sont des
données adressables `_<SUBTYPE>.FST/.LST` — statiques ou élaborées
dynamiquement, MÊME chemin de lecture (CODE_SCALAR_SUBTYPE_FIRST_LAST,
expander-expressions ~1675, factorisation à réutiliser telle quelle).

**Résidu consigné (movsx)** : un énuméré de PLUS de 128 positions stocké
sur un octet verrait ses positions ≥ 128 chargées négatives — l'ORDRE est
préservé à l'intérieur de chaque moitié mais pas entre elles. CHARACTER
(128 valeurs, Ada 83) et BOOLEAN sont hors de cause ; à re-vérifier
seulement si un témoin déclare un tel énuméré. Pas un sujet du périmètre 1.

**Règle des bornes : celles du SOUS-TYPE DE LA VUE, jamais du type de base.**
C'est le motif dominant du pilier 3.7 (« la vue contrainte n'est pas le type
de base »), transposé : six correctifs là-bas disent que c'est ICI que les
bugs viendront.

## 4. Taxonomie LRM 11.1 et affectation aux prédéfinies

| Check | Lève | Sites d'émission | Périmètre |
|---|---|---|---|
| Longueur (4.5.1) LEN_G = LEN_D | CONSTRAINT_ERROR | CODE_COMPOSITE_OPERATOR (dette D3-contrôle) | **1** |
| Index (4.1.1) | CONSTRAINT_ERROR | CODE_INDEXED (bornes _FST/_LST du descripteur) | **1** |
| Gamme scalaire (3.5.4, 5.2, 6.4.1, 4.6, 4.7) | CONSTRAINT_ERROR | affectation, init, param **in**, return, conversion, qualification | **1** |
| Division par zéro (4.5.5) | NUMERIC_ERROR | sites DIV/REMI/MODI utilisateur (~3505) — PAS les DIV internes du compilateur (adressage, STORAGE_UNIT) | **1** |
| Null access sur `.all` | CONSTRAINT_ERROR | CODE_ALL (CEQ 0 sur le pointeur) | 2 |
| Gamme flottante / fixed | CONSTRAINT_ERROR | FCLT/FCGT ; fixed = entier scalé, bornes scalées (Q5) | 2 |
| Discriminant (3.7.2) | CONSTRAINT_ERROR | affectation record contraint, conversion | 2 (avec 3.7 bis) |
| Overflow (4.5) | NUMERIC_ERROR | après CHAQUE op arithmétique | **HORS PÉRIMÈTRE** (consigné) |
| STORAGE_ERROR | — | bump allocator sans contrôle (dette connue) | HORS PÉRIMÈTRE |
| Élaboration (3.9) | PROGRAM_ERROR | — | HORS PÉRIMÈTRE |
| pragma SUPPRESS | — | ignoré (le commutateur global §7 en tient lieu) | HORS PÉRIMÈTRE |

## 5. Élision statique (périmètre 1 : minimale et sûre)

Émettre TOUJOURS, sauf :
1. Sous-type cible = type de base (aucune contrainte) — cas massivement
   majoritaire, indispensable pour contenir la taille des FINC ;
2. Valeur statique (SM_VALUE présent) ET bornes du sous-type statiques ET
   valeur prouvée dans les bornes — élision totale ; hors bornes statiquement :
   émettre le raise INCONDITIONNEL (BRA ce_raise_) + avertissement en
   commentaire FINC (sem a pu déjà rejeter, ne pas doubler en refus bruyant).

PAS d'analyse de flux, PAS de propagation d'intervalles : « même sous-type
des deux côtés » n'élide PAS en périmètre 1 (une composante indexée du bon
sous-type a pu être corrompue par un voisin — décision conservatrice ; le
raffinement, s'il vient, appartient à la passe d'optimisation future sur la
LLIR explicite — cohérent avec Q2).

## 6. Ordre de construction (étapes-témoins)

- **E-0** : DUMP de CHK_DUMP0 (fourni par le mainteneur) — tranche Q5/Q6
  et confirme les formes d'arbre aux six sites de gamme scalaire AVANT
  toute émission (piège 71 : les deux fois où la règle a été suivie, le
  dump a contredit l'hypothèse).
- **E-A** : trampolines dans le wrapper + `CHECKS_ENABLED` + témoin
  CHK_TEST0 : une affectation scalaire hors bornes rattrapée par handler,
  une non rattrapée → sentinelle nomme CONSTRAINT_ERROR, $? = 1. Juge le
  chemin check→trampoline→déroulage de bout en bout AVANT multiplication
  des sites.
- **E-B** : LEN_G = LEN_D (solde la dette D3-contrôle). Les deux longueurs
  sont DÉJÀ chargées au site — une comparaison + BT. Retirer la ligne
  d'ETAT_PILIERS et le commentaire RESTRICTION de CODE_DN_BLTN_OPERATOR_ID.
- **E-C** : index check dans CODE_INDEXED (bornes du descripteur sous la
  main). Témoin : indexation dynamique hors bornes, y compris via tranche.
- **E-D** : gamme scalaire, UN site à la fois dans l'ordre : affectation →
  init de déclaration → param in → return → conversion → qualification.
  Témoin par site (CHK_TEST1 auto-jugeant, sections numérotées façon
  exc_test1) ; témoin SIGNÉ obligatoire (valeur négative vers sous-type
  positif — l'analogue du témoin (-5,2,3) du lot D2).
- **E-E** : division par zéro (trampoline ne_raise_, trois opcodes à garder).
- **E-F** : filet complet checks ON — y compris AUTO-COMPILATION (§7).

Méthode inchangée : livraisons en instructions ligne par ligne ; tag git.

## 7. Fossiles réveillés, deuxième vague (extension du piège 74)

Avant ce pilier, toute valeur hors bornes était TOLÉRÉE silencieusement —
y compris dans les bibliothèques ET dans TLALOC lui-même. Règle de tri :
tout `EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR` apparaissant au filet
avec checks ON est une DETTE RENDUE VISIBLE (probablement un vrai bug
latent), pas une régression du pilier. Outil de tri : `CHECKS_ENABLED`
(commutateur global expander) — filet vert OFF / échec ON = fossile
localisé ; le site du check fautif se trouve en instrumentant le FINC.
Prévoir que la passe d'auto-compilation checks ON sera longue à verdir la
première fois — c'est le stress test du pilier, pas un incident.

## 8. Restrictions consignées à l'ouverture

Overflow, STORAGE_ERROR, checks d'élaboration, pragma SUPPRESS : hors
périmètre (§4). Discriminants, null access, flottants/fixed : périmètre 2.
Énuméré > 128 positions sur octet : résidu movsx consigné (§3).
Génériques : le corps partagé émet les checks du FORMEL — bornes de
l'instance via __u (Q6, dump E-0).

## 9. Questions — closes et restantes

**Closes (arbitrage mainteneur, 10 juillet) :**
- Q1 — Trampolines : dans le wrapper FAS, comme exc_raise_. CLOS.
- Q2 — Macro CHK : NON. LLIR explicite maximale dans le FINC, en vue d'une
  passe d'optimisation future. Règle GÉNÉRALE du projet désormais. CLOS.
- Q3 — Normalisation : fetch codi = movsx signés partout → cohérence
  valeur/bornes par construction (résidu > 128 positions consigné §3). CLOS.
- Q4 — Ordre pile aux stores : push adresse puis push data (pop data,
  pop address) — idiome §3 inchangé sur toutes les branches. CLOS.

**Restantes (tranchées au dump E-0) :**
- **Q5 — Fixed point.** Valeurs = entiers scalés : les bornes _FST/_LST
  d'un sous-type fixed sont-elles stockées scalées (comparaison entière
  directe) ou en unités du type (rescale nécessaire) ? CHK_DUMP0 §F.
- **Q6 — Génériques.** Bornes du formel discret en corps partagé : chemin
  __u/_ENUM_USE_INFO (GENERIC_FIRST_LAST, expressions ~1830) réutilisable
  tel quel ? CHK_DUMP0 §G.
- **Q7 — NUMERIC_ERROR vs CONSTRAINT_ERROR.** LRM 83 les distingue (11.1) ;
  l'AI-00387 (adopté ensuite) les confond. ACVC 1.11 accepte les deux pour
  la division. Proposé : distinguer (fidélité 83), coût nul (deuxième
  trampoline). À figer avant E-E.

## 10. Ce que ce pilier NE construit PAS

Aucune nouvelle mécanique d'exception, aucun contexte, aucune macro de
déroulage ni de check, aucune modification de _standrd.adb ni de codi. Si
une étape semble exiger l'un de ces éléments, c'est que le design dévie —
revenir à cette note.
