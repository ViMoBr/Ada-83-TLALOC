# VAGUE 4 « expander bruyant » — livraison du 28/07/2026

Périmètre exécuté (triage §6.5) : arbre déclarations/structures (§1c) +
corps `null` restants du §2, avec revue systématique (leçon vague 3).
Quatre fichiers touchés : expander.adb, declarations, structures,
types_decls (un tag). Base = sources post-vague 3, syntaxe
`-gnats -gnat83` verte. **32 modifications, un seul commit.**

## Oracle et AVERTISSEMENT recensement

Diff FINC corpus attendu **vide** (else de dispatch, corps morts,
annotations, une scorie sans effet supprimée). MAIS : le TROU « épilogue
fonction d'instanciation » (MODIF 26, l'ex-« A VOIR ») **VA sonner au
recensement sur tout le pilier 3** — c'est voulu. « A VOIR » est un
verdict interdit par la définition de fini ; le bilan du recensement
doit forcer l'écriture de la VRAIE raison (résultat géré par le corps
partagé ?) et le reclassement INTENTIONNEL documenté AVANT la bascule
STRICT. Ne pas basculer STRICT avec ce TROU actif sous peine de casser
le filet génériques.

## Verdicts élucidés en session (au-delà du triage)

- **CODE_IMPLICIT_NOT_EQ → INTENTIONNEL** (le triage disait « à
  vérifier ») : le "/=" implicite est résolu AU SITE D'USAGE par symbole
  d'opérateur (égalités scalaires, BLKCMP D1, records 3.7 — quatre sites
  d'expressions le traitent). Rien à déclarer.
- **CODE_DERIVED_SUBPROG → TROU confirmé** : SUBPROGRAM_ORIGIN ne suit
  que les chaînes de RENAMES, pas la dérivation — un appel à un
  sous-programme dérivé viserait un label jamais émis. Sémantique réelle
  à instruire le jour où le recensement le montre vivant.
- **Scorie `if DN_FIXED then null` → MORT, supprimée** : aucun effet,
  les inits fixed passent le filet ; pas de TROU qui aurait sonné à tort
  sur tout le pilier F.
- **CODE_DEFERRED_CONSTANT_DECL → TROU** avec porte de sortie écrite :
  si le recensement montre que l'élaboration à la COMPLÉTION suffit
  (LRM 7.4), reclasser INTENTIONNEL avec cette raison.
- **CODE_RECORD_REP** : le commentaire du TROU précise que les clauses
  de COMPOSANTS sont, elles, traitées (represented_items, n° 117) — seul
  l'ALIGNEMENT était avalé. Évite un futur faux diagnostic.

## HORS LISTE (revue systématique, 7 dispatchers de plus que le §1c)

CODE_PARAM (chaîne in/out/in_out), CODE_EXP_DECL,
CODE_SIMPLE_RENAME_DECL (un renames de sous-programme/package passerait
là), CODE_NON_GENERIC_DECL, la chaîne FORMAL des actuels génériques
(sorte de formel non couverte), CODE_GENERIC_FRAME_OFFSETS (un formel
non couvert = slots non réservés = offsets GFP FAUX — de la famille
« programme faux qui tourne », pas n° 115), et structures:60 enrichi
(raise nu → TROU, le « modèle » du briefing mis au standard).

## Faux positifs fermés

Les quatre chaînes de types_decls signalées par le scanner (513, 529,
1195, 2048) sont des plieurs partiels à sémantique d'échec EXPLICITE
(OK := FALSE en aval) ou des gardes à return — pas des avaleurs. Le
when-others « borne réellement dynamique » reçoit son tag INTENTIONNEL
(critère grep du fini).

## Reste après vague 4 (pour la vague 5, dernière)

Les ~28 demi-bruyants §4 restants (moins l'ex-921 promu en vague 3),
les stubs « ANOMALIE » à re-taguer DEFAUT DOCUMENTE, CODE_CONVERSION
« cible non faite » (expressions ~6214), et les chantiers consignés :
factorisation SELARG/INDARG + normalisation indexés out/in-out,
l'observation « adresse seule vers formel in composite » (note vague 3),
TYPE_SIZE scalaire vs CD_IMPL_SIZE (avec test-miroir n° 110, à croiser
n° 117). Après vague 5 : vérification de la définition de fini complète
(greps + revue), run RECENSEMENT global, entrée PIEGES « discipline
TROU() » avec ses trois exemples d'avaleurs non-115 accumulés (boucle
infinie INC/DEC, offsets GFP faux, LI sans opérande).
