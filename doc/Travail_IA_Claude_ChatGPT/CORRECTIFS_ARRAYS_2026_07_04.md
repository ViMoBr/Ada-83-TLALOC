# Correctifs pilier 3.6 — verdict d'ARRAY_TEST1 (4 juillet 2026)

## Diagnostic

ARRAY_TEST1 a joué son rôle de calibrage. Trois écarts, triés selon la discipline convenue :

1. **`M'LENGTH(2)` rend 3 au lieu de 2** — défaut local. `CODE_LENGTH`
   (expander-expressions.adb, l. 1874) : le chemin access-to-array lit `DIM_EXP`, mais les
   deux chemins principaux (paramètre l. 1948/1951, variable l. 1960/1966) câblent
   `LST_1`/`FST_1`. → **Patch A**.
2. **`C2 := "GHIJKL"` et `C3 := C1 & C2` sont des no-ops silencieux** — branche inachevée.
   Dans `CODE_ASSIGN` (expander-instructions.adb, branche « OBJET ASSIGNE TABLEAU ») :
   seul le chemin agrégat est terminé ; le chemin `DN_USED_OBJECT_ID` empile
   @DST puis deux fois @SRC sans BLKMOV ; le chemin `else` empile @doublet_src sans copie ;
   et pour un littéral chaîne, `CODE_EXP` n'empile rien du tout (`CODE_STRING_LITERAL`
   n'émet que la directive `STR`). → **Patch B**.
3. **`JOUR'IMAGE(MARDI)` imprime `1`** — pilier absent (LRM 3.5.5 : table IMAGES des
   énumérés hors instanciation générique). **Consigné, pas de rustine** : à traiter avec
   le patron de type des énumérés (la table IMAGES existe déjà côté ENUMERATION_IO,
   il manque son émission pour tout type énuméré référencé par 'IMAGE/'VALUE hors générique).

**Constat de méthode (à verser à la synthèse)** : les tests ACVC de classe **A** sont des
oracles de compilation-exécution, pas de valeurs — une affectation no-op les laisse
« passer » (c'est ainsi qu'A21001A cohabitait avec le bug 2). La sémantique des valeurs
n'est protégée que par les programmes-témoins et, plus tard, les séries C.

---

## Patch A — CODE_LENGTH : honorer la dimension (expander-expressions.adb)

Dans le bloc `declare` de la fin de `CODE_LENGTH` (l. ~1940), ajouter la lecture de la
dimension :

```ada
      declare
        ARRAY_LVL		: INTEGER		:= DI( CD_LEVEL, PREFIX_DEFN );
        PREFIX_TYPE_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, PREFIX_TYPE ) ) );
        DIM_EXP		: TREE		:= D( AS_EXP, ATTRIBUTE );
        NUM_DIM		: INTEGER		:= 1;
      begin
        if  DIM_EXP /= TREE_VOID  then
          NUM_DIM := DI( SM_VALUE, DIM_EXP );
        end if;
```

puis remplacer les quatre suffixes câblés :

| Ligne | Avant | Après |
|---|---|---|
| 1948 | `& ".LST_1");` | `& ".LST_" & IMAGE( NUM_DIM ) );` |
| 1951 | `& ".FST_1");` | `& ".FST_" & IMAGE( NUM_DIM ) );` |
| 1960 | `( PREFIX_TYPE_STR & ".LST_1" );` | `( PREFIX_TYPE_STR & ".LST_" & IMAGE( NUM_DIM ) );` |
| 1966 | `( PREFIX_TYPE_STR & ".FST_1" );` | `( PREFIX_TYPE_STR & ".FST_" & IMAGE( NUM_DIM ) );` |

Note LRM : `P'LENGTH(N)` exige N statique positif ≤ dimensionnalité (annexe A) — `SM_VALUE`
suffit donc, comme dans FIRST/LAST.

---

## Patch B — CODE_ASSIGN : terminer l'affectation complète de tableau
(expander-instructions.adb, branche « OBJET ASSIGNE TABLEAU », l. ~1583)

