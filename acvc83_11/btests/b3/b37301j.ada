-- B37301J.ADA

-- CHECK THAT COMPONENT LIST CANNOT BE VACUOUS IN A VARIANT PART.

-- ASL 7/1/81

PROCEDURE B37301J IS

     TYPE DAY IS (MON, TUE, WED, THU, FRI, SAT, SUN);
     TYPE VREC6(DISC : DAY) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS
                    WHEN MON =>               -- ERROR: VACUOUS LIST.
                    WHEN OTHERS =>
                         NULL;                -- OK.
               END CASE;
          END RECORD;
 
BEGIN
     NULL;
END B37301J; 
