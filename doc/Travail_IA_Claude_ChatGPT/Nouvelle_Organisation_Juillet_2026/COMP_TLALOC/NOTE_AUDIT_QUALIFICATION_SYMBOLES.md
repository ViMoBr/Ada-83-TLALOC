# NOTE — Audit de la qualification des symboles d'objets (`_disp`, `__u`, `__dat`)

Session du 12 juillet 2026. Campagne fasmg ADA_COMP. Sœur de
NOTE_AUDIT_COMPOSANTS_REPRESENTES.md.

## Contexte et règle

Dans le FINC, un nom nu n'est résolu par fasmg que dans le **namespace
courant**. Les symboles d'objets (`X_disp`, `X__u`, `X__dat`) vivent dans
le namespace de leur région déclarante : toute référence depuis une autre
région doit être qualifiée par `REGIONS_PATH`. Le niveau du L/S règle le
frame, jamais la visibilité (règle n° 100 de CONVENTIONS).

**Danger spécifique de cette famille** : contrairement au chantier des
records représentés (où aucun symbole de composant n'existe et où fasmg
échoue toujours bruyamment), un nom nu peut ici se **lier silencieusement
à un homonyme local** — par exemple une référence par nom étendu `P.X`
depuis un sous-programme possédant sa propre locale `X`. Code faux sans
erreur d'assemblage. C'est le seul chantier de la campagne à mode de
défaillance potentiellement muet : le balayage proactif n'est pas du
confort, c'est de la correction.

## Le porteur unique

L'idiome correct existe dans `LOAD_MEM` (utils, branche variable,
~455-480) : qualification conditionnelle. À extraire dans utils et à
utiliser partout :

    procedure PUT_OBJ_SYMBOL ( DEFN : TREE;  SUFFIX : STRING ) is
        -- Reference a un symbole d'objet : qualifiee par sa region si
        -- l'objet n'est pas local au sous-programme courant (idiome
        -- LOAD_MEM, n 100). Nom nu = namespace courant seulement.
      DEFN_LVL : INTEGER := DI( CD_LEVEL, DEFN );
    begin
      if  DEFN_LVL /= INTEGER( CUR_LEVEL )
      or else  D( XD_REGION, DEFN ).TY = DN_PACKAGE_ID
      then
        REGIONS_PATH( DEFN );
      end if;
      PUT( PRINT_NAME( D( LX_SYMREP, DEFN ) ) & SUFFIX );
    end PUT_OBJ_SYMBOL;

Préférer cet idiome conditionnel au chemin absolu inconditionnel : sur
une locale de sous-programme, il évite de parier sur l'adressabilité du
namespace `nom_Ln` depuis l'intérieur.

## Règle de tri (provenance du nom)

Un site est à convertir si et seulement si la chaîne de nom dérive d'un
**DEFN utilisateur** (`PRINT_NAME( LX_SYMREP, <SM_DEFN...> )`). Elle est
nue à bon droit si elle dérive de :

- `ANON*` / `ANONYMOUS_STR` / `ANON_R/G/D` / `"_aga"` — temporaires de
  générateurs, déclarés au point d'usage ;
- `ITERATION_ID_STR & LABEL_STR(...)` — variables d'itération étiquetées ;
- `EQA_/EQB_ & EQ_UID` — temporaires d'égalité ;
- `"VAR " & ...` — sites de **déclaration** (définitions, nues par
  nature), y compris l'élaboration immédiate qui suit dans le même
  namespace (tout COMPILE_*_VAR) ;
- `'-' & ... & "_ofs"` — paramètres, PRMzone du namespace courant ;
- chemins déjà absolus (`STANDARD.EXCEPTIONS_*`).

NB : les ancres ci-dessous réfèrent au **snapshot du dépôt projet**,
antérieur au balayage manuel du 12/07 — certains sites [P] sont déjà
convertis localement et les numéros de ligne ont dérivé. Ancrer par
procédure englobante et forme émise, pas par numéro seul.

## Inventaire

### expander-utils.adb — le cœur

