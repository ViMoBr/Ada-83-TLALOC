# SESSION 18 JUILLET 2026 — AUTO-ASSEMBLAGE ADA_COMP
# Blocs à coller dans les fichiers de contexte.
# NOTE NUMÉROTATION : la copie projet de PIEGES.md s'arrête au n° 96, mais le
# code référence déjà n° 97 (garde definite) et n° 99 (TYPE_INFO_STR) — le
# registre vivant est en avance. Les entrées ci-dessous sont numérotées 100–105 ;
# ajuster au premier numéro réellement libre avant collage.


=====================================================================
=== À COLLER EN FIN DE JOURNAL_SESSIONS.md ===
=====================================================================

## Session 18 juillet 2026 — Auto-assemblage ADA_COMP (fasmg oracle de cohérence)

Objectif : assembler ADA_COMP.fas complet (IDL + EXPANDER auto-compilé).
fasmg joue l'oracle de cohérence inter-unités : chaque symbole fantôme
est un mensonge entre le site déclarant et le site utilisant. Sept
défauts soldés en chaîne, tous par lecture du trace fasmg (la pile de
macros nomme l'argument fautif : `FETCH_DWORD` ⇒ 3e opérande, garde
`LId` ⇒ 2e — discriminant décisif à deux reprises).

**(1) Records représentés dérivés/privés** (DEFINTERP_TYPE = new TREE,
privé, SET_UTIL). HAS_COMPONENT_REP répondait FALSE sur PT hérité :
la garde XD_REGION de FIND_COMP_REP_ELEM_FROM_COMPONENT n'acceptait
que DN_TYPE_ID, or un type privé a pour occurrence canonique un
DN_PRIVATE_TYPE_ID — REGIONS_PATH le savait (ligne ~729), pas
REPRESENTED_ITEMS. Élargissement des gardes (DN_PRIVATE_TYPE_ID,
DN_L_PRIVATE_TYPE_ID) + CODI.FULL_VIEW dans FIND_COMP_REP_ELEM et
CODE_STORE_REP_COMPONENT ; verrous posés dans COMPILE_RECORD_VAR
(3 sites) : record représenté sans comp_rep trouvé ⇒ LÈVE — le
namespace représenté n'exporte AUCUN offset, la branche offset y est
structurellement illégale.

**(2) Corps génériques : _disp/_ofs** (MESSAGE : in STRING de
REQ_TYPE_XXX). LOAD_MEM, branche « formel objet de type non formel »,
émettait `-X_disp` (nom physique côté instance) au lieu de `-X_ofs`
(constante d'accès relative au GFP, bloc virtual de
CODE_GENERIC_FRAME_OFFSETS). Deux lignes (scalaire + composite) ; la
branche HAS_GENERIC_TYPE voisine était correcte (preuve par symétrie).

**(3) Piège n° 99 en rafale : sous-types tableaux anonymes.**
`_OBJ.FST_1` fabriqué au lieu de `_OBJ__type.FST_1` (namespace local
de COMPILE_ARRAY_VAR) : d'abord le 'RANGE de boucle
(CODE_RANGE_ATTRIBUTE_BOUND, branche CLASS_VC_NAME), puis 'FIRST/'LAST
en expression (CODE_ATTRIBUTE, branche variable tableau) — même
maladie, organes distincts. Balayage systématique vers TYPE_INFO_STR ;
le balayage a introduit ses régressions : la substitution mécanique
`'_' & PRINT_NAME( X )` → `TYPE_INFO_STR( X )` passait le SYMBOL_REP
(diagnostic D : « PAS D ATTRIBUT XD_SOURCE_NAME DANS DN_SYMBOL_REP » —
imprimé SANS lever, FINC corrompu en aval, n° 96 en sursis). Helper
durci et généralisé : accepte un SPEC (descente XD_SOURCE_NAME) ou un
NAME (retour direct — un nom écrit dans le source n'est jamais
anonyme), lève sinon. Forme B légitime recensée
(CODE_SCALAR_SUBTYPE_FIRST_LAST) : pour les bornes de sous-types
scalaires, le nom AU SITE fait foi, pas l'alias canonique du spec.

**(4) with d'un sous-programme de bibliothèque** (EXPANDER depuis
ADA_COMP) : CALL vers `EXPANDER_L1.elab` jamais défini. Trois trous :
CODE_WITH_CONTEXT branche DN_PROCEDURE_ID posait CD_LEVEL/CD_PARAM_SIZE
sans émettre l'include ; CODE_TRANS_WITH_INCLUDES filtrait sur
PACKAGE/GENERIC seulement ; tête de FINC des unités sous-programmes
sans la garde `X = 'X'` (convention n° 97, réservée jusqu'ici à
CODE_PACKAGE_DECL/CODE_GENERIC_DECL). Correctifs aux trois sites
(+ DN_FUNCTION_ID par symétrie) et régénération d'EXPANDER.FINC.
Dette consignée : CD_PARAM_SIZE := 0 fabriqué en aveugle pour les
sous-programmes withés — garde à poser si la liste de formels est non
vide.

