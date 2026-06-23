-- C45613A.ADA

-- CHECK THAT NUMERIC_ERROR/CONSTRAINT_ERROR IS RAISED
-- BY "**" FOR INTEGERS WHEN THE RESULT EXCEEDS THE RANGE 
-- OF THE BASE TYPE.

-- H. TILTON 10/06/86

WITH REPORT; USE REPORT;
PROCEDURE C45613A IS
 
BEGIN
     TEST ("C45613A","CHECK THAT NUMERIC_ERROR/CONSTRAINT_ERROR " &
                     "IS RAISED BY ""**"" FOR INTEGERS WHEN THE " &
                     "RESULT EXCEEDS THE RANGE OF THE BASE TYPE");

     DECLARE
          INT : INTEGER;
     BEGIN
          INT := IDENT_INT(INTEGER'LAST ** IDENT_INT(2));
          FAILED ("NO EXCEPTION FOR SECOND POWER OF INTEGER'LAST");
             
          EXCEPTION
               WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS => 
                    FAILED ("WRONG EXCEPTION RAISED FOR " &
                            "SECOND POWER OF " &
                            "INTEGER'LAST");
     END;

     DECLARE
          INT : INTEGER;
     BEGIN
          INT := IDENT_INT(INTEGER'FIRST ** IDENT_INT(3));
          FAILED ("NO EXCEPTION FOR THIRD POWER OF INTEGER'FIRST");
               
          EXCEPTION
               WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED FOR " &
                            "THIRD POWER OF " &
                            "INTEGER'FIRST");
            
     END;

     RESULT;
   
END C45613A;
