-- B61001B.ADA

-- CHECK THAT A PROCEDURE MAY NOT BE DECLARED AS A TYPE.

-- DAS  1/20/81


PROCEDURE B61001B IS

     TYPE T1 IS PROCEDURE (X : INTEGER);             -- ERROR: PROCEDURE
                                                     -- MAY NOT BE
                                                     -- DECLARED AS A
                                                     -- TYPE.

BEGIN

     NULL;

END B61001B;
