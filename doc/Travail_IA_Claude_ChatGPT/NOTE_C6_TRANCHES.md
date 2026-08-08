# NOTE C6 — TRANCHES À PRÉFIXE INDEXÉ ET DÉRÉFÉRENCÉ (instruction avant code)

Prescription du bilan : instruire contre le modèle d'adressage n° 112 AVANT
de coder.  Cette note est le livrable de l'étape — AUCUN code tant qu'elle
n'est pas validée (précédent : NOTE_MODELE de C7).  30/07/2026.

## 1. Réalité corpus (3 traversées)

- expander-utils.adb:795 — `GA_NAME( GA_COUNT )( 1 .. FORMAL_NAME'LENGTH )
  := FORMAL_NAME;` : tranche DESTINATION, préfixe INDEXÉ, composant =
  STRING contraint (bornes statiques, FST = 1).
- expander-utils.adb:810 — `GA_NAME( I )( 1 .. GA_LEN( I ) ) = FORMAL_NAME`
  : tranche SOURCE (opérande d'égalité), même préfixe.
- idl.adb — 1 traversée DN_ALL : tranche sur déréférence `P.all(A..B)`.
  À LOCALISER précisément (grep `.all(` ou `.ALL (` dans idl.adb) — voir Q1c.

## 2. Vérités terrain établies (lecture des sources, 30/07)

- **CODE_OBJECT_ADDRESS** possède DÉJÀ les bras nécessaires :
  `when DN_INDEXED => CODE_INDEXED( NAME );` (référence de composant :
  @data nue, conforme n° 112) et `when DN_ALL => CODE_EXP( AS_NAME )`
  (valeur d'accès, commentée « valeur access = @objet designe »).
- **L'allocateur qualifié** : `HEAP_ALLOC` de `<DESIG>.size`, résultat
  conservé dans `VAR ANON_ptr, q` BRUT — AUCUN doublet construit.  La
  valeur d'accès composite est donc un **@data nu** ; les bornes d'un
  désigné CONTRAINT sont celles du TYPE (bloc info statique), pas d'un
  __u d'objet.
- **Conséquence architecturale** : le rameau « paramètre composite » de
  CODE_SLICE (slot → @doublet → LIa 0 / LIa 8) ne s'applique PAS au
  DN_ALL.  Les deux formes nouvelles partagent UN SEUL idiome :

      @data(préfixe)  = CODE_OBJECT_ADDRESS( NAME )      -- la règle, déjà là
      FST_1(préfixe)  = lecture STATIQUE du bloc info du type préfixe
                        (PREFIX_ARRAY_TYPE = SM_EXP_TYPE( NAME ))

  puis la mécanique commune inchangée : LOW ; FST_1 ; SUB ; LI comp ;
  MUL ; ADD — et les modes destination/source existants.

## 3. Implantation proposée (après validation)

Dans CODE_SLICE, ajouter UN elsif avant le TROU :

    elsif  NAME.TY = DN_INDEXED  or else  NAME.TY = DN_ALL  then
      CODE_OBJECT_ADDRESS( NAME );                -- @data du préfixe (règle)
      CODE_EXP( AS_EXP1( range ) );               -- LOW
      <lecture statique _FST_1 du type préfixe>   -- cf. Q2
      SUB ; LI comp_size/8 ; MUL ; ADD

Le TROU reste en queue (formes restantes : préfixe DN_SLICE de tranche,
fonction — zéro traversée, n° 122).  Une modification, les deux formes.

## 4. Témoin SLICE1 (plan — écrit après validation de la note)

    type ROW  is array ( 1 .. 3 ) of STRING( 1 .. 8 );
    type VEC  is array ( 1 .. 6 ) of INTEGER;
    type PVEC is access VEC;

- S1 indexé : GA : ROW ; GA(2)(2..4) := "xyz" (destination) ; égalité
  GA(2)(2..4) = "xyz" (source) ; bornes pleines (1..8) ; sous-tranche au
  bord (7..8) ; les composants voisins GA(1)/GA(3) INTACTS après écriture
  (le risque « adresse de base » du bilan).
- S2 déréférence : P := new VEC'(10,20,30,40,50,60) ; lecture par tranche
  source (somme de P.all(2..4) via boucle sur copie) ; écriture
  destination P.all(5..6) := ... via agrégat/objet ; P.all(1) et P.all(4)
  intacts.
- Attendu recensement : 2 formes × leurs sites ≈ 5-6 traversées
  « CODE_SLICE forme de nom » (2 × DN_INDEXED min., 2 × DN_ALL min.),
  compte exact au premier run.

## 5. Questions à trancher AVANT le code (validation de la note)

- **Q1a** — Contresigner : valeur d'accès composite = @data nu (lecture
  allocateur ci-dessus).  Un fragment FINC d'un `new` + déréférence
  d'idl.adb suffit.
- **Q1b** — Le site DN_ALL d'idl.adb tranche-t-il un désigné CONTRAINT ?
  (Si non contraint : bornes portées par l'objet au tas — AUTRE modèle,
  non couvert par cette note, à instruire séparément.)
- **Q1c** — Localiser le site (fichier:ligne) et le joindre à la note
  validée.
- **Q2** — Nom/chemin EXACT de la lecture statique de la première borne :
  le FINC montre `VAR _FST_1, d` dans le namespace du type (souligné),
  mais les lectures par pointeur du rameau paramètre impriment `.FST_1`
  (sans souligné).  Lever l'ambiguïté sur un FINC existant de
  tranche-sur-paramètre (le corpus en a depuis vague ≤ 4) : quelle
  chaîne exacte pour `Ld <lvl>, <path>._<TYPE>.?FST_1` en statique ?
- **Q3** — Contresigner que CODE_INDEXED sur composant COMPOSITE laisse
  bien @data nue (n° 112) : un FINC de `GA_NAME( I )` hors tranche, ou
  lecture de la queue de CODE_INDEXED.

## 6. Oracles du chantier (une fois codé)

1. Témoin : traversées attendues au recensement (commit A), puis
   « SLICE1 PASSE » + intacts des voisins (commit B).
2. Compteur : 16 → 13, famille « CODE_SLICE forme de nom » ABSENTE.
3. Diff FINC corpus : le calcul d'adresse APPARAÎT aux 3 sites (utils
   795/810, idl.adb) — chacun était « adresse de base absente »,
   défaillance à l'usage, à consigner au journal.
4. Filet + les six témoins ; ligne C6 du BILAN → SOLDÉ ; tag.
