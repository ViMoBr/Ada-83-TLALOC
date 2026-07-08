# Triage de couverture DIANA / EXPANDER

**Date** : 4 juillet 2026 — mis à jour le 7 juillet 2026 (clôture pilier 11)
**Statut** : instrument d'audit — première passe, à valider et maintenir
**Méthode** : extraction des 230 nœuds de `diana_NODES.txt`, recherche de `DN_<NOM>` dans les
8 fichiers `expander*.adb`. Le dispatch de l'expander se fait surtout par chaînes
`if NODE.TY = DN_X`, donc le critère retenu est **la mention** (le nœud est connu du code),
pas la présence dans un `when`.

**Résultat brut** : 142 nœuds mentionnés, 88 jamais mentionnés.

**Avertissement de principe** (à ne pas oublier) : DIANA est plus général que la
sous-représentation exécutable. Ce document n'est PAS un plan de développement
« un nœud = une tâche ». C'est un inventaire filtré qui répond à une seule question :
*parmi les nœuds inconnus de l'expander, lesquels portent une sémantique d'exécution ?*
Le plan de développement, lui, est piloté par le LRM (voir SESSION_EXPANDER_SYNTHESE §4,
Point de méthode du 4 juillet).

**Second avertissement** : « mentionné » ne veut pas dire « traité correctement ».
DN_PRIVATE compte 58 mentions et reste différé ; DN_ACCESS est dispatché mais
CODE_ACCESS_DECL est incomplet. La dette des piliers *entamés* se lit dans la table
« fondations » de la synthèse, pas ici.

---

## Catégorie A — Infrastructure de l'arbre : rien à compiler (18 nœuds)

Nœuds lexicaux, de racine ou de plomberie. Aucune sémantique d'exécution.

`root, user_root, txtrep, num_val*, symbol_rep, hash, sourceline, error, list,
nil, void*, true, false, lib_info, def, source_name_s, compltn_unit_s, trans_with`

(* mentionnés par ailleurs comme valeurs d'attributs, jamais comme nœuds à générer — normal)

## Catégorie B — Listes et séquences : traversées génériquement (≈ 20 nœuds)

Tous les `*_S` : `alternative_s, choice_s, comp_rep_s, context_elem_s, decl_s,
discrete_range_s, dscrmt_decl_s, exp_s, general_assoc_s, index_s, item_s, name_s,
param_s, pragma_s, scalar_s, stm_s, test_clause_elem_s, use_pragma_s, variant_s,
argument_id_s`.

La traversée de liste est générique (SM_FIRST/suivant) ; ces nœuds n'ont pas à
apparaître nommément. **Exception** : `dscrmt_decl_s` et `variant_s` réapparaissent
en catégorie E comme composants du pilier « records à discriminants ».

## Catégorie C — Nœuds syntaxiques `*_DEF` et contraintes : sémantique portée par le TYPE_SPEC (≈ 16 nœuds)

L'expander travaille sur `SM_OBJ_TYPE` / `SM_TYPE_SPEC` (DN_INTEGER, DN_FLOAT,
DN_ENUMERATION, DN_RECORD, DN_CONSTRAINED_ARRAY…), pas sur la forme syntaxique de la
déclaration. Ces nœuds sont donc légitimement absents :

`integer_def, float_def, enumeration_def, record_def, private_def, l_private_def,
formal_float_def, formal_fixed_def, float_constraint, constrained_array_def (mention
indirecte), constant_decl, variable_decl` (le dispatch se fait sur les *_ID :
DN_CONSTANT_ID, DN_VARIABLE_ID), `access_def, fixed_def, fixed_constraint,
dscrmt_constraint` — **attention** : les quatre derniers sont légitimement absents
*en tant que formes syntaxiques*, mais leurs TYPE_SPEC correspondants appartiennent
à des piliers non faits (access complet, fixed, discriminants) — voir E.

## Catégorie D — Artefacts de résolution sémantique du front-end (≈ 10 nœuds)

Types universels et classes de surcharge, consommés par l'analyse sémantique :

`any_access, any_access_of, any_composite, any_integer, any_real, any_string,
universal_fixed` (universal_integer / universal_real sont mentionnés, pour les
littéraux — cohérent).

