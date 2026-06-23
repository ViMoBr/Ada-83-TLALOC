-- B39004E.ADA

-- CHECK THAT A NUMBER DECLARATION IS NOT ALLOWED IN A DECLARATIVE
-- PART AFTER A PACKAGE BODY STUB.

-- RJW 2/27/86 

PROCEDURE B39004E IS
     
     N1 : CONSTANT := 0;                -- OK.

     PACKAGE B39004E_PKG IS END B39004E_PKG;

     N2 : CONSTANT := 1;                -- OK.

     PACKAGE BODY B39004E_PKG IS SEPARATE;
          
     N3 : CONSTANT := 3;                -- ERROR: NUMBER DECL AFTER
                                        --        PACKAGE BODY STUB.
BEGIN
     NULL;          
END B39004E;                                
