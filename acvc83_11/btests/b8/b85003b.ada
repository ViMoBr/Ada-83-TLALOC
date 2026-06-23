-- B85003B.ADA

-- OBJECTIVE:
--     CHECK THAT AN OBJECT RENAMING DECLARATION IS ILLEGAL IF IT
--     RENAMES A RECORD COMPONENT OR SUBCOMPONENT WHICH DEPENDS ON A
--     DISCRIMINANT AND THE CONTAINING RECORD IS A FORMAL GENERIC
--     'IN OUT' PARAMETER HAVING AN UNCONSTRAINED NONFORMAL TYPE OR
--     A CONSTRAINED NONFORMAL TYPE.

-- HISTORY:
--     JET 07/22/88  CREATED ORIGINAL TEST.

PROCEDURE B85003B IS
     TYPE R0 (D : INTEGER) IS
          RECORD
               F : INTEGER := D;
          END RECORD;
     TYPE A0 IS ARRAY (INTEGER RANGE <>) OF INTEGER;
     TYPE REC (D : INTEGER := 1) IS
          RECORD
               F1 : INTEGER := D;
               F2 : R0(D);
               F3 : A0(1 .. D);
          END RECORD;

     SUBTYPE SUBREC1 IS REC(1);
     SUBTYPE SUBREC2 IS REC(2);

     GENERIC
          GR1, GR2 : IN OUT REC;
          SR1 : IN OUT SUBREC1;
          SR2 : IN OUT SUBREC2;
     PACKAGE GENPACK IS
          GX1 : INTEGER RENAMES GR1.F1;     -- OK.
          GX2 : R0 RENAMES GR1.F2;          -- ERROR: COMPONENT
                                            --  USES DISCRIMINANT.
          GX3 : A0 RENAMES GR1.F3;          -- ERROR: COMPONENT
                                            --  USES DISCRIMINANT.
          GX4 : INTEGER RENAMES GR2.F2.F;   -- ERROR: SUBCOMPONENT
                                            --  USES DISCRIMINANT.
          GX5 : INTEGER RENAMES GR2.F3(1);  -- ERROR: SUBCOMPONENT
                                            --  USES DISCRIMINANT.

          SX1 : INTEGER RENAMES SR1.F1;     -- OK.
          SX2 : R0 RENAMES SR1.F2;          -- ERROR: COMPONENT
                                            --  USES DISCRIMINANT.
          SX3 : A0 RENAMES SR1.F3;          -- ERROR: COMPONENT
                                            --  USES DISCRIMINANT.
          SX4 : INTEGER RENAMES SR2.F2.F;   -- ERROR: SUBCOMPONENT
                                            --  USES DISCRIMINANT.
          SX5 : INTEGER RENAMES SR2.F3(1);  -- ERROR: SUBCOMPONENT
                                            --  USES DISCRIMINANT.
     END GENPACK;

BEGIN
     NULL;
END B85003B;
