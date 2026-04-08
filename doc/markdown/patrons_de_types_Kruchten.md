
Suivant la thèse de Philippe KRUCHTEN sur Ada/Ed chapitre 4  Elaboration des types

d'après la section 2 "gestion des patrons de types" page 45 "il y a 16 variantes de patron de type".
Voici un type énuméré qui étiquette chaque type de patron suivant Kruchten.
```
type TEMPLATE_TYPE is (
	TT_INT_RANGE,
	TT_ENUM,		TT_ENUM_RANGE,
	TT_FLOAT_RANGE,	TT_FIXED,
	TT_ACCESS,
	TT_U_ARRAY,	TT_C_ARRAY, TT_D_ARRAY, TT_S_ARRAY,
	TT_RECORD,	TT_U_RECORD, TT_C_RECORD, TT_ID_RECORD,
	TT_TASK,	TT_SUBPROGRAM

);
```

TT est utilisé ultérieurement dans des noms pour signifier Template_Type

Pour faciliter certains types ultérieurs, un doublet de bornes :
```
type UPPER_LOWER_INDICES	is record
	  UPPER_BOUND	: INTEGER;
	  LOWER_BOUND	: INTEGER;
	end record;
```

On utilise plus bas un type TEMPLATE_REFERENCE qui n'est pas défini mais qui est un pointeur pour le runtime.


Maintenant les patrons.

**1) INT RANGE**
tt_int_range
```
type TEMPLATE_INT_RANGE is record
	  INTEGER_SIZE	: POSITIVE;
	  UPP_LOW		: UPPER_LOWER_INDICES;
	end record;
```

_exemple :_
```
type ASCII_CODE	is new INTEGER range 0 .. 127;

```

**2) ENUM**
tt_enum
```
type TEMPLATE_ENUM is record
	  ENUM_SIZE		: POSITIVE;
	  UPP_LOW		: UPPER_LOWER_INDICES;
	  LITTERAL_LIST	: STRING;	-- concaténation de chaînes type Pascal (longueur octets)
	end record;
```

_exemple :_
```
type JOUR is ( LUNDI, MARDI, MERCREDI, JEUDI, VENDREDI, SAMEDI, DIMANCHE);
```

**3) ENUM SUBTYPE**
tt_enum_range
```
type TEMPLATE_ENUM_RANGE is record
	  ENUM_SIZE	:POSITIVE;
	  UPPER_BOUND	: INTEGER;
	  LOWER_BOUND	: INTEGER;
	  BASE_TYPE		: ENUM_TEMPLATE_REFERENCE;
	end record;
```

_exemple :_
```
subtype JOUR_TRAVAILLE is JOUR range LUNDI .. VENDREDI;
```

**4) FLOAT RANGE**
tt_float_range
```
type TEMPLATE_FLOAT is record
	  FLOAT_SIZE	: POSITIVE;
	  UPPER_BOUND	: FLOAT;
	  LOWER_BOUND	: FLOAT;
	end record;
```

**5) FIXED**
tt_fixed
```
type TEMPLATE_FIXED is record
	  FIXED_SIZE	: POSITIVE;	-- 2,4,6,8
	  UPPER_BOUND	: FLOAT;
	  LOWER_BOUND	: FLOAT;
	  STEP_BASE		: NATURAL;	-- 2 ou 10
	  DOT_POSITION	: INTEGER;	-- dans -127 .. + 128
	end record;
```

**6) ACCESS**
tt_access
```
type TEMPLATE_ACCESS is record
	  ACCESS_SIZE			: POSITIVE;	-- Taille adresse
	  TASK_ID				: INTEGER;
	  MASTER_ENVIRONMENT	: ADDRESS;
	end record;
```

**7) UNCONSTRAINED ARRAY**
tt_u_array
```
type TT_LIST	is array ( INTEGER range <> ) of TEMPLATE_REFERENCE;

type TEMPLATE_UNCONSTRAINED_ARRAY ( DIMENSION :INTEGER )  is record
	  ARRAY_SIZE		: NATURAL;
	  COMPONENT_TT		: TEMPLATE_REFERENCE;
	  INDICES_TT_LIST	: TT_LIST( 1 .. DIMENSION );
	end record;
```
_exemple :_
```
type VECTEUR is array ( INTEGER range <>) of FLOAT;
```

**8) CONSTRAINED ARRAY**
tt_c_array

Même structure que pour TT_U_ARRAY mais références aux sous-types indices contraignants.

_exemple :_
```
subtype VECTEUR_4D is VECTEUR (  1 .. 4 );
```


**9) DISCRIMINATED_ARRAY**
tt_d_array

Tableau dont des bornes dépendent de discriminants d'un type article contenant.

```
type TT_BOUNDS_LIST	is array ( INTEGER range <> ) of UPPER_LOWER_INDICES;

type TEMPLATE_DISCRIMINATED_ARRAY is record
	  TT_UNCONSTRAINED	: TEMPLATE_REFERENCE;
	  CONTAINING_RECORD	: TEMPLATE_REFERENCE;
	  UPPS_LOWS			: TT_BOUNDS_LIST;
	end record;
```

