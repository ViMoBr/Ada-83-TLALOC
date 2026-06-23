-- CC3125A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE INITIAL VALUE OF A 
-- GENERIC IN PARAMETER DOES NOT SATISFY ITS SUBTYPE CONSTRAINT.

-- THIS TEST CHECKS PARAMETERS OF A NON-GENERIC TYPE.

-- DAT 8/10/81
-- SPS 4/14/82

WITH REPORT; USE REPORT;

PROCEDURE CC3125A IS

BEGIN
     TEST ("CC3125A","GENERIC PARAMETER DEFAULTS OF " &
                     "NON-GENERIC TYPE EVALUATED AND CHECKED WHEN " &
                     "DECLARATION IS INSTANTIATED AND DEFAULT USED");

     FOR I IN 1 .. 3 LOOP
          COMMENT ("LOOP ITERATION");
          BEGIN

               DECLARE
                    SUBTYPE T IS INTEGER RANGE 1 .. IDENT_INT(1);
                    SUBTYPE I_1_2 IS INTEGER RANGE
                         IDENT_INT (1) .. IDENT_INT (2);

                    GENERIC
                         P,Q : T := I_1_2'(I);
                    PACKAGE PKG IS 
                         R: T := P;
                    END PKG;

               BEGIN

                    BEGIN
                         DECLARE
                              PACKAGE P1 IS NEW PKG;
                         BEGIN
                              IF I = IDENT_INT(1) THEN
                                   IF P1.R /= IDENT_INT(1) 
                                   THEN FAILED ("BAD INITIAL"&
                                        " VALUE");
                                   END IF;
                              ELSIF I = 2 THEN
                                   FAILED ("SUBTYPE NOT CHECKED AT " &
                                           "INSTANTIATION");
                              ELSE
                                   FAILED ("DEFAULT NOT EVALUATED AT " &
                                           "INSTANTIATION");
                              END IF;
                         EXCEPTION
                              WHEN OTHERS => FAILED ("WRONG HANDLER");
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              CASE I IS
                                   WHEN 1 =>
                                        FAILED ("INCORRECT EXCEPTION");
                                   WHEN 2 =>
                                        COMMENT ("CONSTRAINT CHECKED" &
                                             " ON INSTANTIATION");
                                   WHEN 3 =>
                                        COMMENT ("DEFAULT EVALUATED " &
                                             "ON INSTANTIATION");
                              END CASE;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    CASE I IS
                         WHEN 1 =>
                              FAILED ("NO EXCEPTION SHOULD BE RAISED");
                         WHEN 2 =>
                              FAILED ("DEFAULT CHECKED AGAINST " &
                                      "SUBTYPE AT DECLARATION");
                         WHEN 3 =>
                              FAILED ("DEFAULT EVALUATED AT " &
                                      "DECLARATION");
                    END CASE;
          END;
     END LOOP;

     RESULT;
END CC3125A;
