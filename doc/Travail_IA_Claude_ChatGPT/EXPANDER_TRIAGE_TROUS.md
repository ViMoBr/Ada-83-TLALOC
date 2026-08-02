# EXPANDER — TRIAGE DES TROUS SILENCIEUX (inventaire du 28/07/2026)

Inventaire exhaustif sur les sources en contexte, selon la méthode du
briefing « expander bruyant ». Chaque site reçoit un verdict :
**TROU()** (à rendre bruyant), **INTENTIONNEL** (à annoter),
**DEFAUT DOCUMENTE** (à commenter/croiser), **FAIT** (lève déjà),
**MORT** (code jamais appelé, à supprimer).

---

## 0. ECARTS AVEC LE BRIEFING (sources plus récentes)

Le briefing du 27/07 est partiellement périmé — en mieux :

| Site cité par le briefing | Etat réel constaté |
|---|---|
| expressions:361 CODE_USED_OBJECT_ID `when others` « imprime sans lever » | **lève PROGRAM_ERROR** (l.362) — FAIT |
| CODE_TYPE_MEMBERSHIP corps `null;` (fossile n° 115) | **implémenté**, avec garde bruyante « MARQUE NON SCALAIRE » + raise (l.6416-6418) — FAIT |
| represented_items : « SIZE_BITS := 0 ment » et sites « non gere » | tous les PUT_LINE « non gere » du fichier **lèvent PROGRAM_ERROR** — FAIT (reste le fallback de REPRESENTED_RECORD_SIZE_BITS, cf. §5) |
| « ~63 demi-bruyants » | **~56 sites lèvent déjà** ; il reste **~30 vrais demi-bruyants** (liste §4) |

Le comptage `null;` a aussi bougé : declarations 15, expressions 16,
instructions 15, expander.adb 9, structures 1, types_decls 1 (~57 au total).

---

## 1. DECOUVERTE MAJEURE : L'ARBRE DE DISPATCH EST INTEGRALEMENT MUET

