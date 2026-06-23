-- CC1010A.ADA

-- CHECK THAT THE NAMES IN A GENERIC SUBPROGRAM DECLARATION ARE
-- STATICALLY IDENTIFIED (I.E., BOUND) AT THE POINT WHERE THE
-- GENERIC DECLARATION TEXTUALLY OCCURS, AND ARE NOT DYNAMICALLY
-- BOUND AT THE POINT OF INSTANTIATION.

-- ASL 8/12/81

WITH REPORT;
PROCEDURE CC1010A IS
     USE REPORT;
BEGIN
     TEST ("CC1010A","PROPER VISIBILITY OF FREE IDENTIFIERS IN " &
           "GENERIC DECLARATIONS, BODIES AND INSTANTIATIONS");

     OUTER:
          DECLARE
               FREE : CONSTANT INTEGER := 5;
          BEGIN
               DECLARE
                    GENERIC
                         GFP : INTEGER := FREE;
                    PROCEDURE P(PFP : IN INTEGER := FREE);
          
                    FREE : CONSTANT INTEGER := 6;
            
                    PROCEDURE P(PFP : IN INTEGER := OUTER.FREE) IS
                    BEGIN
                         IF FREE /= 6 OR GFP /= 5 OR PFP /= 5 THEN
                              FAILED ("BINDINGS INCORRECT");
                         END IF;
                    END P;
               BEGIN
                    DECLARE
                         FREE : CONSTANT INTEGER := 7;
                         PROCEDURE INST IS NEW P;
                    BEGIN
                         INST;
                    END;
               END;
          END OUTER;
     RESULT;
END CC1010A;
