-- C55B16A.ADA

-- OBJECTIVE:
--     CHECK THE PROCESSING OF ITERATIONS OVER AN ENUMERATION TYPE
--     WHOSE (USER-DEFINED) REPRESENTATION CONSISTS OF A NON-CONTIGUOUS
--     SET OF INTEGERS.
--
--     (INHERITANCE (AND SUBSEQUENT OVERRIDING) OF REPRESENTATION
--     SPECIFICATIONS WILL BE TESTED ELSEWHERE.)

-- HISTORY:
--     RM  08/06/82  CREATED ORIGINAL TEST.
--     BCB 01/04/88  MODIFIED HEADER.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.


WITH REPORT; USE REPORT;
PROCEDURE  C55B16A  IS

     I1  :  INTEGER := 0 ;

     TYPE  ENUM  IS  ( 'A' , 'B' , 'D' , 'C' , Z , X , D , A , C );
     FOR   ENUM  USE ( -15 , -14 , -11 , -10 ,
                         1 , 3 , 4 , 8 , 9 );

BEGIN

     TEST ("C55B16A" , "TEST LOOPING OVER ENUMERATION TYPES WITH"  &
                       " NON-CONTIGUOUS REPRESENTATION"            );

     I1 := IDENT_INT(0) ;

     FOR  X  IN ENUM LOOP

          IF  X /= ENUM'VAL(I1)  OR
              ENUM'POS(X) /= I1                               -- 0..8
          THEN
               FAILED ( "LOOP_PARAMETER ASCENDING INCORRECTLY (1)" );
          END IF;

          I1 := I1 + IDENT_INT(1) ;

     END LOOP;


     I1 := IDENT_INT(6) ;

     FOR  X  IN ENUM RANGE D .. C LOOP

          IF  X /= ENUM'VAL(I1)  OR
              ENUM'POS(X) /= I1                               -- 6..8
          THEN
               FAILED ( "LOOP_PARAMETER ASCENDING INCORRECTLY (2)" );
          END IF;

          I1 := I1 + IDENT_INT(1) ;

     END LOOP;


     I1 := IDENT_INT(4) ;

     FOR  X  IN REVERSE 'A'..ENUM'(Z) LOOP

          IF  X /= ENUM'VAL(I1)  OR
              ENUM'POS(X) /= I1                               -- 4..0
          THEN
               FAILED ( "LOOP_PARAMETER DESCENDING INCORRECTLY (3)" );
          END IF;

          I1 := I1 - IDENT_INT(1) ;

     END LOOP;


     RESULT ;


END  C55B16A ;
