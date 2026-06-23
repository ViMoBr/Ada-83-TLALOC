-- B61001L.ADA

-- CHECK THAT A PROCEDURE CANNOT BE DECLARED AS A FORMAL PARAMETER OF A
-- SUBPROGRAM. 

-- DAS  1/20/81

PROCEDURE B61001L IS

     PROCEDURE P8 (P : PROCEDURE (P1 : INTEGER)) IS  -- ERROR: PROCEDURE
                                                     -- DECLARED AS A
                                                     -- FORMAL 
                                                     -- PARAMETER.
     BEGIN
          NULL;
     END P8;

BEGIN

     NULL;

END B61001L;
