--  C45611A.ADA

--  CHECK THAT EXPONENTIATION OF AN INTEGER TO AN INTEGER VALUE IS 
--  CORRECTLY EVALUATED.

--  H. TILTON 9/23/86

WITH REPORT; USE REPORT;

PROCEDURE C45611A IS

    I1,INT : INTEGER;
   
    BEGIN

 
         TEST ("C45611A", "CHECK THAT EXPONENTIATION OF AN INTEGER " &
                          "VALUE IS CORRECTLY EVALUATED");

         I1 := IDENT_INT(0) ** IDENT_INT(0);

         IF IDENT_INT(I1) /= IDENT_INT(1) THEN
              FAILED( "INCORRECT RESULT FOR '0**0'" ); 
         END IF;

         INT := "**" (IDENT_INT(0),IDENT_INT(1));

         IF IDENT_INT(INT) /= IDENT_INT(0) THEN
              FAILED( "INCORRECT RESULT FOR '0**1'" ); 
         END IF;

         I1 := IDENT_INT(6) ** IDENT_INT(0);

         IF IDENT_INT(I1) /= IDENT_INT(1) THEN
              FAILED( "INCORRECT RESULT FOR '6**0'" ); 
         END IF;

         INT := IDENT_INT(156) ** IDENT_INT(1);

         IF IDENT_INT(INT) /= IDENT_INT(156) THEN
              FAILED( "INCORRECT RESULT FOR '156**1'" ); 
         END IF;

         I1 := IDENT_INT(-3) ** IDENT_INT(0);

         IF IDENT_INT(I1) /= IDENT_INT(1) THEN
              FAILED( "INCORRECT RESULT FOR '(-3)**0'" ); 
         END IF;

         INT := "**" (IDENT_INT(-7),IDENT_INT(1));

         IF IDENT_INT(INT) /= IDENT_INT(-7) THEN
              FAILED( "INCORRECT RESULT FOR '(-7)**1'" ); 
         END IF;

         I1 := "**" (IDENT_INT(-1),IDENT_INT(2));

         IF IDENT_INT(I1) /= IDENT_INT(1) THEN
              FAILED( "INCORRECT RESULT FOR '(-1)**2'" );
         END IF;
  
  
         INT := IDENT_INT(-1) ** 3;         

         IF IDENT_INT(INT) /= IDENT_INT(-1) THEN
              FAILED( "INCORRECT RESULT FOR '(-1)**3'" );
         END IF;
  
         INT := "**" (IDENT_INT(0),IDENT_INT(2));

         IF IDENT_INT(INT) /= IDENT_INT(0) THEN
              FAILED( "INCORRECT RESULT FOR '0**2'" );
         END IF;

         INT := IDENT_INT(0) ** IDENT_INT(10);

         IF IDENT_INT(INT) /= IDENT_INT(0) THEN
              FAILED( "INCORRECT RESULT FOR '0**10'" );
         END IF;
  
         INT := "**" (IDENT_INT(6),IDENT_INT(2));

         IF IDENT_INT(INT) /= IDENT_INT(36) THEN
              FAILED( "INCORRECT RESULT FOR '6**2'" );
         END IF;
  
         INT := "**" (IDENT_INT(2),IDENT_INT(2));

         IF IDENT_INT(INT) /= IDENT_INT(4) THEN
              FAILED( "INCORRECT RESULT FOR '2**2'" );
         END IF;

         I1 := "**" (IDENT_INT(1),IDENT_INT(10));

         IF IDENT_INT(I1) /= IDENT_INT(1) THEN
              FAILED( "INCORRECT RESULT FOR '1**10'" );
         END IF;
        
         RESULT;

    END C45611A;      
