-- B33301B.ADA

-- OBJECTIVE:
--     CHECK THAT T'BASE CANNOT BE USED AS A TYPE_MARK IN A
--     SUBTYPE_INDICATION (I.E., IN AN ACCESS_TYPE_DEFINITION,
--     ARRAY_TYPE_DEFINITION, COMPONENT_DECLARATION,
--     DERIVED_TYPE_DEFINITION, DISCRIMINANT_DECLARATION,
--     OBJECT_DECLARATION, PARAMETER_DECLARATION,
--     SUBPROGRAM_SPECIFICATION, OR SUBTYPE_DECLARATION),
--     ALLOCATOR, INDEX OR RENAMING_DECLARATION.

-- HISTORY:
--     DWC 09/22/87  CREATED ORIGINAL TEST FROM SPLIT OF B33301A.ADA.

PROCEDURE B33301B IS

     SUBTYPE T IS INTEGER RANGE 0..10;

     TYPE AR IS ARRAY (T) OF INTEGER;

     SUBTYPE ST IS STRING (1 .. 3);

     I : INTEGER := 0;
     B : BOOLEAN;

     TYPE A IS ACCESS INTEGER;
     AI : A;

     TYPE T1 IS ACCESS T'BASE;                      -- ERROR: 'BASE.
     TYPE T2 IS ARRAY (T) OF T'BASE;                -- ERROR: 'BASE.

     TYPE T3 IS
          RECORD
               I : T'BASE;                          -- ERROR: 'BASE.
          END RECORD;

     TYPE T4 IS NEW T'BASE;                         -- ERROR: 'BASE.
     TYPE T5 IS ARRAY (T'BASE) OF T;                -- ERROR: 'BASE.

     TYPE T6 (D : T'BASE) IS                        -- ERROR: 'BASE.
          RECORD
               I : INTEGER;
          END RECORD;

     GENERIC
          TYPE I IS RANGE <>;
     PACKAGE PKG IS
          J : I;
     END PKG;

     I1 : T'BASE;                                   -- ERROR: 'BASE.
     I2 : CONSTANT T'BASE := 0;                     -- ERROR: 'BASE.

     SUBTYPE T7 IS T'BASE;                          -- ERROR: 'BASE.

     I3 : T'BASE RENAMES I;                         -- ERROR: 'BASE.

     GENERIC
          G1 : IN T'BASE;                           -- ERROR: 'BASE.
          G2 : IN OUT T'BASE;                       -- ERROR: 'BASE.
     PACKAGE GENPACK1 IS
     END GENPACK1;

     GENERIC
          TYPE GTYPE1 IS PRIVATE;
          TYPE GTYPE2 IS ARRAY (T) OF GTYPE1;
     PACKAGE GENPACK2 IS
          X : GTYPE2;
     END GENPACK2;

     GENERIC
          TYPE GT IS ARRAY (POSITIVE RANGE <>) OF CHARACTER;
     PACKAGE GENPACK3 IS
     END GENPACK3;

     PROCEDURE P1 (I : T'BASE) IS                   -- ERROR: 'BASE.
     BEGIN
          NULL;
     END P1;

     FUNCTION F1 (I : T) RETURN T'BASE IS           -- ERROR: 'BASE.
     BEGIN
          RETURN I;
     END F1;

BEGIN

     AI := NEW T'BASE;                              -- ERROR: 'BASE.

END B33301B;