| Ancre | Forme émise | Cat. | Traitement |
|---|---|---|---|
| STORE, ~519-521 | `S<c> lvl, DEFN_disp` | **P** | **Patché le 12/07** (miroir de l'idiome LOAD_MEM). Point central : sert toutes les affectations scalaires. |
| STORE, ~516-517 | `SI<c> lvl, -DEFN_ofs` | I | Paramètre OUT/IN OUT : namespace courant. |
| LOAD_MEM, ~455-480 | `L<c>/LVA lvl, [path]DEFN_disp` | Q | Porte déjà l'idiome — c'est le modèle. Convertir vers PUT_OBJ_SYMBOL pour n'avoir qu'une copie (n° 94). |
| ~442-444, ~464, ~477 | variantes LOAD | V | Vérifier : mêmes branches de LOAD_MEM ou copies ? Si copies, convertir. |
| ~613-615 | `STANDARD.EXCEPTIONS_TOP_CTX_disp` | I | Déjà absolu. |

### expander-instructions.adb

| Ancre | Forme émise | Cat. | Traitement |
|---|---|---|---|
| ~655-657, actuels composites | `LVA lvl, [REGIONS_PATH]DEFN_disp` | Q | Déjà qualifié. |
| ~676-678, actuels VARIABLE_ID (2 branches jumelles identiques) | `LVA lvl, DEFN_disp` **nu** | **P** | PUT_OBJ_SYMBOL. Noter l'asymétrie avec 655-657 juste au-dessus. Fusionner les deux branches identiques au passage. |
| ~1690, MANAGE_RENAMES | `SI<c> lvl, DEFN_disp, 0` **nu** | **P** | PUT_OBJ_SYMBOL — un renames de niveau package s'écrit depuis n'importe où. |
| ~297, ~750 | ITERATION_ID + LABEL | I | — |
| ~611-626, ~794-810 | ANON/ANONYMOUS_STR (actuels agrégats) | I | — |
| ~488-501 | EXCEPTIONS_CURRENT (absolu) | I | — |
| ~1775 | commenté | I | — |

### expander-expressions.adb

| Ancre | Forme émise | Cat. | Traitement |
|---|---|---|---|
| INDEX, ~750/769/792/825 | `LId lvl, ARRAY_NAME__u, <path>` base **nue** | **P** | Convertis à la main le 12/07 — vérifier que les QUATRE le sont, puis basculer sur PUT_OBJ_SYMBOL( ARRAY_DEFN, "__u" ). |
| INDEX, ~858 | `La lvl, ARRAY_NAME_disp` **nu** | **P** | Converti le 12/07 (site CUR_VP/N_SPEC) — basculer sur le porteur. |
| Slices, ~958/974 | `La/LId lvl, DEFN_STR _disp/__u` **nus** | **P** | Même traitement — c'est le jumeau slice de l'INDEX. |
| PROCESS_DESIGNATOR, ~1084-1086 | `La lvl, [REGIONS_PATH]DESIGNATOR_disp` | Q | Déjà qualifié. |
| PROCESS_DESIGNATOR, ~1105-1108 | `La lvl, NAME_disp` **nu** (record autonome) | **P** | PUT_OBJ_SYMBOL( D(SM_DEFN,NAME), "_disp" ). |
| PROCESS_DESIGNATOR, ~1155 | base `NAME_disp` **nue** du L<c> composant | **P** | Idem. |
| CODE_OBJECT_ADDRESS?, ~1259/1279/1281 | `La/LVa lvl, DEFN_disp` **nus** (renames construit + variable autonome) | **P** | PUT_OBJ_SYMBOL. Le cas renames est le plus exposé (slot souvent de niveau package). |
| Attributs tableau, ~2016-2018, ~2341-2349 | `LId lvl, [REGIONS_PATH]CHN_PREFIX__u` | Q | Déjà qualifiés. |
| RANGE_ATTRIBUTE, ~6461-6463 | `LId lvl, PREFIX_STR__u,` base **nue** (le déplacement est qualifié, pas la base) | **P** | PUT_OBJ_SYMBOL( PREFIX_DEFN, "__u" ). |
| Attributs, ~6276-6301 | cluster préfixe objet | V | Vérifier la base __u/_disp comme 6461. |
| ~309-312 | itération | I | — |
| ~1012-1039 | ANON_NAME slice anonyme | I | — |
| ~2177-2203 | commenté (INTEGER_IMAGE) | I | — |
| ~2827-2987, ~3136-3189, ~3625-3730 | ANON concat/agrégats/opérateurs composites | I | — |
| ~3876-3957 | ANON doublet résultat de fonction | I | — |
| ~5931-5997, ~6068-6190 | ANON (agrégats, attributs image) | I | — |

### expander-declarations.adb

Quasi-intégralité des ~45 hits : **[D]** — sites de déclaration
(`VAR X_disp`) et élaboration immédiate dans le même namespace
(COMPILE_SCALAR/ARRAY/RECORD_VAR, ~369-1010 ; slots de renames
~1234-1295 ; formels génériques ~1582-1597, ~1757-1759 ; GFP ~1889).
Rien à faire. Les sites ~1080/1126-1140 relèvent de l'autre note
(composants représentés).

## Bilan

Un point central (STORE, patché), sept sites [P] actifs hors
conversions déjà faites (instructions 676/678 et 1690 ; expressions
958/974, 1105-1108, 1155, 1259-1281, 6461-6463), deux clusters [V] à
vérifier (utils 442-477, expressions 6276-6301), tout le reste nu à bon
droit ou déjà qualifié.

## Règle d'audit permanente

Après conversion : dans expressions/instructions/utils, toute
concaténation `PRINT_NAME( ... ) & "_disp"/"__u"/"__dat"` qui n'est ni
précédée de `REGIONS_PATH`/`PUT_OBJ_SYMBOL` à moins de trois lignes, ni
dérivée d'un préfixe généré (ANON, ITERATION, EQ_UID), ni un site
`VAR `, est un bug en attente. Le grep de signature :

    grep -n -B3 '& "_disp"\|& "__u"\|& "__dat"' expander-*.adb

redevient alors un outil de contrôle. Candidate PIEGES : *la
qualification d'un symbole d'objet vit en UNE procédure
(PUT_OBJ_SYMBOL) ; le mode de défaillance d'un nom nu peut être MUET
(liaison homonyme) — seul chantier de la campagne où fasmg n'est pas un
auditeur exhaustif.*

## Vérifications de clôture

1. Reconstruire, régénérer, et relire dans IDL-IDL_MAN.FINC le site
   DABS : `Sw` désormais qualifié `STANDARD.IDL.PAGE_MAN.CUR_VP_disp`.
2. Contrôler les quatre conversions manuelles du 12/07 (INDEX) et les
   basculer sur le porteur — quatre copies de l'idiome redeviendraient
   le n° 94.
3. Test dirigé homonyme : une procédure avec locale `X` affectant
   `P.X` de son package — le FINC doit montrer deux symboles distincts.
4. Grep de contrôle final : zéro hit non classé par cette note.
