# NOTE DE MODÈLE D'EXÉCUTION — CHECKS RUNTIME (LRM 11.1) — v1.4 FINALE : PÉRIMÈTRE 1 CLOS

**9–11 juillet 2026 — TOUTES étapes closes et jugées** : E-0 (dump),
E-A (CHK_TEST0 6/6), E-B (CHK_LEN0 5/5), E-C (CHK_IDX0 12/12),
E-D (CHK_TEST1 8/8, six sites), E-E (CHK_DIV0 5/5, Q7 figée :
NUMERIC_ERROR, fidélité 83), E-F (filet + ACVC verts checks ON **et**
OFF — checks ON devient le régime permanent). Toutes questions Q1–Q7
closes. Fossiles de campagne : n° 80 (rectifié), 81+bis+ter, 82, 83,
84 — §7 bis. Restes du périmètre 2 : §8. La
campagne de fossiles de cette phase est consignée en §7 bis.

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

### 3 bis. Confirmations du dump CHK_DUMP0 (E-0, 10 juillet)

**La source des bornes est UNIFORME sur tous les sites** — la CIBLE porte
le spec du SOUS-TYPE, les sources portent le type de base :
- affectation : `D(SM_EXP_TYPE, AS_NAME)` = spec du sous-type (S→SMALL
  P227,L21 ; D→DYN P227,L77 ; C→UPPER P229,L32 ; F→FPOS P239,L61) ;
- composante indexée : SM_EXP_TYPE du DN_INDEXED = SOUS-TYPE de composante
  (ici INTEGER base → élidé) ; le check d'INDEX lit le spec du tableau via
  le préfixe (DN_CONSTRAINED_ARRAY) — deux checks, deux sources, un site ;
- conversion : SM_EXP_TYPE du DN_CONVERSION = sous-type cible ; idem
  DN_QUALIFIED ;
- param in : SM_OBJ_TYPE du formel (P de TWICE → SMALL) ;
- return : l'expression porte le type de BASE (résultat de "+") — le
  sous-type de retour se lit dans le FUNCTION_SPEC (AS_NAME) via SM_SPEC.

Donc UNE seule fonction expander `CHECK_SUBTYPE_OF_SITE` qui rend le spec,
et l'idiome §3 derrière — pas de logique par site au-delà de la lecture.

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
   majoritaire, indispensable pour contenir la taille des FINC. Test
   concret (dump) : `TYPE_SPEC = D(SM_BASE_TYPE, TYPE_SPEC)` — comparaison
   de NŒUDS (SMALL P227,L21 a SM_BASE_TYPE→P27,L112 ≠ lui-même → check ;
   INTEGER P27,L112 est son propre base → élision). Jamais de comparaison
   de bornes pour élider en périmètre 1 ;
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

- **E-0 — FAITE (10 juillet)** : dump de CHK_DUMP0 lu. Q5/Q6 closes,
  source des bornes uniforme confirmée (§3 bis), test d'élision confirmé
  (§5). Le piège 71 a encore frappé : l'hypothèse « fixed = bornes
  scalées » était FAUSSE (rationnels en unités du type), et le placeholder
  DN_ENUMERATION du formel pour un actuel ENTIER n'était pas prévisible.
- **E-A — FAITE (10 juillet, CHK_TEST0 6/6)** : trampolines wrapper,
  `CHECKS_ENABLED`, CODE_RANGE_CHECK, site affectation (INTEGER +
  ENUMERATION). Complétée le 11 par la garde d'élision n° 80.
- **E-B — FAITE (10 juillet, CHK_LEN0 5/5)** : LEN_G = LEN_D, dette
  D3-contrôle SOLDÉE (ETAT_PILIERS mis à jour).
- **E-C — FAITE (10 juillet, CHK_IDX0 12/12)** : index check dans les
  QUATRE variantes de CODE_INDEXED, sans élision (consigné).
- **E-D — FAITE (11 juillet, CHK_TEST1 8/8)** : init de déclaration,
  param in (mode in seul, copy-back consigné), return (sous-type via
  AS_HEADER→AS_NAME→SM_DEFN→SM_TYPE_SPEC), conversion, qualification,
  et corps générique partagé (bornes du formel via GFP/_ENUM_USE_INFO —
  seul site hors CODE_RANGE_CHECK, aucune élision). A exhumé le
  fossile n° 84 (adaptateur INADR/OUTADR jamais appelé côté lecture).
- **E-E — FAITE (11 juillet, CHK_DIV0 5/5)** : /, mod, rem utilisateur
  → NUMERIC_ERROR via ne_raise_ (premier exercice du trampoline).
  Q7 figée : fidélité LRM 83, NUMERIC_ERROR ≠ CONSTRAINT_ERROR.
- **E-F — FAITE (11 juillet)** : filet + ACVC complets verts checks ON
  ET checks OFF ; auto-compilation (production FINC) verte. Checks ON
  = régime permanent.

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

