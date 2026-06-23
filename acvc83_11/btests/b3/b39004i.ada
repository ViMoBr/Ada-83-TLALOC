-- B39004I.ADA

-- CHECK THAT A TASK STORAGE SIZE SPECIFICATION IS NOT ALLOWED IN A 
-- DECLARATIVE PART AFTER A TASK BODY.

-- RJW 2/27/86 

PROCEDURE B39004I IS
     
     TASK TYPE RESOURCE IS
          ENTRY SEIZE;
          ENTRY RELEASE;
     END RESOURCE;

     FOR RESOURCE'STORAGE_SIZE USE 200;         -- MAY BE REJECTED.

     TASK TYPE MAILBOX IS
          ENTRY DEPOSIT;
          ENTRY COLLECT;
     END MAILBOX;

     TASK BODY RESOURCE IS 
     BEGIN
          NULL;
     END RESOURCE;
          
     FOR MAILBOX'STORAGE_SIZE USE 500;          -- ERROR: TASK STORAGE
                                                -- SIZE AFTER TASK 
                                                -- BODY.
     TASK BODY MAILBOX IS 
     BEGIN
          NULL;
     END MAILBOX;
          
BEGIN
     NULL;          
END B39004I;                                