**(5) CODE_RETURN et types universels** (TYPE_SIZE d'expander-utils,
unité compilée pour la première fois — le refus bruyant R6 a parlé).
`return ADDR_SIZE;` (nombre nommé) : DN_UNIVERSAL_INTEGER hors
dispatch. Correctif LRM : expression universelle ⇒ FULL_VIEW du
sous-type de RETOUR de la fonction (déjà calculé pour le check E-D3,
hissé) ; et caractère de store dérivé de CE type (EXP_TYPE_CHAR sur
un universel aurait répondu 'b' — Sb dans un slot relu en d, R6 bis
silencieux évité). DN_UNIVERSAL_REAL couvert par le même repli.

**(6) Renames d'objets : bug bilatéral** (tab renames ASCII.HT,
UTILS). Le modèle pointeur de CODE_RENAMES_OBJ_DECL (VAR X_disp,q +
adresse à l'élaboration — conforme LRM 8.5, constituants évalués une
fois) était trahi des deux côtés : usage `LIb 1, TAB_disp, 0` SANS
REGIONS_PATH (UTILS est un namespace FRÈRE de REPRESENTED_ITEMS — la
remontée fasmg ne trouve que les parents) ; et l'élaboration rangeait
la VALEUR (`LI 9` / `Sa`) : CODE_OBJECT_ADDRESS → CODE_SELECTED
(IS_SOURCE => FALSE) → PROCESS_DESIGNATOR, dont la branche
CONSTANT/NUMBER/ENUM pliait en LI sans consulter IS_SOURCE — seule
branche de la procédure à l'ignorer. Correctif : branche constante
sensible à IS_SOURCE (LVa + REGIONS_PATH + _disp — le stockage existe,
STANDARD.ASCII.HT_disp) ; NUMBER_ID et LITTÉRAL D'ÉNUM en contexte
adresse ⇒ LÈVE (pas des objets Ada, pas de stockage — le pliage muet
refabriquerait un pointeur-valant-9).

**(7) fasmg multi-passes** : la répétition de la liste d'includes est
le rejeu normal des displays à chaque passe, pas une ré-inclusion
(les gardes `~ definite` protègent AU SEIN d'une passe). Temps dominé
par EXPANDER.FINC (volume). Thermomètre de convergence : le compteur
`optim push_pop_rax_count` — décroissance puis répétition = proche ;
OSCILLATION = cycle décision↔adresses, remède : rendre l'optimisation
monotone entre passes (hystérésis). Limite de passes fasmg = message
explicite, pas de blocage muet.

**État de sortie** : fasmg ne signale plus d'erreur de symbole ;
assemblage en convergence au moment de la clôture. À consigner au
premier succès : le NOMBRE DE PASSES du résumé final (référence de
non-régression de convergence). Patchs : expander-utils,
expander-represented_items, expander-declarations, expander-expressions,
expander-instructions, expander-structures ; EXPANDER.FINC régénéré.


=====================================================================
=== À COLLER EN FIN DE PIEGES.md (ajuster les numéros : voir note en tête) ===
=====================================================================

100. **XD_REGION d'un composant peut être DN_PRIVATE_TYPE_ID** (records
  représentés dérivés, session bootstrap). La garde « OWNER.TY =
  DN_TYPE_ID » de FIND_COMP_REP_ELEM_FROM_COMPONENT rejetait les
  discriminants hérités d'un type PRIVÉ dérivé (new TREE) → branche
  offset sur un record représenté → symbole fantôme. REGIONS_PATH
  acceptait déjà PRIVATE/L_PRIVATE_TYPE_ID : quand un consommateur de
  XD_REGION énumère les espèces, s'aligner sur la liste de
  REGIONS_PATH. Corollaire verrouillé dans COMPILE_RECORD_VAR : un
  record représenté n'exporte AUCUN offset — comp_rep introuvable ⇒
  LÈVE, jamais la branche offset.

101. **`_disp` et `_ofs` ne se mélangent pas dans un corps générique.**
  `X_disp` = physique côté INSTANCE (VAR) ; `X_ofs` = constante
  d'accès relative au GFP (bloc virtual de
  CODE_GENERIC_FRAME_OFFSETS), seul nom légal dans le corps :
  `La n,-GFP_ofs` puis `LVA ,-X_ofs`. LOAD_MEM écrivait `-X_disp`
  (deux lignes, scalaire et composite) — l'erreur fasmg ressemble à
  un défaut REGIONS_PATH mais le chemin est bon, seul le suffixe ment.

