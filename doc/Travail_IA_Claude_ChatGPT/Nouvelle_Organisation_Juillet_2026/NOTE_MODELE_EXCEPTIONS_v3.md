# NOTE DE MODÈLE D'EXÉCUTION — EXCEPTIONS (pilier LRM 11) — v3 TELLE QUE CONSTRUITE

**7 juillet 2026 — pilier CLOS.** Remplace la v2 (document d'arbitrage) :
ceci décrit le modèle TEL QU'IL TOURNE, vérifié par EXC_TEST0/1/1U et
EXC_REN0 (oracles dans ORACLES_TESTS.md). Pièges associés : n° 69–76.

## 1. Stratégie (inchangée depuis l'arbitrage) : pile de contextes de reprise

Tout frame porteur de handlers empile à `begin:` (POST-élaboration → LRM
11.4.2 mécanique) un contexte de reprise ; `raise` = poser l'identité dans
EXCEPTIONS_CURRENT et sauter au déroulage, qui restaure EN BLOC l'état
machine depuis le contexte sommet et saute à son dispatch. Frames sans
handler : coût strictement NUL, balayés par la restauration. Pop AVANT
dispatch (11.4.1) : non-appariement, raise dans un handler et fin de
handler tombent juste sans code supplémentaire.

## 2. Répartition doctrinale (« codi = machine à pile »)

- **_standrd.adb (Ada 83, compilé par TLALOC)** : EXCEPTIONS_TOP_CTX,
  EXCEPTIONS_CURRENT (niveau 0), type EXCEPTION_CONTEXT — ses STATOFS SONT
  la spécification du layout binaire —, contexte-sentinelle EXC_CTX0, les
  cinq prédéfinies (exceptions ORDINAIRES, aucun cas particulier).
- **codi_x86_64.finc** : DEUX macros. `EXC_MACH lvl, ctx` (photographie de
  l'état caché — la seule chose que la LLIR ne sait pas dire) ;
  `EXC_RAISE top` (déroulage). `SYS_EXIT code:0` paramétrée. `excep:`
  fossile retiré.
- **Wrapper (CREATE_FAS_MAIN_FILE)** : init sentinelle après LINK 0 ;
  région inatteignable après SYS_EXIT : `exc_raise_:` (instance unique,
  BRA depuis tous les sites — 5 octets, dimensionné pour les checks) et
  `exc_uncaught_:` (imprime `EXCEPTION NON RATTRAPEE : ` + le nom lu dans
  la STR pointée par EXCEPTIONS_CURRENT, SYS_EXIT 1).
- **Expander** : TOUT le protocole en LLIR ordinaire (voir LLIR_REFERENCE
  § Exceptions) ; CODI porte HANDLER_CTX_AT (pops de sorties anticipées),
  HANDLER_LVL/HANDLER_CTX_SUF (raise nu), EXC_POP, EXCEPTION_ID_OF.

## 3. Le contexte de reprise (layout = record Ada, VARzone du frame)

`VAR exc_ctx_<Ldsp>, q, 8+lvl` — 7 qwords d'en-tête + FP(0..lvl).
PREV_CTX +0 / DISPATCH +8 / RBP +16 / RSP +24 / R13 +32 / R14 +40 /
NXT_LVL +48 / FRAME_POINTERS +56. Nom UNIQUE par frame (suffixe = numéro
du label de dispatch, fabriqué par LABEL_STR des deux côtés — piège 76) :
la résolution ascendante fasmg depuis un bloc interne ne peut pas se
tromper de contexte. VARzone (pas co-pile) : réutilisé à chaque itération,
insensible à la monotonie de R14 (piège 70) — jugé par 100 000 tours
(exc_test1 §12).

Préfixe display ENTIER FP(0..lvl) : tout appel de niveau ≤ lvl pendant la
séquence protégée écrase son entrée, et le raise saute les UNLINK qui
l'auraient restaurée. RBP photographié à la frontière d'instruction ; R13
ET R14 : libération en bloc des frames abandonnés ET des temporaires,
CO_VAR d'élaboration préservés (photo post-élaboration). L'invariant de
frontière d'instruction légitime les deux restaurations — c'est aussi le
SEUL point du système où R14 redescend.

## 4. Identité des exceptions

`STR <NOM>__exc, "<NOM>"` émise par CODE_EXCEPTION_DECL dans le namespace
de la région (postponée : hors flux par construction). **L'identité est
l'adresse `<REGIONS_PATH><NOM>__exc.data_ptr`** — comparée par CEQ,
imprimée par SYS_PUT_STR (le symbole EST son diagnostic), résolue par
fasmg inter-unités. Prédéfinies : mêmes STR dans STANDARD, même chemin.

**Renames (LRM 8.5, pièges 71-72)** : identité PARTAGÉE. Le rename n'émet
AUCUNE STR — un alias de namespace (`data_ptr` local := celui de la cible
directe ; les chaînes composent). Résolution au site d'usage par
EXCEPTION_ID_OF : descente DN_SELECTED (pas de SM_DEFN propre — couvre
raise et choix QUALIFIÉS) puis chaîne SM_RENAMES_EXC, qui porte
l'EXCEPTION_ID directement (contra diana_NODES — dump exc_ren0).

## 5. `raise;` nu (LRM 11.3, piège 75)

Relève l'exception DU handler englobant le plus interne — PAS la globale,
clobberée par toute exception traitée entre-temps (bloc interne ou appel).
À l'entrée de chaque dispatch : EXCEPTIONS_CURRENT copiée dans PREV_CTX
(+0), mort depuis le pop — sauvegarde PAR ACTIVATION, un exemplaire par
incarnation, aucun restore nulle part (le design EXC_HANDLED à
save/restore a été écarté pour cette raison). Le raise nu recharge de là ;
le fond de dispatch propage la globale (intacte à cet endroit). Juges :
exc_test1 §10.2/10.3 (adversariaux).

## 6. Sorties anticipées (piège 69 inclus)

CODE_RETURN / CODE_EXIT : boucle PAR NIVEAU — pop (si HANDLER_CTX_AT(L))
puis UNLINK L — plus, pour return, le pop du corps protégé de la procédure
elle-même. HANDLER_CTX_AT(L) vrai pendant la génération des stms protégés
SEULEMENT (effacé avant les alternatives : un return depuis un handler ne
pope pas — contexte déjà dépilé). `goto` : même comptabilité, en attente
du pilier 5.9 — l'infrastructure est prête.

## 7. Restrictions en vigueur

Handlers sur corps de PACKAGE : ANOMALIE (élaboration, différé).
Exceptions pendant l'élaboration des unités de bibliothèque → sentinelle.
TASKING_ERROR jamais levée (pilier 9). DN_CHOICE_RANGE en exceptions :
ANOMALIE. Checks runtime : hors pilier — point d'entrée prêt
(LCA STANDARD.<X>__exc.data_ptr ; Sa 0,EXCEPTIONS_CURRENT_disp ;
BRA STANDARD.exc_raise_).

## 8. Questions closes (traçabilité v1/v2)

Q1 (emplacement des globales) : VAR niveau 0 ordinaires de STANDARD.
Q2/Q2' (R14/UNLINK) : monotonie PORTEUSE, contexte en VARzone — piège 70.
Q3 : SYS_EXIT paramétrée. Q4 : raise nu dumpé avant codage (AS_NAME =
DN_VOID). Q5 : les STR portent le nom simple (choix d'implantation ;
la sentinelle reste univoque, l'adresse fait l'identité). Off-by-one de
la v2 corrigé : 8+lvl qwords (7 d'en-tête + lvl+1 de display).
