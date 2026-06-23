-- B39004K.ADA

-- CHECK THAT A ENUMERATION REPRESENTATION CLAUSE IS NOT ALLOWED IN A 
-- DECLARATIVE PART AFTER A PACKAGE BODY STUB.

-- RJW 7/16/86 

PROCEDURE B39004K IS
     
     TYPE NBOOL IS (FALSE, TRUE);
     TYPE CHAR IS ('A', 'B');
     TYPE MIX_CODE IS (ADD, SUB, MUL);

     FOR NBOOL USE                       -- MAY BE REJECTED.
          (FALSE => 0, TRUE => 1);

     PACKAGE B39004K1 IS END B39004K1;

     FOR CHAR USE ('A' => 8, 'B' => 16); -- MAY BE REJECTED.

     PACKAGE BODY B39004K1 IS SEPARATE;
          
     FOR MIX_CODE USE                   
          (ADD => 1, SUB => 2, MUL => 3);    -- ERROR: ENUMERATION REP
                                             -- CLAUSE AFTER PACKAGE 
                                             -- BODY STUB.
BEGIN
     NULL;          
END B39004K;                                
