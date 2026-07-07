# Note de modèle d'exécution — Reliquat 3.6, tableaux non contraints (TLALOC)

**Rédigée le 5 juillet 2026, AVANT tout code** (discipline de pilier : représentation
mémoire + invariants pile/display + conventions d'appel, pour décider sciemment
extension vs refonte). Reconstituée par lecture de l'existant émis — descriptive
pour ce qui est câblé, prescriptive pour les trous marqués **[TROU]**.

---

## 1. Ce que « reliquat 3.6 » désigne réellement (après audit du code)

L'étiquette d'ETAT_PILIERS « CODE_UNCONSTRAINED_ARRAY_DECL absent, STRING général »
est **périmée**. Audit d'ouverture (grep + lecture) :

- `CODE_UNCONSTRAINED_ARRAY_DECL` **existe et est câblée** :
  `expander-declarations-types_decls.adb:341`, dispatchée depuis la ligne 44
  (`DN_ARRAY → CODE_UNCONSTRAINED_ARRAY_DECL`). Modèle DIANA confirmé :
  `DN_ARRAY` = non contraint (`array(T range <>)`), `DN_CONSTRAINED_ARRAY` = contraint.
- `COMPILE_ARRAY_VAR` (`expander-declarations.adb:529`) gère **déjà** :
  objet contraint anonyme d'un type non contraint (branche `SOURCE_CONSTRAINT`,
  génère un namespace `_<obj>__type` local via `PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC`,
  l.590-597), init par littéral chaîne (l.626), par appel de fonction retournant
  un doublet (l.642), par agrégat (l.658), par qualifié (l.666).

Le reliquat n'est donc pas « poser la fondation » mais **auditer sa complétude et
combler les trous résiduels**. Le témoin sert à mesurer, pas à ouvrir un vide.

---

## 2. Représentation mémoire

### 2.1 Le doublet objet (runtime, par objet tableau)

Tout objet tableau est un **doublet** de deux quadmots contigus dans le frame :

```
<obj>_disp : q    -- offset 0 : data_ptr  → adresse des composants (co-pile)
<obj>__u   : q    -- offset 8 : info_ptr  → adresse du bloc use__info du (sous-)type
```

Invariant confirmé (`COMPILE_ARRAY_VAR`, `CODE_SLICE`) : quand un tableau transite
par un **paramètre** ou un **retour de fonction**, c'est l'adresse du doublet qui
circule ; `data_ptr` est à l'offset 0, `info_ptr` à l'offset ADDR_SIZE (=8).
Un paramètre lit ses bornes via `-<p>_ofs` puis `LIa ,,8` pour atteindre info_ptr.

### 2.2 Le bloc `use__info` (statique, par TYPE — émis par CODE_UNCONSTRAINED_ARRAY_DECL)

Pour un type non contraint, `CODE_UNCONSTRAINED_ARRAY_DECL` émet un `namespace`
contenant le doublet de tête + un `virtual at 4` déroulant les offsets :

```
namespace _<TYPE>
  VAR use__info, q
  VAR SIZ, d
        LVA  L, SIZ        \
        Sa   L, use__info   > use__info pointe sur lui-même (auto-référence)
        LI   1              |
        NEG                 |
        Sd   L, SIZ         /  SIZ := -1  → MARQUEUR « NON CONTRAINT »
  virtual at 4              -- offsets des champs du descripteur d'un objet CONTRAINT
    SIZ_n / FST_n / LST_n   -- une dimension intermédiaire (récursif, n = numéro dim)
    ...
    COMP_SIZ / FST_1 / LST_1 -- dimension finale : taille composant + bornes dim 1
  end virtual
end namespace
```

