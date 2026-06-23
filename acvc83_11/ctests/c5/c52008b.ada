-- C52008B.ADA
 
-- CHECK THAT A RECORD VARIABLE DECLARED WITH A SPECIFIED DISCRIMINANT
-- CONSTRAINT CANNOT HAVE A DISCRIMINANT VALUE ALTERED BY ASSIGNMENT.  
-- ASSIGNING AN ENTIRE RECORD VALUE WITH A DIFFERENT DISCRIMINANT VALUE
-- SHOULD RAISE CONSTRAINT_ERROR AND LEAVE THE TARGET VARIABLE 
-- UNALTERED.  THIS TEST USES NON-STATIC DISCRIMINANT VALUES.
 
-- ASL 6/25/81
-- JRK 11/18/82
 
WITH REPORT;
PROCEDURE C52008B IS
 
     USE REPORT;
 
     TYPE REC1(D1,D2 : INTEGER) IS
          RECORD
               COMP1 : STRING(D1..D2);
          END RECORD;
 
     TYPE AR_REC1 IS ARRAY (NATURAL RANGE <>) OF REC1(IDENT_INT(3),
                                                      IDENT_INT(5));

     TYPE REC2(D1,D2,D3,D4 : INTEGER := 0) IS
          RECORD
               COMP1 : STRING(1..D1);
               COMP2 : STRING(D2..D3);
               COMP5 : AR_REC1(1..D4);
               COMP6 : REC1(D3,D4);
          END RECORD;
 
     STR : STRING(IDENT_INT(3)..IDENT_INT(5)) := "ZZZ";
 
     R1A : REC1(IDENT_INT(3),IDENT_INT(5)) := (3,5,STR);
     R1C : REC1(5,6) := (5,6,COMP1 => (5..6 => 'K'));
   
     Q,R : REC2(IDENT_INT(2),IDENT_INT(3),IDENT_INT(5),IDENT_INT(6));
     TEMP : REC2(2,3,5,6);
    
     W : REC2(1,4,6,8);
     OK : BOOLEAN := FALSE;
 
 
BEGIN
 
     TEST ("C52008B", "CANNOT ASSIGN RECORD VARIABLE WITH SPECIFIED " &
                      "DISCRIMINANT VALUE A VALUE WITH A DIFFERENT " &
                      "(DYNAMIC) DISCRIMINANT VALUE");
 
     BEGIN
          R1A := (IDENT_INT(3),5,"XYZ");

          R := (IDENT_INT(2),IDENT_INT(3),IDENT_INT(5),IDENT_INT(6),
                "AB",
                STR,
                (1..6 => R1A),
                R1C);
 
          TEMP := R;
          Q := TEMP;
          R.COMP1 := "YY";
          OK := TRUE;
          W := R;
          FAILED ("ASSIGNMENT MADE USING INCORRECT DISCRIMINANT " &
                  "VALUES");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT OK
               OR Q /= TEMP
               OR R = TEMP
               OR R = Q
               OR W.D4 /= 8 THEN
                    FAILED ("LEGITIMATE ASSIGNMENT FAILED");
               END IF;
          WHEN OTHERS => 
               FAILED ("WRONG EXCEPTION");
     END;
 
     RESULT;
 
END C52008B;
