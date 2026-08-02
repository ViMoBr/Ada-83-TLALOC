# BILAN RECENSEMENT AUTO-COMPILATION — TRIAGE ET ORDRE DE BATAILLE (28/07/2026)
## CLOTURE — 1er aout 2026

Campagne « expander bruyant » close (5 vagues + 6 reclassements) : plus
aucun avaleur silencieux. Le premier run RECENSEMENT complet sur
l'auto-compilation rend **187 traversées, 10 familles** — chacune est
désormais un chantier nommé. Décision de méthode actée : les segfaults
attendent, on met les FINC en ordre d'abord (chasser un segfault au
travers de FINC déclarés SUSPECTS = travailler sur du sable).

Discipline inchangée : UN chantier = UN témoin ORACLES **écrit avant**
l'implantation (n° 114/115 : rameau jamais exécuté = faux), diff FINC +
re-run recensement + filet à chaque pas. Le compteur de traversées doit
décroître de façon comptable à chaque chantier soldé.

## Le bilan consolidé

| # | Famille | Trav. | Coût estimé | Risque si mal fait |
|---|---------|------:|-------------|--------------------|
| C1 | Conversion vers RECORD (+1 CONSTRAINED_ARRAY) | 60 | SOLDÉ 30/07  | faible |
| C2 | CODE_CASE choix = marque de sous-type | 82 | SOLDÉ 30/07 | contrôle faux |
| C3 | Lecture d'un OUT | 2 | SOLDÉ 30/07 | faible |
| C4 | COMPILE_ARRAY_VAR init par objet entier | 3 | SOLDÉ 30/07 | données fausses |
| C5 | Exponentielle entière générale | 21 | SOLDÉ 30/07 | pile |
| C6 | CODE_SLICE préfixes ALL/INDEXED | 3 |  SOLDÉ 30/07 | adressage |
| C7 | Instanciation resultat non contraint | 10 | SOLDÉ 01/08 (relais du slot, piege n 123 ; oracle INSTF1) |
| C8 | 'ADDRESS (overlay) | 3 | SOLDÉ 01/08 — voie IMPLANTATION retenue (pas la voie 3) : equation fasmg + grille des sortes (n 124) ; oracle ADDR_OV1 |

Ordre proposé = coût croissant À VOLUME ÉGAL, mais C1 d'abord (60
traversées pour un coût quasi nul), puis C2 (le gros volume). Après
C1+C2 : ~144 des 187 traversées tombent.

## C1 — Conversion vers un type RECORD (59) + CONSTRAINED_ARRAY (1)

Diagnostic : conversions entre types DÉRIVÉS (set_util : les types de
sets privés dérivés ; idl.adb : tableau). LRM 4.6 : entre type dérivé et
parent, MÊME représentation — la conversion composite est une IDENTITÉ
sur le doublet. Le TROU actuel laisse d'ailleurs la valeur telle quelle :
le comportement est DÉJÀ correct, il ne manque que le verdict.
Implantation : brancher DN_RECORD | DN_CONSTRAINED_RECORD → null
INTENTIONNEL (« dérivation : même représentation, identité »).
DN_CONSTRAINED_ARRAY : identité aussi, MAIS consigner au carnet la
dette « glissement de bornes + vérification d'index » (LRM 4.6(11)) —
non exercée par le corpus (conversion entre sous-types de même profil).
Témoin : conversion record dérivé aller-retour + comparaison ; tableau
dérivé idem.

## C2 — CODE_CASE, choix = marque de sous-type (84)