Point clé : **`SIZ = -1` est le témoin runtime du caractère non contraint**. Un
objet contraint (sous-type) porte un `SIZ ≥ 0` réel (taille totale en bits),
posé par `PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC`. Le `virtual at 4` n'alloue rien :
il **nomme les offsets** dans le descripteur runtime que chaque objet contraint
remplira (SIZ_n/FST_n/LST_n par dimension, COMP_SIZ pour le pas d'indexation).

### 2.3 Descripteur runtime d'un objet contraint

Quand un objet est contraint (`V : VECTEUR(1..5)` ou `subtype`), les offsets du
`virtual` du type de base sont matérialisés en mémoire : SIZ (taille réelle),
puis par dimension FST/LST/SIZ, COMP_SIZ. `info_ptr` de l'objet pointe dessus.
C'est ce descripteur que lisent `'FIRST/'LAST/'LENGTH/'RANGE` et l'indexation.

---

## 3. Invariants pile / display

- Convention des expressions tableau : une expression tableau **laisse l'adresse
  du doublet** en sommet de pile (cf. CODE_QUALIFIED, agrégat dynamique, retour
  de tranche). Le consommateur (affectation, paramètre, concat) lit offset 0/8.
- Allocation des data : `CO_VAR` sur la **co-pile** (pile secondaire de données
  de taille dynamique), taille = `SIZ/STORAGE_UNIT`. Ne touche pas au display.
- `COMP_SIZE_BITS` arrondit au STORAGE_UNIT (piège n°10, cause des « six VRAI » du
  lot D3 : BOOLEAN 1 bit → stride 0). À réutiliser tel quel pour tout composant.

---

## 4. Conventions d'appel (paramètres/retours non contraints)

- **Paramètre formel non contraint** (`T : VECTEUR`, `S : STRING`) : reçoit
  l'adresse du doublet de l'actuel. Bornes lues dynamiquement via info_ptr.
  Confirmé fonctionnel (SOMME/AFFICHE d'array_test1, MILIEU d'array_test2).
- **Retour de type non contraint** (`return STRING`) : la fonction construit un
  doublet (data sur co-pile de l'appelé, promue), renvoie son adresse. Le site
  d'appel lit offset 0/8 (`COMPILE_ARRAY_VAR` l.642-655 pour l'init d'objet ;
  MILIEU prouve le retour de tranche). **[TROU probable]** : retour STRING de
  longueur *calculée* (non-tranche, p. ex. concaténation construite dans le corps)
  — dette D6 (bloc info anonyme câblé 1-dim) susceptible de mordre ici.

---

## 5. Trous résiduels à cibler par le témoin (array_test3)

Classés par certitude décroissante d'être de vrais trous :

1. **[TROU]** `'FIRST/'LAST/'LENGTH/'RANGE(N)` de préfixe = **marque de sous-type
   non contraint** (pas objet). Le code d'attribut (`expander-expressions.adb`)
   privilégie `DN_CONSTRAINED_ARRAY` + objet ; le chemin marque non contrainte
   pure est à vérifier. Parent de la dette D9 `VEC3'RANGE` (corrigée pour
   contraint ; non contraint = ?).
2. **[TROU]** Type non contraint à **composant non scalaire** (array of record,
   array of array). `COMP_SIZE_BITS` gère DN_RECORD/DN_CONSTRAINED_RECORD et
   DN_ACCESS/DN_FLOAT ; composant array non contraint = illégal en Ada, mais
   array of *constrained* array est légal et non testé.
3. **[TROU]** Objet non contraint dont les **bornes viennent d'un agrégat sans
   contrainte explicite** (`V : VECTEUR := (1,2,3)`) : branche DN_AGGREGATE de
   COMPILE_ARRAY_VAR appelle COVAR_ALLOCATE qui lit `.SIZ` du type — or `.SIZ=-1`
   pour un non contraint ! Allocation de -1/8 octets. **Fort soupçon de bug.**
4. **[TROU]** Idem bornes déduites d'une **valeur d'init** (`V : VECTEUR := F(x)`)
   et d'un **littéral chaîne** vers objet non contraint (`S : STRING := "abc"`) :
   même question — COVAR_ALLOCATE vs SIZ=-1.
5. **STRING général** : sous-types dynamiques `STRING(1..N)` avec N variable
   (partiellement couvert par S0/SD d'array_test2, à consolider auto-jugeant).
6. Dette **D6** (bloc info anonyme 1-dim) : à réexaminer sur non contraint 2D.
7. Dette **D5-complet** : re-étiquetage bornes au sous-type cible de conversion.

Le trou n°3 (COVAR_ALLOCATE lisant SIZ=-1) est la découverte de l'audit et
justifie à lui seul le témoin : c'est exactement le genre de « fondation câblée
mais jamais exercée » que le protocole cherche à débusquer.

---

## 6. Décision extension vs refonte

**Extension**, pas refonte. Le modèle mémoire (doublet + use__info + SIZ marqueur)
est cohérent et déjà partagé par contraint/non contraint, paramètres, retours,
agrégats qualifiés. Les trous sont des **branches manquantes ou non exercées**
(notamment l'allocation d'un objet non contraint à bornes déduites), pas un défaut
de représentation. Aucun invariant pile/display n'est remis en cause.
