-- C43004A.ADA

-- OBJECTIVE:
--     CHECK THAT CONSTRAINT_ERROR IS RAISED IF A VALUE FOR A
--     NON-DISCRIMINANT SCALAR COMPONENT OF AN AGGREGATE IS NOT
--     WITHIN THE RANGE OF THE COMPONENT'S SUBTYPE.

-- HISTORY:
--     BCB 01/22/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C43004A IS

     TYPE INT IS RANGE 1 .. 8;
     SUBTYPE SINT IS INT RANGE 2 .. 7;

     TYPE ENUM IS (VINCE, JOHN, TOM, PHIL, ROSA, JODIE, BRIAN, DAVE);
     SUBTYPE SENUM IS ENUM RANGE JOHN .. BRIAN;

     TYPE FL IS DIGITS 5 RANGE 0.0 .. 10.0;
     SUBTYPE SFL IS FL RANGE 1.0 .. 9.0;

     TYPE FIX IS DELTA 0.25 RANGE 0.0 .. 8.0;
     SUBTYPE SFIX IS FIX RANGE 1.0 .. 7.0;

     TYPE DINT IS NEW INTEGER RANGE 1 .. 8;
     SUBTYPE SDINT IS DINT RANGE 2 .. 7;

     TYPE DENUM IS NEW ENUM RANGE VINCE .. DAVE;
     SUBTYPE SDENUM IS DENUM RANGE JOHN .. BRIAN;

     TYPE DFL IS NEW FLOAT RANGE 0.0 .. 10.0;
     SUBTYPE SDFL IS DFL RANGE 1.0 .. 9.0;

     TYPE DFIX IS NEW FIX RANGE 0.0 .. 8.0;
     SUBTYPE SDFIX IS DFIX RANGE 1.0 .. 7.0;

     TYPE REC1 IS RECORD
           E1, E2, E3, E4, E5 : SENUM;
     END RECORD;

     TYPE REC2 IS RECORD
           E1, E2, E3, E4, E5 : SFIX;
     END RECORD;

     TYPE REC3 IS RECORD
           E1, E2, E3, E4, E5 : SDENUM;
     END RECORD;

     TYPE REC4 IS RECORD
           E1, E2, E3, E4, E5 : SDFIX;
     END RECORD;

     A : ARRAY(1..5) OF SINT;
     B : REC1;
     C : ARRAY(1..5) OF SFL;
     D : REC2;
     E : ARRAY(1..5) OF SDINT;
     F : REC3;
     G : ARRAY(1..5) OF SDFL;
     H : REC4;

     GENERIC
          TYPE GENERAL_PURPOSE IS PRIVATE;
     FUNCTION GENEQUAL(ONE, TWO : GENERAL_PURPOSE) RETURN BOOLEAN;

     FUNCTION GENEQUAL(ONE, TWO : GENERAL_PURPOSE) RETURN BOOLEAN IS
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN ONE = TWO;
          ELSE
               RETURN ONE /= TWO;
          END IF;
     END GENEQUAL;

     FUNCTION EQUAL IS NEW GENEQUAL(SENUM);
     FUNCTION EQUAL IS NEW GENEQUAL(SFL);
     FUNCTION EQUAL IS NEW GENEQUAL(SFIX);
     FUNCTION EQUAL IS NEW GENEQUAL(SDENUM);
     FUNCTION EQUAL IS NEW GENEQUAL(SDFL);
     FUNCTION EQUAL IS NEW GENEQUAL(SDFIX);

BEGIN
     TEST ("C43004A", "CHECK THAT CONSTRAINT_ERROR IS RAISED IF A " &
                      "VALUE FOR A NON-DISCRIMINANT SCALAR COMPONENT " &
                      "OF AN AGGREGATE IS NOT WITHIN THE RANGE OF " &
                      "THE COMPONENT'S SUBTYPE");

     BEGIN
          A := (1,2,3,4,7);            -- CONSTRAINT_ERROR BY AGGREGATE
                                       -- WITH INTEGER COMPONENTS.
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 1");
          IF EQUAL (INTEGER (A(IDENT_INT(1))),
                    INTEGER (A(IDENT_INT(1)))) THEN
               COMMENT ("DON'T OPTIMIZE A");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 1");
     END;

     BEGIN
          B := (ENUM'VAL(IDENT_INT(ENUM'POS(DAVE))), TOM, PHIL,
                ROSA, JODIE);
                                       -- CONSTRAINT_ERROR BY AGGREGATE
                                       -- WITH COMPONENTS OF AN
                                       -- ENUMERATION TYPE.
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 2");
          IF NOT EQUAL (B.E1, B.E1) THEN
               COMMENT ("DON'T OPTIMIZE B");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 2");
     END;

     BEGIN
          C := (1.0,2.0,3.0,4.0,10.0); -- CONSTRAINT_ERROR BY AGGREGATE
                                      -- WITH FLOATING POINT COMPONENTS.
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 3");
          IF NOT EQUAL (C(IDENT_INT(1)), C(IDENT_INT(1))) THEN
               COMMENT ("DON'T OPTIMIZE C");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 3");
     END;

     BEGIN
          D := (1.0,2.1,3.3,4.4,8.0);  -- CONSTRAINT_ERROR BY AGGREGATE
                                       -- WITH FIXED POINT COMPONENTS.
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 4");
          IF NOT EQUAL (D.E1, D.E1) THEN
               COMMENT ("DON'T OPTIMIZE D");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 4");
     END;

     BEGIN
          E := (1,2,3,4,7);          -- CONSTRAINT_ERROR BY AGGREGATE
                                     -- WITH DERIVED INTEGER COMPONENTS.
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 5");
          IF NOT EQUAL (INTEGER (E(IDENT_INT(1))),
                        INTEGER (E(IDENT_INT(1)))) THEN
               COMMENT ("DON'T OPTIMIZE E");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 5");
     END;

     BEGIN
          F := (DENUM'VAL(IDENT_INT(DENUM'POS(VINCE))), TOM, PHIL,
                ROSA, JODIE);
                                       -- CONSTRAINT_ERROR BY AGGREGATE
                                       -- WITH COMPONENTS OF A DERIVED
                                       -- ENUMERATION TYPE.
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 6");
          IF NOT EQUAL (F.E1, F.E1) THEN
               COMMENT ("DON'T OPTIMIZE F");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 6");
     END;

     BEGIN
          G := (1.0,2.0,3.0,4.0,10.0); -- CONSTRAINT_ERROR BY AGGREGATE
                                       -- WITH DERIVED FLOATING POINT
                                       -- COMPONENTS.
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 7");
          IF NOT EQUAL (G(IDENT_INT(1)), G(IDENT_INT(1))) THEN
               COMMENT ("DON'T OPTIMIZE G");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 7");
     END;

     BEGIN
          H := (1.0,2.0,3.5,4.3,8.0);  -- CONSTRAINT_ERROR BY AGGREGATE
                                       -- WITH DERIVED FIXED POINT
                                       -- COMPONENTS.
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 8");
          IF NOT EQUAL (H.E1, H.E1) THEN
               COMMENT ("DON'T OPTIMIZE H");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 8");
     END;


     RESULT;
END C43004A;
