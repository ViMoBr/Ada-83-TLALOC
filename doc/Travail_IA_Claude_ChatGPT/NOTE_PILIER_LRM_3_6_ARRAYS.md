# Note de pilier — LRM 3.6 « Array Types » (3.6.1, 3.6.2, 3.6.3)

**Date** : 4 juillet 2026
**Référence** : ANSI/MIL-STD-1815A-1983, §3.6 ; opérations référencées : §4.5.1 (logiques),
§4.5.2 (relationnels et égalité), §4.5.3 (caténation), §4.6 (conversions), §4.1.2 (tranches),
§4.3.2 (agrégats de tableaux), annexe A (attributs).
**Périmètre exclu explicitement** : les vérifications CONSTRAINT_ERROR (bornes, glissement,
compatibilité de longueurs) relèvent du pilier « exceptions » ; ici on génère le code du cas
nominal sans contrôle, en notant chaque site de contrôle futur par un commentaire `; CHK:`
dans le FINC émis.

---

## 1. Représentation actuelle (rappel du modèle)

Un objet tableau est un **doublet** `(_disp : @data, __u : @info)`. Le bloc info a deux
formes de layout, cohérentes entre elles pour le cas 1-dim :

- **Type nommé** (namespace `_TYPE`) : `SIZ:d` à 0, puis `virtual at 4` avec, par dimension
  non terminale, `SIZ_n/FST_n/LST_n:d`, et pour la dernière dimension `COMP_SIZ/FST_n/LST_n:d`.
  Pour un type **non contraint**, seul le gabarit d'offsets est émis et `SIZ = -1`.
- **Bloc anonyme inline** (concaténation, agrégats dynamiques, résultat de fonction) :
  `SIZ:d, _COMP_SIZ:d, _FST_1:d, _LST_1:d` — mêmes offsets 0/4/8/12 que le cas nommé 1-dim.
  **Limite** : ce bloc anonyme est câblé 1-dim (voir dette D6).

`SIZ` est en **bits** ; les longueurs de travail (`*_len`) sont en **octets** car elles servent
de compteur BLKMOV. Convention BLKMOV : pile `… @DST, LEN, @SRC`.

## 2. Acquis (vérifié dans le source, sessions ≤ 4 juillet)

| LRM | Élément | Où | Statut |
|---|---|---|---|
| 3.6 | Types contraints, multi-dim, taille statique/dynamique | PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC, COMPILE_ARRAY_TYPE_DIMENSION | validé (ACVC A2/A3) |
| 3.6 | Types non contraints : gabarit d'offsets, SIZ=-1 | CODE_UNCONSTRAINED_ARRAY_DECL | validé |
| 3.6.1 | Contrainte d'index sur objet, sous-type anonyme (y compris nœud partagé) | COMPILE_ARRAY_VAR + correctif A21001A | validé 4 juil. |
| 3.6.1 | Index par marque de sous-type (sans range explicite) | HAS_RANGES=FALSE | présent, peu exercé |
| 4.1.1 | Indexation, y compris multi-index | CODE_INDEXED (boucle sur DN_ARRAY) | validé 1-dim ; 2-dim à confirmer par test |
| 4.1.2 | Tranches : lecture, affectation (agrégat, tranche, expression), paramètre effectif | CODE_SLICE, CODE_ASSIGN, instr. 760/1666 | validé partiellement |
| 4.3.2 | Agrégats : positionnels, nommés (range, others), bornes dynamiques | CODE_ARRAY_AGGREGATE (+_DYNAMIC), DIM_TBL 8 dims | validé 1-dim ; multi-dim imbriqué à confirmer |
| A | 'FIRST/'LAST/'LENGTH, formes dimensionnées (N) | CODE_ATTRIBUTE (DIM_EXP) | présent |
| A | 'RANGE (boucles for, préfixes objet/type/composant) | CODE_RANGE_ATTRIBUTE_BOUND | récent ; chemins « non traité » résiduels tracés |
| 4.5.3 | Caténation array & array (opérandes : littéral chaîne, tranche, agrégat, expression) | CODE & concat, doublets temporaires co-pile | validé (A21001A) |
| 6.4 | Retour de fonction tableau : côté appelant (doublet anonyme) et côté appelé (BLKMOV via result__ofs) | PREPARE_ARRAY_RETURN, CODE_RETURN | validé pour 'IMAGE ; général à confirmer |
| 3.6.3 | STRING : littéraux, affectation, PUT/GET | CODE_STRING_LITERAL, TEXT_IO | validé |

## 3. Dette du pilier (à produire)

- **D1 — Égalité `=` / `/=` de tableaux** (3.6.2 → 4.5.2). Le dispatch de
  CODE_DN_BLTN_OPERATOR_ID émet CEQ/CNE scalaires quels que soient les opérandes : sur deux
  composites, on compare les **adresses des doublets**. Requis : test préalable d'égalité des
  longueurs (en octets), puis comparaison mémoire. Vaut pour tout composite mais implémenté
  ici pour les tableaux ; devra être réutilisable par les records.
