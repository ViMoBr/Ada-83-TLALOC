# ÉTAT DES PILIERS — tableau de bord TLALOC

**Dernière mise à jour : 5 juillet 2026** (clôture pilier 3.7, records à discriminants et variantes — lots R-A/R-B).
**Régime** : ce fichier est RÉÉCRIT à chaque clôture ; il est la seule source de
vérité sur « où on en est ». Le récit des sessions est dans JOURNAL_SESSIONS.md,
les pièges dans PIEGES.md, les conventions dans CONVENTIONS_ARCHITECTURE.md,
les sorties attendues dans ORACLES_TESTS.md, l'inventaire des nœuds dans
DIANA_COUVERTURE_TRIAGE.md.

## Méthode (arrêtée le 4 juillet 2026)

Le **LRM Ada 83** est la spécification et son ordre (types → objets → expressions
→ sous-programmes → packages → génériques → tâches) l'ordre de dépendances des
piliers. Le **réseau DIANA** est le contrat d'interface énumérable (triage).
L'**ACVC** est un filet de régression, pas une méthode de conception : ses échecs
informent la priorité des piliers, ils ne constituent pas la liste des tâches.
Deux disciplines : note de **modèle d'exécution** avant chaque nouveau pilier ;
**tri systématique** de chaque échec entre « défaut local d'un pilier existant »
(correction immédiate) et « manifestation d'un pilier absent » (consignation).
La sémantique n'est protégée que par les programmes-témoins à sortie attendue
(piège n° 51) : chaque clôture ajoute son oracle à ORACLES_TESTS.md.

## Piliers clos ou acquis

| Pilier (LRM) | État | Date / référence |
|---|---|---|
| 3.5.1–3.5.4 Scalaires : entiers, énumérés, sous-types | acquis | sessions ≤ avril |
| 3.5.7 Flottants (IEEE 754 double sur pile, SSE2) | acquis | 11 avril |
| 3.5.9 Points fixes | partiel : DURATION/CALENDAR OK ; mul/div générales incomplètes | 15 mai–5 juin |
| **3.6 Tableaux (formes contraintes, opérateurs complets)** | **CLOS** : affectation complète, égalité, ordre lexicographique, logiques booléens composites, caténation toutes formes, tranches (lecture/écriture/paramètre/retour), intervalles nuls, agrégats (positionnel/nommé/others/2D/qualifiés), conversions, attributs dimensionnés, 'RANGE (objet et marque de sous-type) | **5 juillet 2026** — oracles ARRAY_TEST1/2 |
| 3.6 reliquat non contraint | objets non contraints par agrégat (bornes
  déduites, trou n°3), attributs sur marque, STRING dynamique, formels/retours,
  conversion — ARRAY_TEST3 37/37 | clôture à prononcer après filet complet
  (ARRAY_TEST1/2, RECORD_TEST1/2, A2–A8, auto-compilation) + tag git |
| **3.7 Records à discriminants et variantes** | **CLOS** : discriminants (déclaration, contrainte, défauts, lecture, contrôle de flux), variantes statiques (layout ADDITIF), agrégats canoniques (positionnel/nommé/mixte/variantes/imbriqués), vues contraintes nommées et anonymes (objets, composants, éléments de tableau, formels, retours, qualifiés), égalité (BLKCMP sans variantes ; cascade statique à variantes), 'CONSTRAINED par objet, mutables, changement de variante | **5 juillet 2026** — oracles RECORD_TEST1/2 |
| 13 Clauses de représentation (records compacts) | acquis pour le type TREE du bootstrap | 21 juin |
| 3.8/4.8 Access minimal (`new`, `.all`) | minimal bootstrap | 22 juin |
| 5, 6 Instructions, sous-programmes, blocs | acquis (PRO/ELB/UNLINK, display, blocs declare) | ≤ avril + pièges 47–48 |
| 8.5 Renames d'objets | entamé (déclarations traitées) | 14 juin |
| 12 Génériques (packages, sous-programmes, thunks LD/ST CALLI) | acquis | avril + 4 juillet (piège 47) |
| 14.3 TEXT_IO | presque achevé (hors exceptions) ; GET scanners conformes ; FIXED_IO testé | 5 juin |
| 14.2.3 / 14.2.5 SEQUENTIAL_IO, DIRECT_IO | validés tous types | 10 mai |
| 9.6 CALENDAR | opérationnel (cas normaux) | 5 juin |

## Fondations absentes (piliers non ouverts)

| Pilier (LRM) | Manque | Note |
|---|---|---|
| 3.4 Dérivation | derived_def, derived_subprog | — |
| 11 Exceptions | handlers (squelette présent) | débloque les contrôles différés (CONSTRAINT_ERROR) |
| 8.x Portée, visibilité, use, renommage complet | causes-mères présumées des 4 échecs A8 | tri à faire avant d'ouvrir |
| 9 Tâches | tout | reporté |
| 12.1.3 Défauts de formels génériques | box/name/no_default | CALLI en place (TODO 5.3) |

## Dettes et restrictions consignées (n'empêchant pas les clôtures prononcées)