**Remplacer intégralement :**

```ada
	elsif  NAME_TYPE.TY = DN_ARRAY  or  NAME_TYPE.TY = DN_CONSTRAINED_ARRAY  then			-- OBJET ASSIGNE TABLEAU
	  CODE_OBJECT( DEFN );
	  if  SRC_EXP.TY = DN_USED_OBJECT_ID  then
	    CODE_OBJECT( D( SM_DEFN, SRC_EXP ) );
	    CODE_OBJECT( SRC_EXP );

	  elsif  SRC_EXP.TY = DN_AGGREGATE  then
	    EXPRESSIONS.CODE_AGGREGATE( SRC_EXP, NAME_TYPE );

	  else
	    EXPRESSIONS.CODE_EXP( SRC_EXP );
            end if;
```

**par :**

```ada
	elsif  NAME_TYPE.TY = DN_ARRAY  or  NAME_TYPE.TY = DN_CONSTRAINED_ARRAY  then			-- OBJET ASSIGNE TABLEAU

	  if  SRC_EXP.TY = DN_AGGREGATE  then
	    CODE_OBJECT( DEFN );									-- @DST (data) — chemin valide, inchange
	    EXPRESSIONS.CODE_AGGREGATE( SRC_EXP, NAME_TYPE );

	  else
	    -- Convention BLKMOV : pile = @DST, LEN, @SRC.
	    CODI.LOAD_MEM( DEFN );									-- @doublet destination (variable ou parametre)
	    PUT_LINE( tab & "La" );									-- @DST = data_ptr (offset 0 du doublet)

	    -- LEN (octets) lu dynamiquement dans le descripteur de la DESTINATION :
	    -- SIZ (bits, dword a l'offset 0 du bloc info) / STORAGE_UNIT.
	    -- Robuste pour les sous-types anonymes (STRING(1..6)) et les parametres,
	    -- la ou un `_TYPE.size` statique remonterait au type de base non contraint
	    -- via XD_SOURCE_NAME (meme famille que le piege n° 46).
	    -- ; CHK: egalite des longueurs source/destination (pilier exceptions)
	    if  DEFN.TY in CLASS_PARAM_NAME  then							-- idiome CODE_LENGTH, chemin parametre
	      PUT_LINE( tab & "LVA" & tab & IMAGE( DI( CD_LEVEL, DEFN ) )
			& ", -" & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_ofs" );
	      PUT_LINE( tab & "LIa" & tab & ", ," & INTEGER'IMAGE( CODI.ADDR_SIZE ) );		-- @info
	      PUT_LINE( tab & "Ld" & tab & ", 0" );						-- SIZ (bits)
	    else											-- idiome CODE_LENGTH, chemin variable
	      PUT( tab & "LId" & tab & IMAGE( DI( CD_LEVEL, DEFN ) ) & ", " );
	      CODI.REGIONS_PATH( DEFN );
	      PUT_LINE( PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "__u, 0" );				-- SIZ (bits)
	    end if;
	    PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
	    PUT_LINE( tab & "DIV" );									-- LEN en octets

	    if  SRC_EXP.TY = DN_STRING_LITERAL  then
	      EXPRESSIONS.CODE_STRING_LITERAL( SRC_EXP, EXPRESSIONS.ANONYMOUS_NAME_AT( SRC_EXP ) );
	      PUT_LINE( tab & "LCA" & tab
			& EXPRESSIONS.ANONYMOUS_NAME_AT( SRC_EXP ) & ".data_ptr" );			-- @SRC (idiome concat, l. 2550)

	    elsif  SRC_EXP.TY = DN_SLICE  then
	      EXPRESSIONS.CODE_SLICE( SRC_EXP, IS_DESTINATION => TRUE );				-- @src, len_src
	      PUT_LINE( tab & "DROP" );								-- longueur = celle de la destination

	    else
	      EXPRESSIONS.CODE_EXP( SRC_EXP );							-- @doublet (variable, concat, appel de fonction, qualifie)
	      PUT_LINE( tab & "La" );								-- @SRC = data_ptr
	    end if;

	    PUT_LINE( tab & "BLKMOV" );
	  end if;
```