_exemple_
```
type ENGLOBANT ( TAILLE :INTEGER ) is record
	  TABLE	: VECTEUR ( 1 .. TAILLE );	-- Ceci est un "d_array"
	end record;
```

**10) STRING-LIKE_ARRAY**
tt_s_array
```
type UPPER_LOWER_INDICES	is array ( INTEGER range <> ) of UPPER_LOWER_INDICES;

type TEMPLATE_STRING_LIKE_ARRAY is record
	  ARRAY_SIZE		: NATURAL;
	  COMPONENT_SIZE	: TEMPLATE_REFERENCE;
	  INDEX_SIZE		: INTEGER;
	  UPPS_LOWS			: UPPER_LOWER_INDICES;
	end record;
```

**11) SIMPLE 	RECORD**
tt_record

C'est le type article simple sans discriminant.
```
type OFFSET_REFERENCE is record
	  OFFSET		: NATURAL;
	  TT_REFERENCE	: TEMPLATE_REFERENCE;
	en record;
	
type OFFSETS_REFERENCES_LIST	is array ( INTEGER range <> ) of OFFSET_REFERENCE;

type TEMPLATE_RECORD ( NUMBER_OF_COMPONENTS :INTEGER ) is record
	  RECORD_SIZE		: NATURAL;
	  OFS_REFS			: OFFSETS_REFERENCES_LIST ( 1 .. NUMBER_OF_COMPONENTS ) ;
	end record;
```

**12) UNCONSTRAINED RECORD**
tt_u_record
```
type CHOICES_LIST_DESCRIPTOR ( NUMBER_OF_CHOICES :INTEGER );

type CHOICES_LIST_DESCRIPTOR_ACCESS is access CHOICES_LIST_DESCRIPTOR;

type CHOICE_DESCRIPTOR is record
	  LOW_BOUND			: INTEGER;
	  FIRST_FIELD_NUM	: INTEGER;
	  LAST_FIELD_NUM	: INTEGER;
	  SUB_CHOICES_LIST	: CHOICES_LIST_DESCRIPTOR_ACCESS;
	end record;

type CHOICES_LIST	is array ( INTEGER range <> ) of CHOICE_DESCRIPTOR;
	
type CHOICES_LIST_DESCRIPTOR ( NUMBER_OF_CHOICES :INTEGER ) is record
	  DISCRIMINANT_NUM	: INTEGER;
	  CHOICES			: CHOICES_LIST ( 1 .. NUMBER_OF_CHOICES );
	en record;
	
type TEMPLATE_UNCONSTRAINED_RECORD ( NUMBER_OF_COMPONENTS :INTEGER ) is record
	  RECORD_SIZE					: NATURAL;
	  NUMBER_OF_DISCRIMINANTS		: INTEGER;
	  NUMBER_OF_FIXED_COMPONENTS	: INTEGER;
	  OFS_REFS						: OFFSETS_REFERENCES_LIST ( 1 .. NUMBER_OF_COMPONENTS ) ;
	  TOP_CHOICES					: CHOICES_LIST_DESCRIPTOR_ACCESS;
	end record;
```
 C'est le patron le plus compliqué à cause des variantes possibles attachées aux valeurs des discriminants.
 
**13) CONSTRAINED RECORD**
tt_c_record
```
type DISCRIMINANTS_VALUES	is array ( INTEGER range <> ) of INTEGER;

type TEMPLATE_CONSTRAINED_RECORD ( NUMBER_OF_DISCRIMINANTS :INTEGER ) is record
	  RECORD_SIZE						: NATURAL;
	  UNCONSTRAINED_RECORD_TT_REFERENCE	: TEMPLATE_REFERENCE;
	  DISCR_VALUES						: DISCRIMINANTS_VALUES ( 1 .. NUMBER_OF_DISCRIMINANTS ) ;
	end record;
```

**14) DISCRIMINANT DISCRIMINATED FIELD RECORD**
tt_id_record
```
type TEMPLATE_D_RECORD ( NUMBER_OF_DISCRIMINANTS :INTEGER ) is record
	  UNCONSTRAINED_RECORD_REFERENCE			: TEMPLATE_REFERENCE;
	  CONTAINING_RECORD_REFERENCE				: TEMPLATE_REFERENCE;
	  DISCR_VALS								: DISCRIMINANTS_VALUES ( 1 .. NUMBER_OF_DISCRIMINANTS ) ;
	end record;
```

exemple :
```
type R ( D :INTEGER ) is record
	  C : ENGLOBANT ( D );	-- Voici le id_record
	end record;
```

**15) TASK**
tt_task

Le contenu exact de ce patron est à examiner plus avant.
```
type TEMPLATE_TASK is record
	  STATIC_PRIORITY 				: NATURAL;
	  NUMBER_OF_ENTRIES				: NATURAL;
	  NUMBER_OF_ENTRIES_FAMILIES	: NATURAL;
	  --     à voir :
	  -- ENTRIES_TABLE ( 1 .. NUMBER_OF_ENTRIES_FAMILIES );
	  -- FAMILY_SIZE si type statique ou TT_REFERENCE type indice famille si dynamique
	end record;
```

**16) SUBPROGAM**
tt_subprogram

à réfléchir, la section de thèse 4.2 manque de précision sur ce patron.

segment number
elaboration flag
relay table
local objects number