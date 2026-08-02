# VAGUE 3 « expander bruyant » — livraison du 28/07/2026

Périmètre exécuté (triage §6.4) : arbre de CODE_INSTRUCTION (§1b),
corps tasking d'instructions.adb, CODE_DELAY, annotations INTENTIONNEL
du même fichier. **Un seul fichier touché : expander-instructions.adb**,
base = sources post-vague 2, syntaxe `-gnats -gnat83` verte.
26 modifications, un seul commit.

## Oracle

Diff FINC corpus attendu **strictement vide** : la vague n'ajoute que des
else de dispatch, des corps morts convertis et des annotations — aucune
émission ne change tant qu'aucun trou n'est traversé. Puis run
RECENSEMENT (option W), triage du bilan, bascule STRICT, filet.

## Contenu

**Dispatchers de la liste §1b** (else TROU) : CODE_STM_ELEM, CODE_STM
(10 branches), CODE_STM_WITH_NAME, CODE_CALL_STM, CODE_STM_WITH_EXP,
CODE_STM_WITH_EXP_NAME, et les trois boucles d'alternatives de CODE_CASE
(ALLOCATE_ALTERNATIVE_LABELS, CODE_ALL_TESTS, CODE_ALL_BODIES — le
`null` du pragma d'alternative annoté INTENTIONNEL, else TROU).

**Dispatchers HORS LISTE, trouvés par la revue systématique** (le
critère de fini « aucun if/elsif de dispatch sans else » impose la revue
du fichier, pas de la seule liste — elle a payé) : CODE_CLAUSES_STM,
CODE_TEST_CLAUSE_ELEM_S, CODE_BLOCK_LOOP, CODE_ENTRY_STM, et le
INC/DEC de FOR_OR_REVERSE_LOOP — celui-ci n'est pas un avaleur ordinaire :
une itération ni FOR ni REVERSE aurait généré une **boucle infinie**
sans un mot.

**Corps vides → TROU** : CODE_ACCEPT, CODE_TERMINATE, CODE_ABORT,
CODE_SELECT_ALTERNATIVE, CODE_SELECTIVE_WAIT, CODE_COND_ENTRY,
CODE_TIMED_ENTRY, CODE_ENTRY_CALL (famille tasking, message « tasking
hors perimetre »), et CODE_DELAY (absent du briefing, relevé au triage).

**INTENTIONNEL annotés** : CODE_NULL_STM (le null Ada) ; CODE_STM_PRAGMA
(partiel — l'annotation dit explicitement de trier ICI le jour où un
pragma d'instruction devient signifiant, SUPPRESS/INLINE…).

**Deux DÉCOUVERTES de session** dans le dispatch des actuels de
CODE_PROCEDURE_CALL (hors charte vague 3 stricte, mais sur le chemin de
la revue et en pleine frontière d'appel) :
1. `DEFN.TY = DN_COMPONENT_ID` émettait `LI ` **sans opérande** — ligne
   FINC syntaxiquement cassée : l'erreur partait à l'assemblage, loin du
   site, au lieu de signaler à l'expansion. → TROU.
2. le `else` final (« DEFN.TY NON FAIT ») était un demi-bruyant — item
   §4 listé vague 5, promu ici car un actuel non empilé = déséquilibre
   garanti du protocole d'appel. → TROU.
   À rayer de la liste §4 (instructions 921 ancien numérotage).

## Faux positifs fermés par la revue

PARAMETRE_ENTREE_EN_GENERIQUE (couverture else complète des deux axes),
garde E-D3 `/= DN_ACCESS` (absence de range-check sur access voulue),
chaîne des actuels (else CODE_EXP présent).

## Observation consignée, sans action

Dans la branche out/in-out → formel in composite (~l. 892) : « le slot
contient déjà l'adresse, la propager » — adresse SEULE propagée vers un
formel in composite, à confronter au contrat @doublet des actuels le
jour de la normalisation SELARG/INDARG (vague 5). Non touché : zone
d'émission, pas de dispatch, aucun élément au dossier n° 112 pour
trancher aujourd'hui.

## Mises à jour documentaires à reporter

- ETAT_PILIERS, carnet TROU : ajouter la famille « arbre instructions
  (vague 3) » — 11 else de dispatch + 3 boucles CASE + 9 corps (8
  tasking + DELAY) + 2 découvertes actuels. Noter les 5 dispatchers
  hors liste.
- Triage §1b : cocher fait ; ajouter la leçon « la liste §1b était
  incomplète (5 dispatchers) : seule la revue systématique du critère
  de fini fait foi » — vaut pour les arbres declarations/structures de
  la vague 4.
- Triage §4 : rayer instructions 921 (promu vague 3).
- PIEGES : rien de nouveau à ériger (le fossile n° 115 couvre) ; la
  boucle infinie INC/DEC peut nourrir l'entrée « discipline TROU »
  comme exemple d'avaleur non-115 (pas un déséquilibre de pile : un
  programme faux qui tourne).

## Vague 4 (préparation)

Arbre déclarations/structures (§1c) + corps null §2 restants
(expander.adb : CONTEXT_PRAGMA, BLOCK_MASTER, DERIVED_SUBPROG,
IMPLICIT_NOT_EQ, SELECT_ALT_PRAGMA, DBGSTOP ; declarations : NULL_COMP,
NUMBER_DECL, DEFERRED_CONSTANT, TASK_DECL, RECORD_REP, « A VOIR » 2265,
USE_PRAGMA ; structures : CODE_TASK_BODY ; expressions : CODE_USED_OP
si restant). Y appliquer d'emblée la revue systématique, pas la liste.
