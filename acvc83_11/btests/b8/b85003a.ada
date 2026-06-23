-- B85003A.ADA

-- OBJECTIVE:
--     CHECK THAT AN OBJECT RENAMING DECLARATION IS ILLEGAL IF IT
--     RENAMES A COMPONENT OR A SUBCOMPONENT OF A VARIANT PART AND THE
--     CONTAINING RECORD IS A FORMAL GENERIC 'IN OUT' PARAMETER HAVING
--     AN UNCONSTRAINED OR CONSTRAINED NONFORMAL TYPE.

-- HISTORY:
--     JET 03/11/88  CREATED ORIGINAL TEST.

PROCEDURE B85003A IS
     TYPE R0 (D : INTEGER) IS
          RECORD
               F : INTEGER := D;
          END RECORD;
     TYPE A0 IS ARRAY (INTEGER RANGE <>) OF INTEGER;
     TYPE REC (D : INTEGER := 1) IS
          RECORD
               F1 : INTEGER;
               F2 : R0(D);
               F3 : A0(1 .. D);
               CASE D IS
                    WHEN 1 =>
                         F4 : INTEGER RANGE -10 .. 0;
                         F5 : A0(1..5);
                    WHEN OTHERS =>
                         F6 : FLOAT;
                         F7 : R0(5);
               END CASE;
          END RECORD;

     SUBTYPE SUBREC1 IS REC(1);
     SUBTYPE SUBREC2 IS REC(2);

     GENERIC
          GR1, GR2 : IN OUT REC;
          SR1 : IN OUT SUBREC1;
          SR2 : IN OUT SUBREC2;
     PACKAGE GENPACK IS
          GX1 : INTEGER RENAMES GR1.F1;     -- OK.
          GX4 : INTEGER RENAMES GR1.F4;     -- ERROR: COMPONENT OF
                                            --  VARIANT PART.
          GX5 : A0 RENAMES GR1.F5;          -- ERROR: COMPONENT OF
                                            --  VARIANT PART.
          GX6 : FLOAT RENAMES GR2.F6;       -- ERROR: COMPONENT OF
                                            --  VARIANT PART.
          GX7 : R0 RENAMES GR2.F7;          -- ERROR: COMPONENT OF
                                            --  VARIANT PART.
          GX8 : INTEGER RENAMES GR2.F5(2);  -- ERROR: SUBCOMPONENT OF
                                            --  VARIANT PART.
          GX9 : INTEGER RENAMES GR2.F7.F;   -- ERROR: SUBCOMPONENT OF
                                            --  VARIANT PART.

          SX1 : INTEGER RENAMES SR1.F1;     -- OK.
          SX4 : INTEGER RENAMES SR1.F4;     -- ERROR: COMPONENT OF
                                            --  VARIANT PART.
          SX5 : A0 RENAMES SR1.F5;          -- ERROR: COMPONENT OF
                                            --  VARIANT PART.
          SX6 : FLOAT RENAMES SR2.F6;       -- ERROR: COMPONENT OF
                                            --  VARIANT PART.
          SX7 : R0 RENAMES SR2.F7;          -- ERROR: COMPONENT OF
                                            --  VARIANT PART.
          SX8 : INTEGER RENAMES SR2.F5(2);  -- ERROR: SUBCOMPONENT OF
                                            --  VARIANT PART.
          SX9 : INTEGER RENAMES SR2.F7.F;   -- ERROR: SUBCOMPONENT OF
                                            --  VARIANT PART.
     END GENPACK;

BEGIN
     NULL;
END B85003A;