- **D5-complet** (3.6/4.6) : bornes du résultat de conversion = celles de la
  source ; faux si consommées directement. Re-étiquetage au sous-type cible à faire.
- **D6** (3.6) : bloc info anonyme câblé 1-dim (concat, agrégat dynamique,
  résultat de fonction). Le lot D3 l'a CONTOURNÉE en réutilisant l'info de
  l'opérande gauche — argument pour généraliser ce contournement.
- **D10** (4.1.4) : attributs à préfixe non nommé (tranche, indexé, appel) ;
  même famille : `return (S(2..3))`.
- **D3-contrôle** (4.5.1/11) : pas de contrôle `LEN_G = LEN_D` des logiques
  composites — CONSTRAINT_ERROR différé au pilier exceptions.
- **CODE_QUALIFIED** : records qualifiés (même vice que tableaux avant D9,
  pilier 3.7) ; branche non contrainte suppose une association nommée unique.
- **CODE_USED_NAME_ID** : retombée silencieuse à aligner sur le style bruyant
  (piège n° 53).
- **'IMAGE/'VALUE** d'énuméré hors générique → pilier 3.5.5.
- **A8** : 4 échecs consignés (renommage, use, portée, visibilité).
- **FIXED** : mul/div générales incomplètes (suffisantes pour DURATION).
- Mélange `and then`/`or` non parenthésé mal géré (TODO §5.2 historique).
- Généralisation LD/ST CALLI aux formels entiers/flottants (TODO §5.1 historique).

- **AGG-NC restrictions** (3.6, UNCONSTRAINED_AGGREGATE_OBJECT) : bornes
  déduites délibérément conservatrices — positionnel à cardinal statique, ou
  nommé à choix DN_NUMERIC_LITERAL (min/max calculés dans l'expander) ;
  multidim, choix dynamiques, mixte, `others` → refus bruyant. À élargir si
  un test ACVC l'exige.
- **DN_QUALIFIED à marque non contrainte** (COMPILE_ARRAY_VAR l. ~666) : même
  vice latent que l'ex-branche agrégat (COVAR_ALLOCATE sur SIZ = -1). Aucun
  témoin ne l'exerce ; le jour venu, router vers
  UNCONSTRAINED_AGGREGATE_OBJECT.
- **Marcheur `_aga`** : la retombée ADD_INDEX_DIMENSION sur index non
  contraint calcule des _FST/_LST faux (range du sous-type d'index) —
  INERTES pour l'émission des données (placement séquentiel par _PTR), mais
  non autoritaires : les bornes d'un agrégat ne font foi QUE publiées dans
  un descripteur. Ne pas « corriger » sans témoin, code partagé (D9, 2D,
  qualifiés).
## Prochaine séquence (à arbitrer à l'ouverture de la prochaine session)

1. **Pilier retenu : reliquat 3.6 — unconstrained arrays** (déclaration du
   type non contraint lui-même, CODE_UNCONSTRAINED_ARRAY_DECL, STRING
   général). Décidé le 5 juillet : coût faible, ferme la strate des types
   composites avant les exceptions (gros chantier, interaction frames).
   Exceptions (pilier 11) ensuite. Audit à l'ouverture : témoin
   auto-jugeant + dump `unconstrained_array_def` (protocole triage).
2. Rédiger la note de modèle d'exécution du pilier retenu AVANT de coder.
3. Filet complet + tag git à chaque clôture.

## Fichiers à uploader en début de session

Les 8 `expander*.adb`, `codi_x86_64.finc`, les paquetages IO concernés,
`machine_code.ads`, le programme de test en cours, et ce dossier documentaire.

## restrictions pilier 3.7 (périmètre 1)

- Égalité de records à variantes : champ par champ, variante active seule
  (RM 4.5.2), générée par cascade statique. Restent BRUYANTS : champ record
  à variantes imbriqué, champ tableau, choix par intervalle. Flottants
  comparés bit à bit (comme BLKCMP).
- Égalité : opérande agrégat non supporté (refus bruyant).
- Composants dépendant d'un discriminant : hors périmètre (garde
  SM_DEPENDS_ON_DSCRMT disponible, FALSE partout dans TEST1).
- Fonctions retournant un TABLEAU CONTRAINT : vigilance jumelle de C10, le
  slot résultat prend vraisemblablement le placeholder LI 0 — à traiter au
  pilier des retours de tableaux, pas exercé par le filet actuel.
- Catégorie E → couvert : dscrmt_decl, dscrmt_decl_s, dscrmt_constraint,
  variant_part, variant_s, comp_list (à sortir du triage DIANA).
- 'CONSTRAINED d'un formel de type mutable : approximation statique
  (TRUE exact si type sans défauts ; FALSE commenté dans le FINC sinon,
  la valeur exacte suit l'actuel — flag caché à l'appel, différé).
- Défauts de discriminants d'un COMPOSANT record à l'élaboration du parent
  (RM 3.2.1) : non émis, aucun témoin ne l'exerce.
- Déviation console : PUT d'énuméré avec WIDTH cadre à DROITE (blancs de
  tête, RM 14.3.9 prescrit blancs de queue) ; PUT vers chaîne conforme.
  À harmoniser au pilier 14.