- **D2 — Ordre lexicographique `<, <=, >, >=`** pour tableaux 1-dim à composants **discrets**
  (4.5.2). Boucle de comparaison composant par composant, taille composant paramétrée
  (1/2/4/8 octets), règle du préfixe (le plus court gagne s'il est préfixe).
- **D3 — Opérateurs logiques sur tableaux booléens** `and/or/xor` binaires et `not` unaire
  (4.5.1, 4.5.6) : aucune trace dans le source.
- **D4 — Formes composant de la caténation** (4.5.3) : `composant & tableau`,
  `tableau & composant`, `composant & composant`. Le code actuel suppose deux opérandes
  tableaux.
- **D5 — Conversion entre types tableaux** (3.6.2 → 4.6) : CODE_CONVERSION ne traite que les
  scalaires/fixed. Cas nominal : mêmes types d'index et de composant convertibles → BLKMOV
  + bloc info du type cible (glissement de bornes inclus).
- **D6 — Bloc info anonyme multi-dim** : concat, agrégat dynamique et résultat de fonction
  câblés `_FST_1/_LST_1`. Généraliser le layout anonyme au gabarit par dimension (même ordre
  que le `virtual` des types nommés) — ou décider explicitement que les temporaires anonymes
  restent 1-dim et documenter la restriction.
- **D7 — Longueur dynamique jamais bornée à 0** : partout où `LST−FST+1` est émis
  (concat, tranches, agrégats dynamiques), un intervalle nul (LST<FST) donne un compteur
  **négatif** transmis à BLKMOV/CO_VAR. Requis : un émetteur unique `EMIT_LEN_CLAMPED`
  (max(0, LST−FST+1)) utilisé par tous les sites. Tableaux nuls et tranches nulles sont
  légaux et fréquents (3.6.1).
- **D8 — Retour de tranche depuis une fonction** (cas `NAME` de TEXT_IO, consigné de longue
  date) : `return S(A..B);` — le côté appelé doit construire le doublet résultat depuis
  `@data_slice, len`.
- **D9 — À confirmer par test (peut se révéler acquis)** : indexation et agrégats 2-dim
  imbriqués `((..),(..))`, choix multiples `1|3 =>`, `others` complété après composantes
  nommées, tranche indexée d'un composant sélectionné, glissement d'agrégat
  `V : T(5..7) := (1,2,3)`.

## 4. Décisions de modèle d'exécution à prendre (avant d'écrire)

1. **Comparaison mémoire** : nouvelle macro LLIR `BLKCMP` (convention pile
   `… @A, LEN, @B` → empile 0/1 d'égalité, symétrique de BLKMOV, `repe cmpsb` + `sete`)
   pour D1 ; pour D2, soit une macro `BLKLEX size` paramétrée par la taille composant
   (retourne −1/0/+1), soit une routine runtime unique émise une fois par programme —
   à trancher au vu du coût fasmg. Préférence a priori : macros, cohérent avec l'existant.
2. **Opérateurs booléens de tableaux** : `BLKAND/BLKOR/BLKXOR/BLKNOT` octet à octet
   (les booléens sont stockés 1 octet, piège n° 10) vers un temporaire co-pile, mêmes
   conventions de doublet que la concat.
3. **Égalité de longueurs avant BLKCMP** : en l'absence du pilier exceptions, `=` de
   longueurs différentes rend FALSE (sémantiquement correct : 4.5.2), ce n'est PAS un cas
   d'erreur — contrairement à l'affectation, où la vérification de longueur est un `; CHK:`
   différé.
4. **Conversion tableau** : pas de contrôle en v1 (`; CHK:`), BLKMOV + info cible ; le
   glissement est gratuit puisque l'info cible porte ses propres bornes.
5. **Point d'architecture** : sortir la branche « opérandes composites » de
   CODE_DN_BLTN_OPERATOR_ID dans une procédure dédiée (CODE_COMPOSITE_OPERATOR),
   dispatchée sur `SM_EXP_TYPE(PRM_1) ∈ {DN_ARRAY, DN_CONSTRAINED_ARRAY}` — le test du type
   du **premier opérande** (pas du résultat, qui est BOOLEAN pour les relationnels) est déjà
   la règle du code flottant existant.

## 5. Ordre d'implémentation proposé

1. D7 (EMIT_LEN_CLAMPED) — correctif de sûreté transversal, petit, testable seul.
2. D1 (= et /=) avec BLKCMP — débloque le plus de tests (STRING partout).
3. D2 (lexicographique).
4. D3 (booléens de tableaux).
5. D4 (formes composant de &).
6. D5 (conversions).
7. D8 (retour de tranche) — puis réactiver NAME dans TEXT_IO.
8. D6 selon verdict des tests multi-dim (D9).

Filet à chaque étape : ARRAY_TEST1 (acquis, ne doit jamais régresser), puis séries ACVC
complètes, puis ARRAY_TEST2 (objectif du pilier, sections activées au fil des étapes).