`implicit_not_eq, in_op, nullary_call, implicit_conv` : **à vérifier** — ces quatre
peuvent apparaître dans des EXP réelles produites par le front-end (conversion
implicite, /= dérivé de =, appel de fonction sans paramètre). S'ils apparaissent
dans les dumps `____TREE.TXT` de programmes réels, ils passent en catégorie E.
→ action de vérification peu coûteuse : grep sur les dumps existants.

## Catégorie E — Dette réelle : sémantique d'exécution, aucun traitement (≈ 24 nœuds)

C'est la liste qui compte. Regroupée par pilier LRM :

| Pilier (LRM) | Nœuds jamais mentionnés | Nœuds entamés associés |
|---|---|---|
| 3.7.1–3.7.3 Records à discriminants et variantes | `dscrmt_decl, dscrmt_decl_s, dscrmt_constraint, variant_part, variant_s, comp_list` | DN_DISCRIMINANT_ID (dispatché), DN_VARIANT (3 mentions), DN_CONSTRAINED_RECORD |
| 3.6 Unconstrained arrays (reliquat — formes CONTRAINTES closes le 5 juillet 2026 : DN_SLICE et retour de slice traités, opérateurs composites complets) | `unconstrained_array_def` | DN_ARRAY (dispatché mais incomplet : déclaration du type non contraint lui-même, CODE_UNCONSTRAINED_ARRAY_DECL, STRING général) |
| 3.4 Dérivation | `derived_def, derived_subprog` | — |
| 3.5.9 Points fixes | `fixed_def, fixed_constraint` | DN_FIXED (dispatché, squelette) |
| 3.8 / 4.8 Access et allocateurs | `access_def` | DN_ACCESS (dispatché), DN_*_ALLOCATOR, DN_NULL_ACCESS (mentions isolées) |
| 8.5 Renames | `renames_unit` | DN_RENAMES_OBJ_DECL, DN_RENAMES_EXC_DECL (1 mention chacun) |
| 5.9 / 5.1 Labels et goto | `label_id, block_loop_id, block_body` | DN_GOTO, DN_LABELED (goto « fonctionne » — vérifier par où passent les labels) |
| 9 Tâches | `entry, task_spec, task_body_id, block_master` | DN_TASK_BODY, DN_ACCEPT, DN_DELAY, DN_ABORT, DN_ENTRY_CALL, DN_SELECTIVE_WAIT… (mentions isolées) |
| 13 Clauses de représentation | `alignment, comp_rep_pragma, variant_pragma` | DN_COMP_REP, DN_RECORD_REP, DN_LENGTH_ENUM_REP (mentions) |
| 12.1.3 Défauts de formels génériques | `box_default, name_default, no_default` | — |
| 2.8 / 10.1 Pragmas et contexte | `pragma_id, context_pragma, use_pragma_s` | DN_PRAGMA (1 mention) |
| Divers à trier | `attribute_id, argument_id, compilation, compilation_unit` | CODE_COMPILATION_UNIT existe : vérifier le chemin d'entrée réel |

## Sortis de la catégorie E

Pilier 11 CLOS (7 juillet 2026) — sortent de la dette : DN_RAISE (nommé, qualifié, nu), DN_EXCEPTION_DECL, DN_EXCEPTION_ID, DN_RENAMES_EXC_DECL (alias, aucune émission d’identité), DN_ALTERNATIVE_S / DN_ALTERNATIVE, DN_CHOICE_EXP / DN_CHOICE_OTHERS (contexte exceptions ; DN_CHOICE_RANGE y reste ANOMALIE — illégal en Ada 83 de toute façon). Attributs désormais exploités : SM_RENAMES_EXC (forme réelle : EXCEPTION_ID direct, piège 71), XD_WITH_LIST / TW_COMP_UNIT / XD_PARENT (DN_TRANS_WITH, includes des corps). DN_ALTERNATIVE_PRAGMA : ANOMALIE bruyante conservée.



## Utilisation prévue de ce document

1. **À l'ouverture d'un pilier** : relever la ligne correspondante, vérifier sur un
   dump `____TREE.TXT` d'un programme-témoin quels nœuds apparaissent réellement,
   et lesquels de leurs attributs SM_/CD_ le front-end renseigne.
2. **À la clôture d'un pilier** : déplacer les nœuds traités hors de la catégorie E,
   dater.
3. **Ne jamais** transformer ce tableau en liste de tâches nœud par nœud : l'unité
   de travail reste le pilier LRM, avec sa note de modèle d'exécution préalable.
