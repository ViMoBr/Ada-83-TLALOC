-- C37310A.ADA
 
-- CHECK THAT IF A DISCRIMINANT HAS A DYNAMIC SUBTYPE, AN OTHERS
-- CHOICE CAN BE OMITTED IF ALL VALUES IN THE BASE
-- TYPE'S RANGE ARE COVERED.
 
-- ASL 7/10/81
-- SPS 10/25/82

WITH REPORT;
PROCEDURE C37310A IS
 
     USE REPORT;
 
BEGIN
     TEST ("C37310A", "CHECK DYNAMIC DISCRIMINANT SUBTYPES " &
                      "IN VARIANT RECORD DECLARATIONS");

     DECLARE
 
          ACHAR : CHARACTER := IDENT_CHAR('A');
          ECHAR : CHARACTER := IDENT_CHAR('E');
          JCHAR : CHARACTER := IDENT_CHAR('J');
          MCHAR : CHARACTER := IDENT_CHAR('M');
          SUBTYPE STATCHAR IS CHARACTER RANGE 'I'..'N';
          SUBTYPE DYNCHAR IS CHARACTER RANGE ACHAR..ECHAR; 
          SUBTYPE SSTAT IS STATCHAR RANGE JCHAR..MCHAR;

          TYPE LETTER IS NEW CHARACTER RANGE 'A'..'Z';
          SUBTYPE DYNLETTER IS 
               LETTER RANGE LETTER(ECHAR)..LETTER(JCHAR);     
 
          TYPE REC1(DISC : SSTAT := 'K') IS
               RECORD
                    CASE DISC IS
                         WHEN ASCII.NUL..ASCII.DEL => NULL;
                    END CASE;
               END RECORD;
      
          TYPE REC2(DISC : DYNCHAR := 'C') IS
               RECORD
                    CASE DISC IS
                         WHEN ASCII.NUL..ASCII.DEL => NULL;
                    END CASE;       
               END RECORD;
      
          TYPE REC3(DISC: DYNCHAR := 'D') IS
               RECORD
                    CASE DISC IS
                         WHEN CHARACTER'FIRST..CHARACTER'LAST => NULL;
                    END CASE; 
               END RECORD;
      
          TYPE REC4(DISC : DYNLETTER := 'F') IS
               RECORD
                    CASE DISC IS
                         WHEN LETTER'BASE'FIRST..
                              LETTER'BASE'LAST => NULL;
                    END CASE; 
               END RECORD;
 
          R1 : REC1;
          R2 : REC2;
          R3 : REC3;
          R4 : REC4;
     BEGIN
          IF EQUAL(3,3) THEN
               R1 := (DISC => 'L');
          END IF;
          IF R1.DISC /= 'L' THEN
               FAILED ("ASSIGNMENT FAILED - 1");
          END IF;
 
          IF EQUAL(3,3) THEN
              R2 := (DISC => 'B');
          END IF;
          IF R2.DISC /= 'B' THEN
               FAILED ("ASSIGNMENT FAILED - 2");
          END IF;
 
          IF EQUAL(3,3) THEN
               R3 := (DISC => 'B');
          END IF;
          IF R3.DISC /= 'B' THEN
               FAILED ("ASSIGNMENT FAILED - 3");
          END IF;
 
          IF EQUAL(3,3) THEN
               R4 := (DISC => 'H');
          END IF;
          IF R4.DISC /= 'H' THEN
               FAILED ("ASSIGNMENT FAILED - 4");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
              FAILED ("EXCEPTION RAISED");
     END;
 
     RESULT;
 
END C37310A;