Diagnostic : `when UN_SOUS_TYPE =>` (LRM 5.4 : la marque dénote son
intervalle). Le corpus du compilateur en vit — 29 dans gen_subs seul.
Implantation : dans CODE_CHOICE_RANGE_TEST, brancher DN_DISCRETE_SUBTYPE
→ récupérer FIRST/LAST du sous-type et émettre la MÊME fenêtre
CLT/CGT/BF que DN_RANGE. Bornes : STATIC_BOUND_VALUE (exporté au
reclassement n° 5) quand statiques — le cas du corpus (sous-types de
NODE_NAME à bornes littérales) ; sinon TROU résiduel « bornes non
statiques » (discriminé, on ne bénit pas au-delà de l'observé).
Témoin : case avec choix sous-type statique, couvrant premier/dernier/
hors-fenêtre.

## C3 — Lecture d'un OUT (2)

Nos propres sources (types_decls) relisent un paramètre out après
l'avoir écrit — toléré par le front-end. Le slot d'un out scalaire
contient l'adresse de la valeur (protocole n° 91/94), exactement comme
in out : brancher DN_OUT_ID sur le MÊME chemin que DN_IN_OUT_ID.
Témoin : procédure à out relu après écriture.

## C4 — COMPILE_ARRAY_VAR, init par objet entier (3)

`X : ARR := Y;` — la mécanique existe déjà aux sites d'affectation :
taille (.SIZ/8), CODE_COMPOSITE_DATA_ADDRESS( Y ) → @SRC, BLKMOV, sur
le modèle exact de la branche tranche voisine. Témoin : init par objet,
par appel de fonction, par qualifié (les trois formes @doublet de la
règle unique).

## C5 — Exponentielle entière générale (22)

X**N hors les cas pliés (N=2 déjà traité par DEC/SHL). Deux voies :
boucle inline à labels (résultat=1 ; tant que N>0 : MUL...) ou helper
runtime `_powi` émis dans le prélude (à côté de ce_raise_) — préférer le
helper : émis une fois, testable seul, pas de jonglage de labels à
chaque site. Sémantique Ada : N < 0 sur entier = CONSTRAINT_ERROR
(brancher sur ce_raise_). Témoin : 3**5, X**0, X**1, exposant variable,
exposant négatif (levée).

## C6 — CODE_SLICE, préfixes DN_ALL / DN_INDEXED (3)

Tranche d'un déréférencé ou d'un composant indexé. La base @data du
préfixe s'obtient par la machinerie composant existante ; à instruire
contre le modèle d'adressage (n° 112) avant de coder. Témoins : P.all(2..5),
A(I)(2..5), source ET destination.

## C7 — Instanciation de fonction générique à résultat non contraint (10)

Le dur du lot : le protocole résultat (slot + RTD prm_siz-8) suppose une
taille connue de l'appelant ; un résultat DN_ARRAY non contraint (STRING
des utilitaires génériques) ne l'a pas. À croiser avec la dette jumelle
« RESULTAT UNCONSTRAINED » de l'épilogue ordinaire (promue TROU vague 5)
et l'oracle manquant du carnet (fonction ordinaire retournant tableau à
bornes dynamiques) : c'est UN SEUL modèle d'exécution à écrire —
NOTE_MODELE avant tout code, méthode des piliers. Dernier chantier.

## C8 — 'ADDRESS : la décision est éclairée par le compte

TROIS sites vivants seulement (print_nod 1, univ_ops 2). La voie 3
(réécriture source en unchecked_conversion, déjà supportée) coûte trois
petites retouches de VOS sources et débloque tout — l'implantation
overlay (voies 1/2 du dossier CHANTIER_ADDRESS_OVERLAY) reste au carnet
pour le jour où un témoin la réclamera. Recommandation : voie 3.

## Séquencement

1. FAIT C1 (60 traversées, une session courte) → re-run : ~127 attendues.
2. FAIT C2 (84) → re-run : ~43.
3. FAIT C3+C4 (5) en une session → ~38.
4. FAIT C5 (22) → ~16.
5. FAIT C6 (3) → ~13.
6. FAIT C8 décision + retouches sources → ~10.
7. FAIT C7 (10, avec sa NOTE_MODELE) → **0. Bascule STRICT permanente.**
8. Alors seulement : retour aux segfaults, sur des FINC sains.

**RECENSEMENT A ZERO (listing du 01/08 sans TROU). Sequencement point 7
ATTEINT : bascule STRICT permanente** — option W retiree du filet,
TROU_RECENSEMENT = FALSE par defaut ; tout trou futur = PROGRAM_ERROR,
plus aucun FINC SUSPECT assemblable. L'oracle negatif n 118 devient le
regime de croisiere.

**Point 8 : reprise des segfaults** (null_prog,
phase post-PAR_PHASE) — voir memo de reprise en tete du JOURNAL ;
diagnostics d'avant le 28/07 a re-observer (univ_ops et print_nod
executent leurs overlays pour la premiere fois).