### Points de vigilance du patch B

- **Visibilité** : `CODE_STRING_LITERAL` et `ANONYMOUS_NAME_AT` doivent être exportés par
  le spec du package EXPRESSIONS s'ils ne le sont pas déjà (à vérifier dans expander.adb).
- **`Ld , 0` / `LId …, 0`** : offset numérique — accepté par les macros (précédent :
  `SI… _disp, 0` dans MANAGE_RENAMES).
- **`DIV` par 8** : SIZ est toujours multiple de STORAGE_UNIT (STATOFS arrondit à l'octet,
  piège n° 10) — pas de troncature.
- L'ancienne branche laissait 1 à 3 valeurs orphelines sur la pile d'opérandes ; la
  nouvelle est équilibrée.
- Cas non couverts, consignés : destination composant de record (`R.T := …`, message
  `!!! ASSIGN DST COMPONENT_ID` déjà présent côté record), destination renommée composite
  (MANAGE_RENAMES ne retourne que pour les scalaires).

---

## Validation

1. Recompiler l'expander ; repasser **ARRAY_TEST1 v2** (ci-joint : section 3 ré-armée avec
   des bornes distinctes par dimension `array(1..3, 4..5)` — le `'FIRST(2)=1` de la v1
   était juste par coïncidence ; section 9 restreinte à INTEGER'IMAGE, JOUR'IMAGE consigné).
   Attendu : tout vert.
2. Filet complet : séries ACVC A2–A7 + 16/20 A8 + IO_TEST + FLOAT_TEST + ENUM_TEST +
   DIRECT_IO_TEST 1-2 + SEQ_IO + auto-compilation des modules. Attention particulière :
   le patch B change le code émis pour toute affectation `tableau := variable` existante
   (l'ancien chemin, quoique faux, était peut-être compensé quelque part — un échec ici
   serait instructif).
3. Vérifier dans le FINC d'ARRAY_TEST1 que `C3 := C1 & C2` émet bien
   `LId …C3__u, 0 / LI 8 / DIV / … / BLKMOV`.

## Entrées proposées pour la liste des pièges (synthèse §8)

49. **`CODE_LENGTH` et attributs dimensionnés** : tout nouveau chemin d'attribut de
    tableau doit lire `AS_EXP` (la dimension) ; trois chemins sur quatre le faisaient,
    le quatrième câblait `_1`. (session 4 juillet, ARRAY_TEST1)
50. **Affectation complète `tableau := expression`** : la longueur BLKMOV doit venir du
    descripteur **de la destination** (`[__u].SIZ/8`, dynamique), jamais de
    `XD_SOURCE_NAME → _TYPE.size` qui remonte au type de base non contraint pour les
    sous-types anonymes — même famille que le piège 46. Un littéral chaîne en source
    n'empile rien via CODE_EXP : passer par `STR` + `LCA .data_ptr`. (session 4 juillet)
51. **Classes ACVC** : les tests **A** valident compilation + exécution sans erreur, pas
    les valeurs. Une génération muette (branche inachevée) peut les laisser verts.
    La sémantique est protégée par les programmes-témoins et les séries C.
    (session 4 juillet)

## Reclassement

- `'IMAGE`/`'VALUE` d'énuméré hors générique → dette LRM 3.5.5 (pilier « scalaires »,
  petite : réutiliser le bloc IMAGES de BEGIN_BLOC_DEF/END_BLOC_DEF émis pour
  ENUMERATION_IO, en l'émettant pour tout type énuméré dont 'IMAGE/'VALUE est référencé).
- ARRAY_TEST2 : inchangé ; D0 n'existe plus (c'était le patch B), l'ordre reste
  D7 → D1 → D2 → D3 → D4 → D5 → D8 → D9.
