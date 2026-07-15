# NOTE — Audit des fabrications de déplacements `<type>.<champ>` vs records représentés

Session du 12 juillet 2026. Campagne fasmg ADA_COMP.

## Contexte

Les records à clause de représentation (LRM 13.4) n'ont **pas de symboles
d'offset de composants** dans leur namespace FINC (cas `_TREE` : seuls
`use__info`, `SIZ`, `size` existent ; les composants sont des champs de
bits servis par le protocole `CODE_LOAD_REP_COMPONENT` /
`CODE_STORE_REP_COMPONENT` de represented_items).

Tout émetteur qui fabrique un déplacement `TYPE_STR & "." & <champ>` est
donc un consommateur potentiellement fautif. Signature textuelle commune,
qui sert d'inventaire exhaustif :

    grep -n '& "\."' expander-declarations.adb expander-expressions.adb expander-instructions.adb

17 occurrences au 12/07/2026. Trois catégories :

- **[P] À patcher** — atteint des composants d'un record potentiellement
  représenté, aucune garde en amont.
- **[C] Couvert** — composants de record, mais derrière une garde
  `HAS_RECORD_REP` / `HAS_COMPONENT_REP` qui court-circuite avant.
- **[I] Immunisé** — le champ fabriqué est un champ d'*info de type*
  (`FST`, `LST`, `_FST_n`, `_LST_n`, `SIZ`, `size`, `use__info`) ou un
  symbole local au générateur : ces symboles existent aussi pour les
  records représentés (ou ne concernent pas les records). Rien à faire.

Mode de défaillance garanti bruyant : le namespace d'un record représenté
ne contenant AUCUN symbole de composant, tout site [P] oublié échoue à
l'assemblage fasmg (symbole indéfini), jamais silencieusement à
l'exécution — conforme au n° 96.

## Inventaire

| # | Fichier : ligne | Contexte (ancre) | Champ fabriqué | Cat. | Traitement |
|---|---|---|---|---|---|
| 1 | declarations : 1082 | COMPILE_RECORD_VAR, élaboration des **discriminants à défaut** (LRM 3.7.1) — `LIVA <lvl>, <vc>_disp, TYPE.DISCR` + CODE_EXP + `S<c>` | composant (discriminant) | **P** | Gabarit A (fait le 12/07) |
| 2 | declarations : 1131 | COMPILE_RECORD_VAR, **défauts de composants**, branche composant **composite** (`LIVa` + CODE_AGGREGATE) | composant | **P** | Gabarit B |
| 3 | declarations : 1140 | idem, branche composant **scalaire** (`LIVa` + CODE_EXP + `S<c>`) | composant | **P** | Gabarit A (avec COMP_ID) |
| 4 | expressions : 1920 | CODE_SCALAR_SUBTYPE_FIRST_LAST — bornes d'un sous-type scalaire | `.FST` / `.LST` (info de type) | I | — |
| 5 | expressions : 2099 | Bornes d'un type FLOAT | `.FST` / `.LST` | I | — |
| 6 | expressions : 3249 | PATH_FIELD du générateur d'**égalité de records** | composants | **C** | Court-circuité par la branche rep insérée en tête du générateur (12/07 : mot-comparaison `Ld`/`Ld`/`CEQ` si représentation pleine ≤ 32 bits, refus bruyant sinon). Vérifier que la branche rep précède TOUT usage de PATH_FIELD. |
| 7 | expressions : 4380 | VAR_NAME d'agrégat tableau — `ANON_aga.PREFIX_n` | symboles locaux au générateur | I | Déclaration et consommation co-localisées (même règle que les ANON du n° 100). |
| 8 | expressions : 4915 | CANONICAL_RECORD_AGGREGATE (4890-5095), store d'un composant | composants | **C** | Sous la garde 4875 (`HAS_RECORD_REP` → `CODE_REPRESENTED_RECORD_AGGREGATE` + `return`). |
| 9 | expressions : 5123 | STORE_RECORD_FIELD (5107-5142), chemin d'agrégat de repli, appelé en 5169 | composants | **C** | Même branche `DN_RECORD` de CODE_AGGREGATE, donc sous la même garde 4875. **À confirmer d'un coup d'œil** : un seul `return` en tête de branche couvre bien jusqu'ici. |
| 10 | expressions : 5224 | Marcheur d'agrégat par COMP_DECL_S, branche composant composite | composants | **C** | Idem 9 (même confirmation). |
| 11 | expressions : 5245 | idem, branche composant record (BLKMOV) | composants | **C** | Idem 9. |
| 12 | expressions : 5262 | idem, branche composant scalaire | composants | **C** | Idem 9. |
| 13 | expressions : 6387 | Attribut FIRST/LAST de tableau via `__u` | `._FST_n` / `._LST_n` | I | Info de type tableau — un tableau n'est jamais un record représenté. |
| 14 | expressions : 6458 | RANGE_ATTRIBUTE, préfixe paramètre | `.` + borne tableau | I | — |
| 15 | expressions : 6463 | RANGE_ATTRIBUTE, préfixe variable (`LId ... __u`) | idem | I | — |
| 16 | expressions : 6512 | Bornes tableau (piège n° 58 dans le contexte) | `._FST_` / `._LST_` | I | — |
| 17 | expressions : 6637 | LOAD_BOUND des checks de sous-type scalaire | `.FST` / `.LST` | I | — |