102. **TYPE_INFO_STR : contrat d'argument, et la regex qui le viole**
  (extension du n° 99). Le helper prend un TYPE_SPEC (descente
  XD_SOURCE_NAME) ou, version généralisée, un TYPE_NAME (retour
  direct : un nom du source n'est jamais anonyme) ; tout le reste —
  en particulier un DN_SYMBOL_REP — LÈVE. La substitution mécanique
  `'_' & PRINT_NAME( X ) → TYPE_INFO_STR( X )` passe le symrep dans
  100 % des cas (X était `D( LX_SYMREP, ... )`). Forme B légitime à
  NE PAS convertir vers le spec : bornes de sous-types scalaires
  (CODE_SCALAR_SUBTYPE_FIRST_LAST) — le nom AU SITE fait foi, l'alias
  canonique du spec peut différer.

103. **Un sous-programme de bibliothèque withé s'inclut comme un
  paquetage.** CODE_WITH_CONTEXT (DN_PROCEDURE_ID/DN_FUNCTION_ID) et
  CODE_TRANS_WITH_INCLUDES doivent émettre la garde d'include ; et la
  tête de FINC d'une unité sous-programme doit porter `X = 'X'`
  (convention n° 97 — était réservée aux paquetages/génériques).
  Sinon : CALL émis, `X_L1.elab` jamais défini. Dette active :
  CD_PARAM_SIZE := 0 posé en aveugle par la branche with — faux dès
  qu'un sous-programme withé aura des formels (garde à poser).

104. **Expression universelle en `return` = type de RETOUR, pas type
  de l'expression.** `return ADDR_SIZE;` (nombre nommé) →
  DN_UNIVERSAL_INTEGER, hors CLASS_SCALAR. Repli : universel ⇒
  FULL_VIEW du sous-type de retour. ET le caractère de store vient de
  ce type : EXP_TYPE_CHAR sur un universel répond 'b' (CD_IMPL_SIZE
  absent) — Sb dans un slot résultat relu en d = 24 bits de bruit,
  silencieux. Deux corrections indissociables.

105. **Le pliage de constante doit consulter IS_SOURCE** (renames,
  élaboration). Dans PROCESS_DESIGNATOR, la branche
  CONSTANT/NUMBER/ENUM émettait `LI valeur` même en contexte ADRESSE
  (CODE_OBJECT_ADDRESS → IS_SOURCE=FALSE) : le slot pointeur du
  renommage recevait la valeur (déréférencement de 9 au premier
  usage). Constante : LVa + REGIONS_PATH + _disp (le stockage existe
  dans _STANDRD). Nombre nommé / littéral d'énumération : PAS des
  objets, pas d'adresse ⇒ LÈVE. Bug frère au même endroit : l'usage
  du renommage émettait le _disp SANS REGIONS_PATH — un namespace
  FRÈRE n'est pas trouvé par la remontée fasmg (seuls les parents le
  sont) : l'absence de chemin n'est tolérable qu'intra-région.

106. **fasmg est multi-passes : les displays se rejouent.** La
  répétition de la liste d'includes = passes successives, pas une
  ré-inclusion (les gardes `~ definite` agissent AU SEIN d'une
  passe). Diagnostic de convergence : suivre `push_pop_rax_count`
  par passe — répétition = convergence proche ; oscillation =
  optimisation dont la décision dépend des adresses qu'elle modifie
  ⇒ la rendre MONOTONE entre passes (un verdict « non élidé » ne se
  reprend pas), quitte à laisser des octets. Consigner le nombre de
  passes du premier assemblage réussi comme référence.

  Lecture de trace acquise (2 occurrences décisives) : la pile de
  macros de l'erreur fasmg désigne l'ARGUMENT fautif — `macro LId /
  macro FETCH_DWORD : if disp = 0` ⇒ c'est le 3e opérande (offset)
  qui est indéfini, le 2e (base) a déjà été consommé par
  INDIRECT_BASE_IN_RAX. Trancher par la pile avant de soupçonner un
  opérande.


=====================================================================
=== ETAT_PILIERS.md — lignes à mettre à jour ===
=====================================================================

Remplacer la ligne « 8.5 Renames d'objets » du tableau par :

| 8.5 Renames d'objets | modèle pointeur complet pour le bootstrap : élaboration (adresse réelle, y compris constante prédéfinie — pliage sensible à IS_SOURCE, n° 105), usages avec REGIONS_PATH ; tranches par doublet CODE_SLICE ; nombre nommé/littéral d'énum en contexte adresse ⇒ lève | 18 juillet 2026 |

Ajouter au tableau (ou à la section d'état courant) :

| Bootstrap : auto-assemblage ADA_COMP (fasmg) | plus d'erreur de symbole ; convergence multi-passes en cours à la clôture de session — consigner le nombre de passes au premier succès (référence n° 106) ; dette CD_PARAM_SIZE=0 des sous-programmes withés (n° 103) | 18 juillet 2026 |
