-- B39004C.ADA

-- CHECK THAT AN EXCEPTION DECLARATION IS NOT ALLOWED IN A DECLARATIVE
-- PART AFTER A TASK BODY.

-- RJW 2/27/86 

PROCEDURE B39004C IS
     
     OVERFLOW : EXCEPTION;               -- OK.

     TASK T IS END T;

     UNDERFLOW : EXCEPTION;              -- OK.

     TASK BODY T IS 
     BEGIN
          NULL;
     END T;
          
     ABENDING : EXCEPTION;              -- ERROR: EXCEPTION DECL AFTER
                                        --        TASK BODY.
BEGIN
     NULL;          
END B39004C;                                