Le briefing signalait la catégorie B (« elsif sans else ») comme un cas à
auditer manuellement. Le constat est pire : **c'est le motif de conception
de TOUT l'arbre de dispatch**. Chaque étage est un `if TY in CLASSE_X /
elsif TY in CLASSE_Y / end if` **sans else final**. Un nœud hors des
classes attendues traverse toute la cascade et disparaît sans un mot.

### 1a. Arbre de CODE_EXP (contexte EXPRESSION — contrat +1 en pile — PRIORITE ABSOLUE)

Un nœud avalé ici = zéro valeur empilée = déséquilibre de pile à
retardement = n° 115 exactement. **13 dispatchers muets** :

| Dispatcher | Lignes (expressions.adb) | Verdict |
|---|---|---|
| CODE_EXP | 21-31 | TROU() en else |
| CODE_NAME | 125-133 | TROU() en else |
| CODE_DESIGNATOR | 72-80 | TROU() en else |
| CODE_USED_NAME | 43-54 | TROU() en else |
| CODE_USED_OBJECT | 57-68 | TROU() en else |
| CODE_NAME_EXP | 105-122 | TROU() en else |
| CODE_NAME_VAL | 88-101 | TROU() en else |
| CODE_EXP_EXP | 225-240 | TROU() en else |
| CODE_EXP_VAL | 194-209 | TROU() en else |
| CODE_EXP_VAL_EXP | 179-190 | TROU() en else |
| CODE_QUAL_CONV | 151-160 | TROU() en else |
| CODE_MEMBERSHIP | 164-176 | TROU() en else |
| CODE_AGG_EXP | 212-222 | TROU() en else |

Note : la cascade étant par CLASS_*, chaque else n'attrape que « nœud de
la classe parente mais d'aucune sous-classe » — c'est précisément le cas
qui aujourd'hui ne laisse AUCUNE trace.

### 1b. Arbre de CODE_INSTRUCTION (contrat : effet net nul)

| Dispatcher | Lignes (instructions.adb) | Verdict |
|---|---|---|
| CODE_STM_ELEM | 33-45 | TROU() en else |
| CODE_STM (10 branches !) | 57-104 | TROU() en else |
| CODE_STM_WITH_NAME | 528-545 | TROU() en else |
| CODE_STM_WITH_EXP | 1021-1045 | TROU() en else |
| CODE_STM_WITH_EXP_NAME | 1438-1454 | TROU() en else |
| CODE_CALL_STM | 634-651 | TROU() en else |
| CODE_CASE, boucles d'alternatives (3×) | 1270-1281, 1352-1362, 1389-1399 | if DN_ALTERNATIVE / elsif DN_ALTERNATIVE_PRAGMA (null légitime, annoter) / **else TROU()** |

### 1c. Arbre des déclarations et structures

| Dispatcher | Lignes | Verdict |
|---|---|---|
| CODE_DECL | declarations 36-46 | TROU() en else |
| CODE_ID_DECL | declarations 79-91 | TROU() en else |
| CODE_ID_S_DECL | declarations 96-104 | TROU() en else |
| CODE_HEADER | declarations 110-124 | TROU() en else |
| CODE_REP | declarations 1427-1438 | TROU() en else |
| CODE_UNIT_DECL | declarations 1487-1499 | TROU() en else |
| CODE_SUBP_ENTRY_HEADER | declarations 234-244 | deux branches `null;` (élaboration vide : INTENTIONNEL ? à confirmer) + TROU() en else |
| CODE_NAMED_REP | declarations 1441-1453 | branches = appels COMMENTES (CODE_ADDRESS, CODE_LENGTH_ENUM_REP) : **TROU rep-clauses** + TROU() en else |
| CODE_ITEM_S | structures 571-590 | TROU() en else |

Modèle à imiter partout : structures:60 (`when others => raise
PROGRAM_ERROR` dans CODE_COMPILATION_UNIT) — à enrichir du message TROU().

---

## 2. CORPS `null;` COMPLETS (catégorie A)

### expander-instructions.adb
| Ligne | Procédure | Verdict |
|---|---|---|
| 48 | CODE_STM_PRAGMA | INTENTIONNEL partiel — trier les pragmas qui comptent, annoter |
| 180 | CODE_NULL_STM | INTENTIONNEL (le null Ada) — annoter |
| 188 | CODE_ACCEPT | TROU (tasking) |
| 196 | CODE_TERMINATE | TROU (tasking) |
| 204 | CODE_ABORT | TROU (tasking) |
| 245 | CODE_SELECT_ALTERNATIVE | TROU (tasking) |
| 297 | CODE_SELECTIVE_WAIT | TROU (tasking) |
| 512 | CODE_COND_ENTRY | TROU (tasking) |
| 520 | CODE_TIMED_ENTRY | TROU (tasking) |
| 625 | CODE_ENTRY_CALL | TROU (tasking) |
| **1219** | **CODE_DELAY** | **TROU (absent du briefing !)** — un `delay` avalé en silence |

### expander.adb
| Ligne | Procédure | Verdict |
|---|---|---|
| 422 | CODE_CONTEXT_PRAGMA | INTENTIONNEL probable (pragmas de contexte) — annoter/trier |
| 429 | CODE_BLOCK_MASTER | TROU (tasking/masters) |
| 436 | CODE_DERIVED_SUBPROG | TROU — sous-programmes dérivés : sémantique réelle |
| 443 | CODE_IMPLICIT_NOT_EQ | à vérifier : "/=" dérivé de "=" peut être résolu ailleurs — sinon TROU |
| 493-501 | CODE_ADRESSE : 3 branches `null;--GEN_PUSH_DATA...` (VARIABLE_ID, IN_ID, IN_OUT/OUT) | **TROU — code commenté, aucune adresse empilée** (le `when others` lève, mais les branches « reconnues » ne font rien !) |
| 521 | CODE_SELECT_ALT_PRAGMA | INTENTIONNEL probable — annoter |
| 535 | DBGSTOP | INTENTIONNEL (point d'arrêt débogueur) — annoter |

### expander-declarations.adb
| Ligne | Procédure | Verdict |
|---|---|---|
| 72 | CODE_NULL_COMP_DECL | INTENTIONNEL (composant null) — annoter |
| 343 | CODE_NUMBER_DECL | INTENTIONNEL probable : DN_NUMBER_ID est plié à l'usage via SM_INIT_EXP (expressions:355) — annoter avec cette raison |
| 352 | CODE_DEFERRED_CONSTANT_DECL (`null; --PUT_LINE A FAIRE` !) | TROU — le message a été *commenté*, régression de bruit |
| 435 | `if ...DN_FIXED then null;` (branche then vide) | scorie ? MORT ou TROU — élucider |
| 1309 | CODE_TASK_DECL | TROU (tasking) |
| 1398 | renames d'exception | INTENTIONNEL — déjà annoté PILIER 11, modèle à suivre |
| 1466 | CODE_RECORD_REP : `null; -- CODE_ALIGNMENT_CLAUSE...` | TROU rep-clauses (croiser n° 117) |
| 2265 | `else null; -- A VOIR` (résultats de fonction) | TROU — « A VOIR » = verdict interdit par la définition de fini |
| 2409-2412 | CODE_USE_PRAGMA : deux branches null (use, pragma) | INTENTIONNEL probable — annoter |

### expander-expressions.adb et structures
| Ligne | Site | Verdict |
|---|---|---|
| **2532** | **CODE_POS corps null** | **MORT probable (absent du briefing)** : le dispatch 'P' route POS directement vers CODE_EXP (l.2841) et CODE_POS n'est appelé nulle part — supprimer ou TROU |
| **244-250** | **CODE_USED_OP : émet seulement `"; used op X"`** | **TROU en contexte EXPRESSION (absent du briefing)** — un opérateur utilisé comme nom n'empile rien |
| 1227 | « adresse déjà en pile » | INTENTIONNEL — commentaire déjà bon, ajouter le tag |
| 1650 | `when others => null` (normalisation SM_BASE_TYPE) | INTENTIONNEL probable (TYPE_SPEC inchangé) — annoter |
| structures 710 | CODE_TASK_BODY | TROU (tasking) |
| types_decls 539 | borne dynamique | INTENTIONNEL — déjà commenté, tagger |

---

## 3. CODE_ATTRIBUTE (expressions 2760-2905) — contexte EXPRESSION, priorité 1

Conforme au briefing, plus les chaînes internes muettes :

| Attribut | Verdict |
|---|---|
| 'BASE (2767) | INTENTIONNEL (identité) — annoter |
| CALLABLE (2770), COUNT (2772), TERMINATED (2891) | TROU (tasking) |
| LAST_BIT (2824), POSITION (2848), STORAGE (2878) | TROU (rep-clauses) |
| RANGE (2858) | à trancher : DN_RANGE_ATTRIBUTE est géré par CODE_RANGE_ATTRIBUTE_BOUND (l.6526) dans les discrete_range ; le `null` ici concerne T'RANGE en position d'*expression* → TROU ou « géré ailleurs » annoté avec renvoi |
| VALUE (2894) | TROU (attribut courant) |
| `when others => null` (2902) | **TROU générique — le plus urgent du fichier** |
| Chaînes elsif SANS else internes : 'C' (2770-2774), 'L' (2820-2830), 'M' (2833-2852), 'S' (2861-2888) | un attribut mal reconnu dans sa lettre tombe au travers → else TROU() dans chaque chaîne |

---

## 4. DEMI-BRUYANTS RESTANTS (PUT_LINE sans raise) — ~30 sites réels

A promouvoir TROU() (ou implémenter, ou documenter comme défaut) :

**expressions.adb** : 353 (OUT_ID), 359 (DISCRIMINANT_ID), 769 (indexed
multi-dim D6), 1091 (CODE_SLICE), 1316 (RECURSE_SELECTED), 1960 & 2050
(CONSTRAINED — **empile LI 0 : valeur mensongère**, cat. D), 2553 (SIZE
prefix), 2641 & 2692 (WIDTH — **empile LI 0**, cat. D), 2722/2743/2757
(préfixes d'attributs D6/D10), 3240/3258 (ARRAY_OPERAND), 3517
(COMPOSITE_OPERATOR — stub « bruyant équilibré » documenté pièges 53/55 :
DEFAUT DOCUMENTE, garder mais tagger), 3599/3765 (RECORD_EQUALITY), 3943
(FIXED*FIXED, pilier F-D : DEFAUT DOCUMENTE hors périmètre ?), 4173
(exponentielle entière), 4209 (op. unaire), 4366 (FUNCTION_CALL NAME.TY),
4680/4818/4926 (agrégats tableau), 5042/5092/5299 (agrégats record), 5966
(fixed→fixed small différent), 6021 (**CODE_CONVERSION cible non faite**
— l'exemple du briefing), 6323 (QUALIFIED), 6647/6706/6713
(RANGE_ATTRIBUTE), 6757 (DISCRETE_RANGE_BOUND).

**declarations.adb** : 1028 (ARRAY_VAR ASSOC.TY), 1812 (TYPE_ID générique),
2250 (RESULTAT UNCONSTRAINED — noter : 2259 « PAR REFERENCE » lève, lui).

**types_decls.adb** : 834 (index non integer), 1673/1691 (OFFSET NON
STATIQUE — **le layout continue avec des offsets faux**, cat. D), 2240
(SUBTYPE_DECL TYPE_SPEC.TY).

**instructions.adb** : 921 (INVERSE_RECURSE DEFN.TY), 1945 (ASSIGN DST
COMPONENT_ID DN_RECORD). — 600 et structures 636/763/787 sont des
ceintures « ANOMALIE » volontairement non fatales : DEFAUT DOCUMENTE,
tagger.

---

## 5. VALEURS PAR DEFAUT MENSONGERES (catégorie D)

| Site | Constat | Verdict |
|---|---|---|
| **utils.adb 134-146 TYPE_SIZE** | `when others` : PUT_LINE ILLICITE, **`raise` COMMENTE**, puis `return 0` — **taille 0 silencieuse, le pire site du corpus** (absent du briefing) | décommenter le raise → TROU() |
| types_decls ~1376-1392 STATIC_TYPE_ALIGN_BYTES | défaut 8 « conservateur (comportement STATOFS historique) », documenté en tête | DEFAUT DOCUMENTE — mais croiser OBLIGATOIREMENT avec le chantier n° 117 (alignement 8 imposé aux records représentés) ; le `when others => return 8` de l'OPER_SIZ_CHAR (1392) est légitime (quad) — le briefing visait en fait le défaut de la fonction, pas cette ligne |
| types_decls 1364-1369 STATIC_TYPE_SIZE_BITS | `return 0` par défaut (deux fois) | vérifier chaque appelant : 0 est-il détecté en aval ? Sinon TROU() |
| represented_items 118-140 REPRESENTED_RECORD_SIZE_BITS | cascade SM_SIZE → USED_BITS → CD_IMPL_SIZE, `when others => SIZE_BITS := 0` en handlers | acceptable EN CASCADE ; mais le `return SIZE_BITS` final peut rendre 0 — les appelants (l.517 « taille non geree » + raise) l'attrapent-ils tous ? Vérifier, sinon lever à la source |
| expressions 2050-2052 / 2692-2694 | type non traité → **LI 0 empilé** | TROU() (double faute : demi-bruyant + valeur fausse) |

---

## 6. PLAN D'EXECUTION PROPOSE

1. **Créer TROU()** (dans EXPANDER.UTILS, visible de tous les enfants) :
   message `"; !! TROU <site> : <NODE_NAME(TY)>"` sur le FINC **et**
   Standard_Error (leçon n° 96), puis `raise PROGRAM_ERROR` — sauf mode
   RECENSEMENT (drapeau CODI ou variable d'env) qui logge et continue.
   Surcharges utiles : TROU(SITE, NOEUD) et TROU(SITE) seul.
2. **Vague 1 — arbre de CODE_EXP** (§1a + §3 + CODE_USED_OP + CODE_POS) :
   else/when others TROU() partout. C'est la vague qui tue les n° 115.
3. **Vague 2 — CODE_ADRESSE, appels, retours** (frontières n° 112) +
   utils TYPE_SIZE (décommenter le raise).
4. **Vague 3 — arbre instructions** (§1b) + corps tasking + CODE_DELAY.
5. **Vague 4 — arbre déclarations/structures** (§1c) + corps null de §2.
6. **Vague 5 — demi-bruyants** (§4) : promus TROU() ou implémentés, les
   « ANOMALIE »/stubs équilibrés re-tagués DEFAUT DOCUMENTE.
7. **Annotation systématique** des INTENTIONNEL :
   `null;  -- INTENTIONNEL : <raison>`.
8. **Run RECENSEMENT** sur le corpus → liste des trous vivants dans
   ETAT_PILIERS (carnet de dettes, ordre d'implémentation).
9. **Oracles** : chaque TROU() promu en implémentation reçoit son oracle
   (ORACLES_TESTS) — jamais de rameau non exercé (n° 114/115).
10. **Entrée PIEGES** : « la discipline TROU() », fossile n° 115, avec la
    découverte de cette session : *le dispatch par classes sans else est
    un avaleur systémique, pas un accident local*.

## DEFINITION DE FINI (inchangée, précisée)

- `grep "null;" expander*.adb` ne rend que des lignes `INTENTIONNEL`.
- `grep "when others"` ne rend que raise / TROU() / DEFAUT DOCUMENTE.
- **Aucun if/elsif de dispatch sans else** (nouveau critère — le grep ne
  le voit pas : revue manuelle des ~35 dispatchers listés ici).
- Les ~30 demi-bruyants restants ont un verdict écrit.
- Un run RECENSEMENT complet est consigné dans ETAT_PILIERS.
