-- B61001A.ADA

-- CHECK THAT A PROCEDURE MAY NOT BE DECLARED AS AN OBJECT.

-- DAS  1/20/81


PROCEDURE B61001A IS

     P7   : PROCEDURE (X : INTEGER);                 -- ERROR: PROCEDURE
                                                     -- MAY NOT BE
                                                     -- DECLARED AS AN
                                                     -- OBJECT.

BEGIN

     NULL;

END B61001A;
