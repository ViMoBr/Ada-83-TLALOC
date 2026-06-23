-- B39004B.ADA

-- CHECK THAT A TYPE DECLARATION IS NOT ALLOWED IN A DECLARATIVE
-- PART AFTER A PACKAGE BODY.

-- RJW 2/27/86 

PROCEDURE B39004B IS
     
     TYPE T1 IS NEW INTEGER;             -- OK.
     
     PACKAGE PKG IS END PKG;

     TYPE T2 IS NEW BOOLEAN;             -- OK.

     PACKAGE BODY PKG IS END PKG;
          
     TYPE T3 IS NEW CHARACTER;           -- ERROR: TYPE DECL AFTER
                                         --         PACKAGE BODY.
BEGIN
     NULL;          
END B39004B;                                
