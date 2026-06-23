-- C35503P.ADA

-- OBJECTIVE:
--     CHECK THAT 'FIRST' AND 'LAST' YIELD THE CORRECT RESULTS WHEN THE
--     PREFIX IS A GENERIC FORMAL DISCRETE TYPE WHOSE ARGUMENT IS AN
--     INTEGER TYPE.

-- HISTORY:
--     RJW 03/24/86 CREATED ORIGINAL TEST.
--     DHH 10/19/87 SHORTENED LINES CONTAINING MORE THAN 72 CHARACTERS.

WITH REPORT; USE REPORT;

PROCEDURE C35503P IS

BEGIN
     TEST ("C35503P", "CHECK THAT 'FIRST' AND 'LAST' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS A " &
                      "GENERIC FORMAL DISCRETE TYPE WHOSE ARGUMENT " &
                      "IS AN INTEGER TYPE" );


     DECLARE

          TYPE INT IS RANGE -6 .. 6;
          SUBTYPE SINT IS INT RANGE INT(IDENT_INT(-4)) ..
                                                     INT(IDENT_INT(4));
          SUBTYPE NOINT IS INT RANGE INT(IDENT_INT(1)) ..
                                                    INT(IDENT_INT(-1));

          GENERIC
               TYPE I IS (<>);
               F, L : I;
          PROCEDURE P ( STR : STRING );

          PROCEDURE P ( STR : STRING ) IS
          BEGIN
               IF I'FIRST /= F THEN
                    FAILED ( "INCORRECT 'FIRST' FOR " & STR );
               END IF;
               IF I'LAST /= L THEN
                    FAILED ( "INCORRECT 'LAST' FOR " & STR );
               END IF;
          END P;

          GENERIC
               TYPE I IS (<>);
               F, L : I;
          PROCEDURE Q;

          PROCEDURE Q IS
               SUBTYPE SI IS I;
          BEGIN
               IF SI'FIRST /= F THEN
                    FAILED ( "INCORRECT VALUE FOR INTEGER'FIRST" );
               END IF;
               IF SI'LAST /= L THEN
                    FAILED ( "INCORRECT VALUE FOR INTEGER'LAST" );
               END IF;
          END Q;

          GENERIC
               TYPE I IS (<>);
          PROCEDURE R;

          PROCEDURE R IS
               SUBTYPE SI IS I;
          BEGIN
               IF SI'FIRST /= SI'VAL (IDENT_INT(1)) THEN
                    FAILED ( "INCORRECT VALUE FOR NOINT'FIRST" );
               END IF;
               IF SI'LAST /= SI'VAL (IDENT_INT(-1)) THEN
                    FAILED ( "INCORRECT VALUE FOR NOINT'LAST" );
               END IF;
          END R;

          PROCEDURE P1 IS NEW P ( I => INT, F => -6, L => 6 );
          PROCEDURE P2 IS NEW P ( I => SINT, F => -4, L => 4 );
          PROCEDURE Q1 IS NEW Q
               ( I => INTEGER, F => INTEGER'FIRST, L => INTEGER'LAST );
          PROCEDURE R1 IS NEW R ( I => NOINT);

     BEGIN
          P1 ( "INT" );
          P2 ( "SINT" );
          Q1;
          R1;
     END;

     RESULT;
END C35503P;
