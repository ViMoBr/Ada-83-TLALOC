# NOTE DE MODÈLE D'EXÉCUTION — EXCEPTIONS (pilier LRM 11) — v2

**Date** : 6 juillet 2026 — v2 = fusion de la note de fin de session antérieure
(base) et de la note de rafraîchissement (ajouts marqués **[v2]**).
Soumise à arbitrage avant toute ligne de code — un seul point reste ouvert (Q2').
**Périmètre** : LRM 11.1–11.4 dans le périmètre statique. Exclus : TASKING_ERROR
levée réellement (pilier 9), pragma SUPPRESS (11.7), optimisations 11.6, et le
CÂBLAGE des checks prédéfinis (futur pilier « checks » — seul le point d'entrée
est ménagé ici).

---

## 1. Ce que sem fournit — lecture du dump exc_test0 du 6 juillet

1. `DN_EXCEPTION_DECL` → `AS_SOURCE_NAME_S` → `DN_EXCEPTION_ID` ne porte que
   `LX_SYMREP` et `XD_REGION` (la région englobante). Aucun CD_* prérempli,
   aucune numérotation front-end : l'identité des exceptions est entièrement à
   la charge de l'expander/runtime. `XD_REGION` alimente `REGIONS_PATH` →
   nommage symbolique uniforme.
2. `DN_RAISE.AS_NAME` → `DN_USED_NAME_ID` → `SM_DEFN` → le `DN_EXCEPTION_ID`
   déclarant. Minimal et propre. **Le `raise;` nu n'a pas été exercé par le
   témoin** — dump à produire au lot E-C avant de coder cette branche.
3. `AS_ALTERNATIVE_S` est présent sur **chaque** `DN_BLOCK_BODY` (corps de
   procédure comme blocs), **liste vide en l'absence de handlers**. Le prédicat
   « frame porteur de handlers » = `not IS_EMPTY(...)`, à un seul endroit.
   Structure interne isomorphe au case : `DN_ALTERNATIVE` → `AS_CHOICE_S`
   (`DN_CHOICE_EXP` / `DN_CHOICE_OTHERS`) + `AS_STM_S`.
4. Les prédéfinies sont des exceptions ORDINAIRES de STANDARD :
   `CONSTRAINT_ERROR` → `SM_DEFN` → `[DN_EXCEPTION_ID]` d'une page de
   `_STANDRD.DCL`. Aucun cas particulier dans l'expander ; obligation runtime :
   déclarer les cinq symboles dans `_STANDRD.FINC`.
5. Le témoin exerce déjà la propagation entre frames frères de MÊME niveau
   lexical (LEVE et BLOCK__2 tous deux CD_LEVEL=2) — le cas display vicieux,
   voir §4.
6. Le corps principal est sans handler : le cas « exception non rattrapée »
   est présent dès le premier témoin → sentinelle runtime requise dès E-0.

## 2. Arbitrage central : pile de contextes de reprise (stratégie a)

**(a) retenue** : tout frame porteur de handlers empile à l'entrée de sa partie
exécutable un CONTEXTE DE REPRISE (photographie des quatre états machine +
chaînage + adresse de dispatch). `raise` = déposer l'identité dans la globale
`EXC_CUR`, restaurer intégralement l'état depuis le contexte sommet, sauter au
dispatch du frame porteur. Non-appariement dans le dispatch = re-raise vers le
contexte suivant : **la propagation multi-frames tombe gratuitement**, les
frames intermédiaires sans handler ne coûtent RIEN et sont balayés par la
restauration en bloc.

**(b) écartée** (déroulage frame à frame via les `excep:` existants) : exige de
retrouver le `excep:` de l'appelant depuis une adresse de retour — table de
correspondance ou convention d'appel modifiée (toucher CALL/RTD). Déroulage
façon DWARF, disproportionné. **[v2]** Corollaire : le label `excep:` émis par
CODE_SUBPROGRAM_BODY devient un fossile — à retirer au lot E-A (piège n° 59 :
pas de stub mort).

Coût de (a) : ~quelques dizaines d'octets et ~15 instructions par ENTRÉE de
frame porteur de handlers (pas par frame tout court, pas par raise absent). Le
flux normal des frames sans handler est strictement inchangé.

**[v2]** Argument sémantique supplémentaire pour (a), gratuit : le push à
`begin:` (post-élaboration) réalise mécaniquement LRM 11.4.2 — voir §5.

## 3. Identité des exceptions : une constante STR par exception

Chaque `exception_decl` émet une constante **STR** (le doublet chaîne existant)
dont les octets sont le NOM de l'exception :

    STR  MON_ERREUR_exc, 'EXC_TEST0.MON_ERREUR'

L'IDENTITÉ est l'adresse du doublet — unique par construction, résolue par fasm
y compris inter-unités (même partage expander/fasm que STATOFS et size=$). Et
la sentinelle « non rattrapée » peut IMPRIMER le nom sans aucune table : le
symbole EST sa propre chaîne de diagnostic. Nommage par `REGIONS_PATH` + `_exc`,
uniforme avec les procédures (Q5 tranchée : chemin complet). Prédéfinies dans
`_STANDRD.FINC` :

    STR  CONSTRAINT_ERROR_exc, 'CONSTRAINT_ERROR'    ; + NUMERIC_ERROR,
                                                     ; PROGRAM_ERROR,
                                                     ; STORAGE_ERROR,
                                                     ; TASKING_ERROR

**[v2] Q1' émission hors flux : réglée par construction.** Relecture de la
macro STR dans le finc : elle émet ses données sous `postpone` — descripteur,
info et octets partent en fin d'assemblage, jamais dans le flux d'exécution.
La vérification « contournée par BRA post » est sans objet ; aucun contrôle à
faire au FINC témoin sur ce point.

## 4. Le contexte de reprise : quoi sauver, et pourquoi

Layout (emplacement : voir Q2', seul arbitrage restant) :

    +0   prev       q    contexte précédent (chaînage)
    +8   dispatch   q    adresse du dispatch de CE frame
    +16  sav_rbp    q    pile de travail, état POST-élaboration
    +24  sav_rsp    q    micro-pile (adresses de retour)
    +32  sav_r13    q    frame pointer de co-pile
    +40  sav_r14    q    sommet de co-pile
    +48  sav_nlvl   q    nombre d'entrées display sauvées = lvl+1
    +56  display[]  (lvl+1) × q   préfixe FP(0..lvl)

**Pourquoi le PRÉFIXE ENTIER du display, pas seulement FP(lvl)** : entre
l'empilement du contexte et le raise, la chaîne d'appel peut re-LINKer
n'importe quel niveau ≤ lvl. Cas concret DU TÉMOIN : BLOCK__2 (niveau 2,
porteur) appelle LEVE (niveau 2) → `LINK 2` écrase FP(2) ; un appel vers une
procédure de niveau 1 écraserait FP(1). Au moment du saut vers le handler,
FP(0..lvl) doivent être les incarnations du frame porteur. Les entrées > lvl
sont sans objet : toute exécution ultérieure les réécrira par LINK avant
lecture (adressage uplevel ≤ niveau courant). `lvl` étant statique au site
d'émission (CD_LEVEL), la sauvegarde est de taille fixe — `rep movsq` de
lvl+1 quadwords. (FP(0) n'est jamais re-LINKé — le macro LINK ignore lvl=0 —
mais l'inclure simplifie la boucle ; coût : un qword.)

**R14 sauvé et restauré** : plus strict que le flux normal (cf. Q2/Q2'),
correct dans les deux lectures : tout ce qui est au-dessus du R14 sauvé
appartient aux frames abandonnés ; les CO_VAR de la partie déclarative du
frame, élaborés AVANT la photographie, sont préservés. Le contexte lui-même
survit à la restauration : photographié APRÈS sa propre mise en place, il est
sous le R14 restauré tant qu'on le lit.

**RBP sauvé à l'état post-élaboration** : indispensable — les handlers
accèdent aux locales du frame. Invariant exploité : aux frontières
d'instructions, la pile de travail est revenue au niveau de `begin:` (les
temporaires sont consommés) — le RBP sauvé est donc l'état d'entrée correct
du dispatch et des handlers, quel que soit le point du raise.

## 5. Sémantique LRM à honorer explicitement

- **11.2 : les handlers ne couvrent PAS la partie déclarative de leur frame.**
  Une exception levée pendant l'élaboration se propage à l'appelant. Le
  placement de EXC_PUSH à `begin:` — APRÈS l'élaboration — n'est donc pas une
  commodité mais une exigence sémantique. Vaut aussi pour les blocs declare
  internes : leur partie déclarative s'exécute sous le contexte englobant tant
  que leur propre EXC_PUSH n'est pas passé. (Cas d'élaboration levante : hors
  témoins tant que les checks n'existent pas ; le placement suffit.)
- **11.4.1 : le contexte se dépile AVANT d'exécuter le dispatch/handler.**
  Sinon une exception levée DANS un handler reboucle sur lui-même ; dépilé
  d'abord, elle se propage naturellement au frame englobant. Le re-raise de
  fond de dispatch (aucun choix apparié) utilise le même invariant : EXC_TOP
  désigne déjà le contexte suivant.
- **Fin normale de handler** : le contrôle continue APRÈS le corps protégé —
  pour un bloc, chute dans l'épilogue normal (UNLINK du bloc, dont le frame
  est toujours lié : le display restauré y pointe) ; pour un corps de
  procédure, BRA vers ret_lbl (UNLINK + RTD).
- **Sortie normale du corps protégé** : EXC_POP (dépiler son contexte) avant
  l'épilogue.
- **`raise;` nu** : re-lever `EXC_CUR` (la globale le porte encore pendant le
  handler). Légal uniquement dans un handler — garanti par sem. Branche codée
  en E-C après dump.

## 5bis. [v2] Sorties anticipées traversant des corps protégés — PIÈGE ANNONCÉ

`return`, `exit` (et `goto` le jour venu) qui sortent d'un ou plusieurs corps
protégés doivent émettre un **EXC_POP par contexte traversé**, en parallèle de
la boucle d'UNLINK existante (CODE_RETURN, CODE_EXIT). Sinon EXC_TOP pointe
dans un frame mort : le premier raise ultérieur restaure un état poubelle et
saute dans du code de dispatch dont le frame n'existe plus.

Comptabilité statique : drapeau par niveau dans CODI
(`HANDLER_CTX_AT : array(LEVEL_NUM) of BOOLEAN`), posé par CODE_BLOCK_BODY à
l'émission du EXC_PUSH, effacé à la sortie. À tout point du programme il y a
au plus un bloc actif par niveau → le drapeau suffit ; la boucle d'UNLINK de
CODE_RETURN/CODE_EXIT teste chaque niveau traversé et intercale l'EXC_POP.

**La subtilité qui fera le piège si on l'oublie** : à l'intérieur du HANDLER,
le contexte du bloc est DÉJÀ dépilé (§5, pop avant dispatch). Le drapeau du
niveau doit donc être VRAI pendant la génération des statements protégés et
FAUX pendant la génération des alternatives — CODE_BLOCK_BODY l'efface AVANT
d'appeler CODE_EXCEPTIONS_ALTERNATIVE_S, pas après. Un `return` depuis un
handler ne pope PAS le contexte de ce bloc (mais pope ceux des blocs
englobants porteurs, dont les drapeaux restent levés).

Témoins obligatoires (ventilés dans la table §8) : return depuis statements
protégés, return depuis handler, exit de boucle dans bloc protégé, return
traversant deux corps protégés imbriqués.

`goto` sortant de bloc protégé : même comptabilité, mais CODE_GOTO est vide
(pilier 5.9 non ouvert) — consigné, non traité.

## 6. Livrables E-0 : runtime seul, validé sans l'expander

### 6.1 codi_x86_64.finc — globales et macros

    EXC_TOP:  dq 0        ; sommet de la pile de contextes (segment RWX, Q1 : OK)
    EXC_CUR:  dq 0        ; identité de l'exception en cours de traitement

**[v2] Q1 tranchée** : le segment unique est RWX (`p_flags dd 7`), les deux
`dq` statiques y sont légitimes. Replis consignés si un W^X arrive un jour :
deux qwords en base de co-pile à l'init, ou extension de la zone display de
32 à 34 qwords (`[r15+8*32]`, `[r15+8*33]` — adressage registre-relatif
homogène avec FP_IN_RAX, un seul point de modification au startup).

- `EXC_PUSH lvl, dispatch_lbl` : met en place le contexte (emplacement selon
  Q2'), remplit {EXC_TOP, dispatch, RBP, RSP, R13, R14, lvl+1, FP(0..lvl)},
  EXC_TOP := contexte. Tout est statique sauf les photographies.
- `EXC_POP` : EXC_TOP := [EXC_TOP].prev.
- `RAI` : dépile l'identité de la pile de travail → EXC_CUR ; RBX := EXC_TOP ;
  restaurer display (rep movsq depuis +56, compte à +48), R13, R14, RSP, RBP ;
  EXC_TOP := [RBX].prev ; `jmp [RBX+8]`. Clobbère RAX/RBX/RCX/RSI/RDI — tous
  légitimes (registres de travail / syscalls).
- `EXC_BT exc_sym, handler_lbl` : compare EXC_CUR à l'adresse de `exc_sym`,
  branche si égal. (Confort d'émission : dispatch sans trafic de pile.)
- `EXC_RERAISE` : ré-empile EXC_CUR et enchaîne sur RAI (fond de dispatch et
  `raise;` nu partagent cette macro).
- `SYS_EXIT` : paramètre `code:0` (Q3 tranchée : oui, rétrocompatible).

### 6.2 Sentinelle « exception non rattrapée »

Contexte statique de fond de pile, photographié au démarrage (juste après la
mise en place pile/display/co-pile du wrapper), EXC_TOP initialisé dessus. Son
dispatch : imprimer `EXCEPTION NON RATTRAPEE : ` + le nom (les octets du STR
pointé par EXC_CUR, via SYS_PUT_STR), puis `SYS_EXIT 1`. C'est aussi ce qui
rend les témoins auto-jugeants exploitables sur le cas non-rattrapé (message
greppable + code retour non nul, vérifiable par `$?`).

### 6.3 _STANDRD.FINC

Les cinq STR prédéfinies (§3).

### 6.4 Témoin E-0 : un .fas ÉCRIT À LA MAIN, sans expander

Valider le runtime isolément : main → EXC_PUSH + corps qui RAI → dispatch
2 choix + re-raise → frame intermédiaire sans contexte → cas non rattrapé.
**[v2]** + une sortie anticipée simulée (EXC_POP manuel puis raise : vérifier
que la propagation saute bien le contexte popé). Oracle : sortie attendue
exacte + codes retour. Quand E-A branchera l'expander, toute anomalie sera
imputable à l'émission, pas au mécanisme.

## 7. Côté expander (lots E-A/E-B/E-C, pour cadrage)

- `CODE_RAISE` (expander-instructions) : réécriture complète en style
  PUT_LINE — `LCA <path>_exc` + `RAI` ; l'ancien design EMIT(EXL/CD_LABEL)
  commenté est SUPPRIMÉ (piège n° 59 : pas de stub mort). `raise;` nu →
  `EXC_RERAISE` (E-C).
- `CODE_BLOCK_BODY` (expander-structures) : si `AS_ALTERNATIVE_S` non vide —
  émettre `EXC_PUSH lvl, <frame>_dsp` en tête de `begin:`, `EXC_POP` en sortie
  normale, `BRA` par-dessus la section dispatch+handlers, puis la section :
  `<frame>_dsp:` avec un `EXC_BT` par DN_CHOICE_EXP (adresse via SM_DEFN →
  REGIONS_PATH), `BRA` inconditionnel pour DN_CHOICE_OTHERS, `EXC_RERAISE` en
  fond, puis les corps de handlers terminés par BRA vers l'épilogue du frame.
  **[v2]** + pose/efface `HANDLER_CTX_AT(lvl)` (§5bis) — effacement AVANT
  l'appel à CODE_EXCEPTIONS_ALTERNATIVE_S.
- **[v2]** `CODE_RETURN` et `CODE_EXIT` : dans la boucle d'UNLINK des niveaux
  traversés, intercaler `EXC_POP` pour chaque niveau dont
  `HANDLER_CTX_AT(L)` est vrai.
- `CODE_EXCEPTIONS_ALTERNATIVE_S` : le squelette actuel émet les todos EN
  LIGNE dans le flux normal et sa chaîne de choix est l'anti-motif du piège
  n° 65 (if sans garde finale) — assainir à la réécriture : garde
  PROGRAM_ERROR sur choix non reconnu (DN_CHOICE_RANGE y est une ANOMALIE,
  déjà noté).
- `exception_decl` (expander-declarations) : émettre la STR (§3). Vérifier le
  chemin de dispatch des déclarations pour DN_EXCEPTION_DECL (probablement
  aucun aujourd'hui — silence à combler, piège n° 65 encore).
- **[v2]** Retrait du label `excep:` fossile de CODE_SUBPROGRAM_BODY et de la
  section 3.3 de LLIR_REFERENCE (mise à jour doc à la clôture).

## 8. Découpage en lots et témoins

| Lot | Contenu | Témoin | Oracle |
|---|---|---|---|
| E-0 | NOTE (ce document) + macros codi + sentinelle + 5 STR _STANDRD + init wrapper | .fas manuel (§6.4, avec sortie anticipée simulée) | sortie exacte + codes retour |
| E-A | raise/handler MÊME frame : CODE_RAISE, CODE_BLOCK_BODY, dispatch, exception_decl, retrait `excep:` ; **[v2]** infra HANDLER_CTX_AT + EXC_POP dans CODE_RETURN/CODE_EXIT | EXC_TEST1 auto-jugeant (bloc, when E, others ; **[v2]** + return depuis corps protégé de procédure, + return depuis handler) + EXC_TEST1U (non rattrapée, $? ≠ 0) | n OK, 0 ECHECS / PASSE ; message sentinelle greppable |
| E-B | propagation inter-frames : appels frères même niveau (cas display §4), récursion, handler levant, handler dans handler ; **[v2]** + exit de boucle dans bloc protégé, return traversant deux corps protégés | EXC_TEST2 auto-jugeant | idem + DEUX exécutions identiques (témoin anti-hors-bloc, piège n° 67) |
| E-C | `raise;` nu (dump préalable), prédéfinies rattrapées, point d'entrée checks documenté | EXC_TEST3 | idem |

Clôture : filet complet habituel (unités, ENUM/DIRECT_IO/SEQ_IO, RECORD_TEST,
ARRAY_TEST, ACVC A2–A8, auto-compilation) — EXC_PUSH ne touchant que les
frames porteurs de handlers, le flux de tout l'existant doit être
octet-à-octet inchangé (vérifiable par diff de FINC sur un témoin ancien).
Mise à jour ETAT_PILIERS + DIANA_COUVERTURE_TRIAGE (sortie de catégorie E des
nœuds du pilier 11) + LLIR_REFERENCE (§4.8, `excep:`) + tag git.

## 9. Questions — état après v2

- **Q1 — TRANCHÉE** : `dq` statiques dans le segment RWX, OK. Replis
  consignés en §6.1 si W^X un jour.
- **Q2 — CONFIRMÉE, devient Q2' (seul arbitrage restant).** La lecture est
  exacte : LINK fait `[r14]:=r13 ; r13:=r14 ; r14+=8`, UNLINK fait seulement
  `r13:=[r13]` — **R14 est monotone croissant**, la co-pile ne se libère que
  logiquement (chaîne R13), jamais physiquement. LLIR_REFERENCE §2.2 (« chaque
  UNLINK libère toutes les allocations du niveau ») décrit l'intention, pas le
  code. Le correctif serait `mov r14, r13` (3 octets) avant le pop — MAIS
  l'absence est peut-être délibérée : les résultats composites qui traversent
  l'UNLINK vers le haut (concat, retours de tableaux dynamiques alloués en
  co-pile du frame appelé) seraient rendus écrasables. **Audit requis** :
  CODE_RETURN copie-t-il TOUJOURS le composite côté appelant avant le ret ?
  (grep des chemins @co-pile franchissant un UNLINK descendant).
  **Conséquence directe sur cette note (Q2')** — emplacement du contexte §4 :
  - *co-pile* (design v1) : EXC_PUSH autonome (bump R14, pas de paramètre de
    déplacement), MAIS avec R14 monotone, un corps protégé dans une BOUCLE
    alloue 56+8(lvl+1) octets par itération, jamais repris → épuisement du Mo
    en ~10⁴ tours sans même lever d'exception. Viable seulement si Q2 est
    corrigée (UNLINK redescend R14).
  - *VARzone du frame* : `VAR exc_ctx, q, 7+lvl` — statique, réutilisé à
    chaque itération, insensible à Q2 ; prix : EXC_PUSH prend un paramètre de
    déplacement (adressage frame-relatif, mécanique existante Sa/La).
  Recommandation : si l'audit Q2 autorise le correctif UNLINK, le faire (il
  éteint une dette générale — les CO_VAR en boucle fuient déjà AUJOURD'HUI,
  hors exceptions) et garder la co-pile ; sinon VARzone. Dans les deux cas,
  consigner Q2 dans PIEGES/dettes.
- **Q3 — TRANCHÉE** : `SYS_EXIT code:0`, rétrocompatible.
- **Q4 — CONFIRMÉE** : dump du `raise;` nu avant codage de sa branche (E-C) ;
  AS_NAME = DN_VOID supposé, à confirmer sur le dump.
- **Q5 — TRANCHÉE** : chemin complet REGIONS_PATH dans les STR d'identité,
  cohérent avec le nommage des procédures ; coût = octets postponés.

**Addendum suite à critique positive ChatGPT 5.5**

Notes avant codage :

1. Pour les STR d’identité, attention à .data_ptr

Dans le codi_x86_64.finc actuel, STR NOM, '...' crée un namespace NOM et le doublet commence à NOM.data_ptr. L’exemple LLIR existant charge les chaînes avec LCA STR_L1.data_ptr, pas avec LCA STR_L1. La référence LLIR montre cette convention dans le squelette de procédure.

Donc je remplacerais partout l’idée :

LCA MON_ERREUR_exc
EXC_BT MON_ERREUR_exc, handler

par :

LCA MON_ERREUR_exc.data_ptr
EXC_BT MON_ERREUR_exc.data_ptr, handler

ou alors il faut créer une macro dédiée EXC_STR qui définit explicitement un alias utilisable comme adresse. Mais le plus simple est de rester homogène avec STR.

2. Le calcul de taille du contexte en VARzone est off-by-one

Le layout proposé contient 7 qwords fixes :

prev, dispatch, sav_rbp, sav_rsp, sav_r13, sav_r14, sav_nlvl

puis lvl + 1 entrées de display, de FP(0) à FP(lvl).

La taille totale est donc :

7 + (lvl + 1) = lvl + 8 qwords

La note mentionne VAR exc_ctx, q, 7+lvl. Avec FP(0) inclus, il faut 8+lvl. Pour un frame de niveau 2, cela fait 10 qwords, pas 9.

3. Je choisirais VARzone pour le contexte, pas la co-pile, au moins pour E-A/E-B

La note a très bien isolé Q2’ : le UNLINK actuel restaure R13 mais ne redescend pas R14. Cela rend la co-pile monotone physiquement. Dans ces conditions, placer les contextes d’exception en co-pile crée une fuite immédiate dans une boucle contenant un bloc protégé, même si aucune exception n’est jamais levée.

Ma recommandation opérationnelle : prendre VARzone maintenant.

Donc la macro devrait probablement être :

EXC_PUSH lvl, ctx_disp, dispatch_lbl

et non seulement :

EXC_PUSH lvl, dispatch_lbl

Le contexte devient un objet local statique du frame :

VAR exc_ctx, q, 8+lvl

Avantages : pas de fuite, réutilisation à chaque itération, pas de correction globale risquée de UNLINK avant le pilier exceptions.

La correction de UNLINK/R14 reste une dette générale à auditer séparément, car elle peut toucher les résultats composites dynamiques qui traversent un retour de fonction.

4. raise; nu et handlers imbriqués : une seule globale EXC_CUR sera insuffisante à terme

Pour E-A simple, EXC_CUR suffit. Pour E-C et surtout pour les handlers imbriqués, il y a un piège sémantique.

Exemple :

exception
   when E1 =>
      begin
         raise E2;
      exception
         when E2 => null;
      end;
      raise;  -- doit re-lever E1, pas E2
end;

Avec une seule globale EXC_CUR, le handler interne écrase EXC_CUR avec E2. Après retour du handler interne, un raise; dans le handler externe risque de relancer E2 au lieu de E1.

Je distinguerais donc deux notions :

EXC_CUR       exception en cours de propagation / dispatch
EXC_HANDLED   exception courante du handler actif, pour raise;

Ou, plus exactement, une petite pile logique de “current handled exception”. Pour minimiser les macros, on peut générer le save/restore côté expander autour de chaque corps de handler, mais il faut prévoir le modèle dès maintenant :

à l’entrée d’un handler : sauvegarder l’ancien EXC_HANDLED, puis EXC_HANDLED := EXC_CUR;
raise; doit re-lever EXC_HANDLED, pas forcément EXC_CUR;
à la sortie normale du handler : restaurer l’ancien EXC_HANDLED;
pour une sortie abrupte depuis le handler, même question que EXC_POP : il faut restaurer les contextes de handler traversés.

Tu peux différer le codage complet à E-C, mais il faut éviter d’ancrer l’idée “raise; = EXC_CUR” trop profondément.

5. Exception renaming : ne pas créer une nouvelle identité

DIANA a DN_RENAMES_EXC_DECL. L’identité d’une exception renommée doit être celle de l’exception renommée, pas une nouvelle STR.

Donc pour :

E1 : exception;
E2 : exception renames E1;

ces formes doivent comparer égales :

raise E2;

exception
   when E1 => ...

Je traiterais renames_exc_decl ainsi :

soit aucun symbole nouveau, et raise/choice résolvent toujours jusqu’à l’exception réelle ;
soit alias FASM : E2_exc.data_ptr équivaut à E1_exc.data_ptr, mais sans créer de second doublet.

C’est un test E-C à ajouter.

Témoins à ajouter

Le témoin initial est bien choisi pour amorcer : handler local, propagation inter-frame, prédéfinie non appariée puis others. Mais je renforcerais la campagne comme suit :

Handler accédant aux locales du frame protégé : prouve que RBP et le display sont restaurés correctement.
Appel frère même niveau : déjà dans LEVE → BLOCK__2, à garder absolument.
Bloc protégé dans une boucle longue sans exception : détecte immédiatement une fuite si le contexte est en co-pile.
Exception levée pendant l’élaboration d’un bloc avec handler : doit être captée par le contexte englobant, pas par le handler du bloc en cours d’élaboration.
Return depuis corps protégé : doit EXC_POP.
Return depuis handler : ne doit pas poper le contexte du bloc déjà dépilé.
Exit traversant un bloc protégé : même logique que return.
Handler qui lève une autre exception : doit propager vers l’englobant, pas reboucler.
Handler imbriqué puis raise; externe : détecte le problème EXC_CUR/EXC_HANDLED.
Exception renames : identité aliasée.
Non rattrapée : message exact + code retour 1.
Verdict final

Je conserverais la stratégie. Elle est bien adaptée à TLALOC et à la LLIR actuelle. Les deux changements que je ferais avant de coder sont :

Contexte en VARzone, avec taille 8+lvl qwords et macro EXC_PUSH lvl, ctx_disp, dispatch_lbl.
Clarification immédiate de l’identité STR : utiliser systématiquement .data_ptr.

Et je documenterais dès maintenant deux dettes à ne pas oublier : EXC_HANDLED pour raise; dans les handlers imbriqués, et renames_exc_decl comme alias d’identité, pas comme nouvelle exception.