## 7 bis. Campagne de fossiles E-A/E-C (10-11 juillet) — bilan

La règle de tri du §7 a été appliquée en vraie grandeur sur la levée
A54B02A (série A). Chaîne : cinq sondes (chk_anon0..3, 2b), trois faux
suspects écartés dans l'ordre (E-C, REPORT.FINC périmé, pilier 11),
un fait décisif (DYN'LAST = 0). Butin :

- **n° 80 (RECTIFIÉ le 11 juillet)** : sous-type ANONYME →
  XD_SOURCE_NAME remonte au base — la garde d'élision est CORRECTE
  (contrôler une contrainte anonyme contre les bornes du base est
  vide de sens) et la dette (a) — contraintes anonymes non
  contrôlées — TIENT. En revanche la sous-hypothèse (b) « bornes des
  prédéfinis jamais élaborées » était FAUSSE : _STANDRD.FINC les
  élabore bien (stores SHL/NEG/SUB vers FST/LST, exécutés en tête de
  flux). Elle reposait sur l'attribution de la levée au site I —
  réfutée ensuite par le n° 81 (la levée venait du site J via
  IDENT_INT ≡ 0). Leçon de triage : quand une cause plus profonde est
  trouvée, RÉ-AUDITER ce que les hypothèses antérieures expliquaient
  encore — ici, plus rien. L'arbitrage 80-b est ANNULÉ ; clôture
  empirique par CHK_PREDEF0 (lecture des bornes prédéfinies par le
  chemin use-info, celui du site générique d'E-D).
- **n° 81 + bis + ter** : actuels CONSTANTS perdus en silence par
  CODE_PROCEDURE_CALL — trois familles (scalaires non-énumérés,
  composites, types privés dont TREE_VOID). Conséquence historique :
  IDENT_INT ≡ 0 depuis l'origine, toute la série A tournait avec un
  harnais inerte ; les FINC auto-compilés portaient des appels à
  arité tronquée (bootstrap inviable). Else BRUYANT en poste — deux
  prises en 24 h. Témoins : chk_cstprm0/1/2.
- **n° 82** : oscillation rel8/rel32 de BT/BF sous alignements
  (anti-monotonie) — tous les sauts passés en rel32, précédent BRA
  généralisé. Le « 4 octets de NOP » historique est expliqué.

Leçon d'ensemble : les trois fossiles ont été trouvés PAR le pilier
(un check, puis la garde qu'il a justifiée) et étaient structurellement
invisibles à la série A. Le filet post-fossiles tourne avec des
IDENT_* vivants pour la première fois.

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

**Closes au dump E-0 (10 juillet) :**
- Q5 — Fixed : les bornes DIANA sont des RATIONNELS en unités du type
  (FPOS : SM_VALUE +0/+1 et +2/+1 sur son SM_RANGE), PAS scalées. Le spec
  porte CD_IMPL_SMALL (+1/+16 ici — noter : ≠ delta +1/+8). Constante de
  comparaison = borne / IMPL_SMALL (FPOS → 0 et 32), calcul rationnel déjà
  outillé (NUMER/DENOM de CVTIX/CVTXI). Bornes fixed dynamiques : rare,
  suit le périmètre 2 des fixed. CLOS.
- Q6 — Génériques : dans le corps partagé, le formel `(<>)` est un
  PLACEHOLDER DN_ENUMERATION à liste de littéraux VIDE, SANS SM_RANGE,
  CD_COMPILED FALSE — MÊME quand l'actuel est un sous-type d'INTEGER (ne
  jamais brancher entier/énuméré sur le placeholder). Bornes à l'exécution
  par le chemin GENERIC_FIRST_LAST existant (La GFP ; LId __u_ofs,
  STANDARD._ENUM_USE_INFO.FST/.LST — expressions ~1831), réutilisable TEL
  QUEL ; garde = CODI.IN_GENERIC_BODY et IS_GENERIC_FORMAL_TYPE. AUCUNE
  élision en corps partagé (bornes inconnues statiquement). Hors du corps,
  l'instanciation PARTAGE le nœud spec de l'actuel (ELEM→SMALL, même
  P227,L21 — identité partagée, motif des renames) : les sites appelants
  passent par le chemin normal sans rien savoir du générique. CLOS.

**Restante :**
- Q7 — CLOSE (E-E, 11 juillet) : NUMERIC_ERROR distincte, fidélité
  LRM 83, jugée par CHK_DIV0 §2-4 (discrimination explicite des deux
  handlers) et §5 (sentinelle nomme NUMERIC_ERROR).

## 10. Ce que ce pilier NE construit PAS

Aucune nouvelle mécanique d'exception, aucun contexte, aucune macro de
déroulage ni de check, aucune modification de _standrd.adb ni de codi. Si
une étape semble exiger l'un de ces éléments, c'est que le design dévie —
revenir à cette note.