Bilan : 3 [P] (tous dans COMPILE_RECORD_VAR), 6 [C], 8 [I].
Aucun hit dans instructions.adb : le chemin d'affectation à composant
sélectionné y est gardé en 1519 (`SEE_IF_REPRESENTED_DESTINATION`).

## Gabarits de traitement

### Gabarit A — store scalaire (sites 1 et 3)

Contrat de `CODE_STORE_REP_COMPONENT( COMP_ID, VALUE_EXP )` : l'adresse
data du record est sur la pile à l'appel ; la procédure fait le
lire-modifier-écrire du champ de bits et accepte `DN_COMPONENT_ID` et
`DN_DISCRIMINANT_ID`.

    if  <EXP> /= TREE_VOID  and then  <EXP> /= TREE_NIL  then
      if  REPRESENTED_ITEMS.HAS_COMPONENT_REP( <ID> )  then
        PUT_LINE( tab & "La  " & LVL_STR & ", " & VC_STR & "_disp" );   -- @data du record
        REPRESENTED_ITEMS.CODE_STORE_REP_COMPONENT( <ID>, <EXP> );
      else
        -- émission LIVA / CODE_EXP / S<c> existante, inchangée
      end if;
    end if;

`<ID>` = DISCR_ID (site 1) ou COMP_ID (site 3), `<EXP>` = DSCRMT_EXP ou
FIELD_INIT.

### Gabarit B — composant composite d'un record représenté (site 2)

Un composant **composite** initialisé par agrégat dans un record
représenté sort du périmètre de `CODE_STORE_REP_COMPONENT` (champs
scalaires, mot unique). Refus bruyant en attendant un client réel :

    if  REPRESENTED_ITEMS.HAS_COMPONENT_REP( COMP_ID )  then
      PUT_LINE( "; COMPILE_RECORD_VAR : composant composite d'un record represente non gere" );
      raise PROGRAM_ERROR;
    end if;
    -- puis émission existante

### Rappel — protocole des consommateurs déjà gardés

Lecture : expressions 1091 (`IS_SOURCE and HAS_COMPONENT_REP` →
`CODE_LOAD_REP_COMPONENT`, séquence Ld / LI first / LI width / UBFX).
Écriture : instructions 1519. Agrégats : expressions 4875. Égalité :
branche rep en tête du générateur (~3256). La normalisation **vue
pleine** (`CODI.FULL_VIEW`) dans `FIND_COMP_REP_ELEM_FROM_COMPONENT`
est indispensable : TREE est un type privé (n° 60).

## Règle d'audit permanente

Après traitement des 3 [P] : toute NOUVELLE concaténation `& "."` vers
un nom de composant de record dans l'expander doit soit être gardée par
`HAS_COMPONENT_REP`, soit prouver que son type ne peut pas être
représenté (info de type, tableaux, symboles locaux). Le grep de
signature redevient alors un outil de contrôle : un hit non classé dans
cette note est un bug en attente. Candidate PIEGES n° 100-bis.

## Vérifications de clôture

1. Coup d'œil : la branche `DN_RECORD` de CODE_AGGREGATE n'a qu'UNE
   entrée et la garde 4875 la coiffe entièrement (couvre les sites
   9-12).
2. Coup d'œil : dans le générateur d'égalité, la branche rep précède
   toute émission via PATH_FIELD (site 6).
3. Test dirigé : `T : TREE;` (discriminant PT à défaut) doit produire
   `La <lvl>, T_disp` + séquence RMW de represented_items, plus aucun
   `_TREE.<comp>`.
4. fasmg sur ADA_COMP : l'auditeur exhaustif — tout site [P] oublié se
   nommera lui-même.
