-- C52001A.ADA

-- CHECK THAT AN ASSIGNMENT STATEMENT REPLACES THE CURRENT VALUE
--    OF THE TARGET VARIABLE FOR INTEGER, BOOLEAN, CHARACTER,
--    ENUMERATED, STRING, ARRAY, RECORD, VARIANT RECORD, AND ACCESS
--    TYPE VALUES.

-- DCB 1/29/80
-- JRK 10/30/80
-- RM  06/09/82
-- SPS 11/1/82


WITH REPORT;
PROCEDURE C52001A IS

     USE REPORT;

     I1 : INTEGER;
     B1 : BOOLEAN;
     C1 : CHARACTER;

     TYPE DAY IS (MON, TUE, WED, THU, FRI, SAT, SUN);
     TDAY : DAY;

     S1 : STRING (1..5);
     A1 : ARRAY (1..10) OF INTEGER;

     TYPE  TYPE_A1  IS  ARRAY (1..10) OF INTEGER;

     TYPE RT1 IS
          RECORD
               RI1 : INTEGER;
               RB1 : BOOLEAN;
               RC1 : CHARACTER;
               RS1 : STRING (1..5);
               RA1 : TYPE_A1 ;
          END RECORD;
     R1 : RT1;
     R2 : RT1;

     TYPE  ARRAY_OF_INT  IS  ARRAY( INTEGER RANGE <> ) OF INTEGER ;
     SUBTYPE SI IS INTEGER RANGE 0..100;
     TYPE VRT (D : DAY := MON; I : SI := 0) IS
          RECORD
               C : CHARACTER;
               CASE D IS
                    WHEN TUE =>
                         B : BOOLEAN;
                    WHEN WED =>
                         A : ARRAY_OF_INT (1..I) ;
                    WHEN OTHERS =>
                         NULL;
               END CASE;
          END RECORD;
     VR1 : VRT;
     VR2 : VRT;

     TYPE INT_PTR IS ACCESS INTEGER;
     PTR1, PTR2 : INT_PTR;

BEGIN
     TEST ("C52001A", "CHECK THAT ASSIGNMENT STATEMENT WORKS");

     I1 := 0;
     I1 := IDENT_INT(34);
     IF I1 /= 34 THEN
          FAILED ("INTEGER ASSIGNMENT NOT WORKING");
     END IF;

     B1 := FALSE;
     B1 := IDENT_BOOL(TRUE);
     IF B1 /= TRUE THEN
          FAILED("BOOLEAN ASSIGNMENT NOT WORKING");
     END IF;

     C1 := 'A';
     C1 := IDENT_CHAR('H');
     IF C1 /= 'H' THEN
         FAILED("CHARACTER ASSIGNMENT NOT WORKING");
     END IF;

     TDAY := MON;
     IF EQUAL(3,3) THEN
          TDAY := FRI;
     END IF;
     IF TDAY /= FRI THEN
          FAILED ("ENUMERATION ASSIGNMENT NOT WORKING");
     END IF;

     S1 := "AAAAA";
     IF EQUAL(3,3) THEN
          S1 := "ZYX12";
     END IF;
     IF S1 /= "ZYX12" THEN
          FAILED ("STRING ASSIGNMENT NOT WORKING");
     END IF;

     A1 := (1..10 => 0);
     IF EQUAL(3,3) THEN
          A1 := (11, 12, 13, 14, 15, 16, 17, 18, 19, 20);
     END IF;
     IF A1 /= (11,12,13,14,15,16,17,18,19,20) THEN
          FAILED ("ARRAY ASSIGNMENT NOT WORKING");
     END IF;

     R1 := (0,TRUE,'A',"AAAAA",(1..10=>0));
     IF EQUAL(3,3) THEN
          R1 := (35,FALSE,'L',"QWERT",(1,2,3,4,5,6,7,8,9,10));
     END IF;
     IF R1 /= (35,FALSE,'L',"QWERT",(1,2,3,4,5,6,7,8,9,10)) THEN
          FAILED
          ("RECORD ASSIGNMENT OF POSITIONAL AGGREGATE NOT WORKING");
     END IF;

     R2 := (-1,TRUE,'Z',"ZZZZZ",(1..10=>-1));
     IF EQUAL(3,3) THEN
          R2 := R1;
     END IF;
     IF R2 /= R1 THEN
          FAILED ("RECORD ASSIGNMENT OF A COMPLETE RECORD NOT WORKING");
     END IF;

     VR1 := (MON,0,'A');
     IF EQUAL(3,3) THEN
          VR1 := (WED,5,'E',(1,2,3,4,5));
     END IF;
     IF VR1 /= (WED,5,'E',(1,2,3,4,5)) THEN
          FAILED ("VARIANT RECORD ASSIGNMENT OF POSITIONAL " &
                  "AGGREGATE NOT WORKING");
     END IF;

     VR2 := (TUE,1,'Z',FALSE);
     IF EQUAL(3,3) THEN
          VR2 := VR1;
     END IF;
     IF VR2 /= VR1 THEN
          FAILED ("VARIANT RECORD ASSIGNMENT OF A COMPLETE " &
                  "RECORD NOT WORKING");
     END IF;

     PTR1 := NEW INTEGER'(0);
     IF EQUAL(3,3) THEN
          PTR1 := NEW INTEGER'(3);
     END IF;
     I1 := IDENT_INT(PTR1.ALL);
     IF I1 /= 3 OR I1 /= PTR1.ALL THEN
          FAILED
          ("INTEGER ASSIGNMENT FROM INTEGER POINTER NOT WORKING");
     END IF;

     PTR2 := NEW INTEGER'(-1);
     IF EQUAL(3,3) THEN
          PTR2 := PTR1;
     END IF;
     IF PTR2 /= PTR1 OR PTR2.ALL /= 3 THEN
          FAILED ("POINTER ASSIGNMENT NOT WORKING");
     END IF;

     RESULT;
END C52001A;
