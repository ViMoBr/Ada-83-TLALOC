-- B39004A.ADA

-- CHECK THAT AN OBJECT DECLARATION IS NOT ALLOWED IN A DECLARATIVE
-- PART AFTER A FUNCTION BODY.

-- RJW 2/27/86 

PROCEDURE B39004A IS
     
     OBJ1 : INTEGER;                    -- OK.
     
     FUNCTION F RETURN INTEGER;

     OBJ2 : INTEGER;                    -- OK.

     FUNCTION F RETURN INTEGER IS
     BEGIN
          RETURN 1;
     END F;

     OBJ3 : INTEGER;                    -- ERROR: OBJECT DECL AFTER
                                        --         FUNCTION BODY.
BEGIN
     NULL;          
END B39004A;                                
