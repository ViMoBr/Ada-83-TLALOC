# CHANTIER — clause d'adresse d'objet (`for X use at ADR`) — ouvert le 28/07/2026

Déclencheur : recensement de l'auto-compilation — TROU « rep-clause
'ADDRESS » vivant, par ex. univ_ops.adb :

    VDP : VECTOR_PAIRS;  for VDP use at V'ADDRESS;

## Nature du manque

C'est un OVERLAY d'objet (l'idiome Ada 83 de réinterprétation en place,
LRM 13.5). L'avaler n'est pas neutre : la déclaration de VDP a DÉJÀ
alloué son propre stockage (COMPILE_*_VAR est passé avant la clause),
donc tout accès à VDP lit/écrit un objet distinct de V — code faux qui
tourne, catégorie la plus sournoise du briefing. Le TROU doit rester
tant que ce n'est pas implanté ou contourné.

## Esquisse d'implantation (à instruire, PAS à coder sans témoin)

Le point dur est le modèle d'accès : une variable composite locale est
accédée par `LVA lvl, X_disp` — l'ADRESSE d'un emplacement alloué par
le cadre, pas une indirection. Un overlay exige que les accès à VDP
résolvent vers l'adresse de V. Trois voies :

1. **Indirection à la déclaration** (la plus locale) : au site de la
   clause, évaluer l'expression d'adresse (V'ADDRESS = data_ptr de V)
   et écraser le doublet de VDP : `VDP_disp := @data(V)` ;
   `VDP__u := use__info(VECTOR_PAIRS)`. NE FONCTIONNE que si TOUS les
   accès à VDP passent par le doublet (La du data_ptr) et jamais par
   `LVA lvl, VDP_disp` directement — à vérifier contre le modèle réel
   des accès composites (convention n° 112 : qui prend l'adresse du
   slot vs le contenu du slot ?). Si les scalaires sont aussi
   overlayables, la voie 1 ne couvre pas (accès scalaires par
   valeur directe dans le slot).
2. **Marquage front-end** (la plus propre) : un attribut CD sur l'objet
   (« aliased-at ») consulté par CODE_VC_NAME pour NE PAS allouer et par
   les chemins d'accès pour indirecter. Coût : toucher le front-end et
   tous les producteurs d'accès — gros.
3. **Contournement source** (la plus rapide pour le bootstrap) :
   réécrire les overlays des sources du compilateur en
   UNCHECKED_CONVERSION (déjà supporté, cf. TO_CHN) ou en accès
   explicites. À chiffrer : combien de sites 'ADDRESS vivants dans
   l'auto-compilation ? (le bilan recensement le donne gratuitement).

## Décision à prendre (mainteneur)

- Si les sites vivants sont peu nombreux et tous du motif
  « réinterprétation de tableau » : voie 3 débloque l'auto-compilation
  immédiatement, et le chantier d'implantation (voie 1 ou 2) reste au
  carnet avec ses témoins (un oracle overlay scalaire + un composite,
  méthodologie ORACLES_TESTS — jamais de rameau non exercé, n° 114/115).
- Sinon : instruire la voie 1 en commençant par l'audit du modèle
  d'accès composite (le dossier n° 112 fournit la carte).

## À consigner

- ETAT_PILIERS / carnet : ce chantier, avec le compte des sites vivants
  dès le prochain bilan complet.
- Croisements : n° 117 (famille rep-clauses), n° 112 (modèle d'accès),
  pilier 11 s'il existe des overlays sur objets à exceptions près (non).

## CLOS le 1er aout 2026 — voie retenue : DELEGATION A FASMG

Ni la voie 1 (indirection runtime), ni la voie 2 (marquage front-end),
ni la voie 3 (reecriture source) : **equation de symbole fasmg**
X_disp = Y_disp quand la sorte le permet, completee par deux formes
runtime (grille complete au piege n 124). La question ouverte du
dossier est TRANCHEE : les acces composites passent PARTOUT par le
CONTENU du slot (data_ptr) — l'indirection est native, aucun producteur
d'acces a toucher. sem posait DEJA SM_ADDRESS (dump TEST_ADDRESS).
Implantation : expander-declarations.adb seul, lots v2 → v2.4
(helper OVERLAY_TARGET + trois usagers). Temoin permanent : ADDR_OV1.
RESTES au carnet (TROU discrimines, cf. ORACLES « Temoins DUS ») :
clause de SOUS-PROGRAMME (16#...#, entree systeme — SM_ADDRESS pose
par sem, equation sur label de CALL envisageable, protocole d'appel a
instruire) ; adresse ABSOLUE d'objet (hors modele frame) ; mode OUT ;
scalaire-sur-composite ; equation cross-niveau ou cross-namespace.
