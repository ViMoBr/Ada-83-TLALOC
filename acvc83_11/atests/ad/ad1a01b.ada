-- AD1A01B.ADA

-- CHECK WHETHER AN IMPLEMENTATION GIVES DIFFERENT SIZES TO OBJECTS 
-- HAVING THE SAME BASE TYPE.  
-- THIS TEST IS FOR ENUMERATION TYPES.

-- RJW 10/27/86

WITH REPORT; USE REPORT;
PROCEDURE AD1A01B IS

     TYPE E260 IS (A1, B1, C1, D1, E1, F1, G1, H1, I1, J1, K1, L1, M1,
                   N1, O1, P1, Q1, R1, S1, T1, U1, V1, W1, X1, Y1, Z1,
                   A2, B2, C2, D2, E2, F2, G2, H2, I2, J2, K2, L2, M2,
                   N2, O2, P2, Q2, R2, S2, T2, U2, V2, W2, X2, Y2, Z2,
                   A3, B3, C3, D3, E3, F3, G3, H3, I3, J3, K3, L3, M3,
                   N3, O3, P3, Q3, R3, S3, T3, U3, V3, W3, X3, Y3, Z3,
                   A4, B4, C4, D4, E4, F4, G4, H4, I4, J4, K4, L4, M4,
                   N4, O4, P4, Q4, R4, S4, T4, U4, V4, W4, X4, Y4, Z4,
                   A5, B5, C5, D5, E5, F5, G5, H5, I5, J5, K5, L5, M5,
                   N5, O5, P5, Q5, R5, S5, T5, U5, V5, W5, X5, Y5, Z5,
                   A6, B6, C6, D6, E6, F6, G6, H6, I6, J6, K6, L6, M6,
                   N6, O6, P6, Q6, R6, S6, T6, U6, V6, W6, X6, Y6, Z6,
                   A7, B7, C7, D7, E7, F7, G7, H7, I7, J7, K7, L7, M7,
                   N7, O7, P7, Q7, R7, S7, T7, U7, V7, W7, X7, Y7, Z7,
                   A8, B8, C8, D8, E8, F8, G8, H8, I8, J8, K8, L8, M8,
                   N8, O8, P8, Q8, R8, S8, T8, U8, V8, W8, X8, Y8, Z8,
                   A9, B9, C9, D9, E9, F9, G9, H9, I9, J9, K9, L9, M9,
                   N9, O9, P9, Q9, R9, S9, T9, U9, V9, W9, X9, Y9, Z9,
                   AA, BA, CA, DA, EA, FA, GA, HA, IA, JA, KA, LA, MA,
                   NA, OA, PA, QA, RA, SA, TA, UA, VA, WA, XA, YA, ZA);

     TYPE NE260 IS NEW E260;
          
BEGIN
     TEST ("AD1A01B", "CHECK WHETHER AN IMPLEMENTATION GIVES " &
                      "DIFFERENT SIZES TO OBJECTS HAVING THE SAME " &
                      "BASE TYPE. THIS TEST IS FOR ENUMERATION TYPES");
     
     DECLARE
          
          S : E260 := A1;

          SUBTYPE SE255 IS E260 RANGE A1 .. UA;
          S1 : SE255 := A1;
          
          SUBTYPE SE127 IS E260 RANGE A1 .. W5;
          S2 : SE127 := A1;

          SUBTYPE SE8 IS E260 RANGE A1 .. A8;
          S3 : SE8 := A1;

          SUBTYPE SELAST IS E260 RANGE ZA .. ZA;
          S4 : SELAST := ZA;
          
     BEGIN

          IF S1'SIZE < S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S1'SIZE IS LESS THAN S'SIZE" );
          ELSIF S1'SIZE = S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S1'SIZE IS EQUAL TO S'SIZE" );
          ELSE 
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S1'SIZE IS GREATER THAN S'SIZE" );
          END IF;

          IF S2'SIZE < S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S2'SIZE IS LESS THAN S'SIZE" );
          ELSIF S2'SIZE = S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S2'SIZE IS EQUAL TO S'SIZE" );
          ELSE 
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S2'SIZE IS GREATER THAN S'SIZE" );
          END IF;

          IF S3'SIZE < S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S3'SIZE IS LESS THAN S'SIZE" );
          ELSIF S3'SIZE = S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S3'SIZE IS EQUAL TO S'SIZE" );
          ELSE 
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S3'SIZE IS GREATER THAN S'SIZE" );
          END IF;

          IF S4'SIZE < S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S4'SIZE IS LESS THAN S'SIZE" );
          ELSIF S4'SIZE = S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S4'SIZE IS EQUAL TO S'SIZE" );
          ELSE 
               COMMENT ( "FOR SUBTYPES OF E260, " &
                         "S4'SIZE IS GREATER THAN S'SIZE" );
          END IF;

     END;          

     DECLARE
          
          S : NE260 := A1;

          SUBTYPE SE255 IS NE260 RANGE A1 .. UA;
          S1 : SE255 := A1;
          
          SUBTYPE SE127 IS NE260 RANGE A1 .. W5;
          S2 : SE127 := A1;

          SUBTYPE SE8 IS NE260 RANGE A1 .. A8;
          S3 : SE8 := A1;

          SUBTYPE SELAST IS NE260 RANGE ZA .. ZA;
          S4 : SELAST := ZA;
          
     BEGIN

          IF S1'SIZE < S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S1'SIZE IS LESS THAN S'SIZE" );
          ELSIF S1'SIZE = S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S1'SIZE IS EQUAL TO S'SIZE" );
          ELSE 
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S1'SIZE IS GREATER THAN S'SIZE" );
          END IF;

          IF S2'SIZE < S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S2'SIZE IS LESS THAN S'SIZE" );
          ELSIF S2'SIZE = S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S2'SIZE IS EQUAL TO S'SIZE" );
          ELSE 
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S2'SIZE IS GREATER THAN S'SIZE" );
          END IF;

          IF S3'SIZE < S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S3'SIZE IS LESS THAN S'SIZE" );
          ELSIF S3'SIZE = S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S3'SIZE IS EQUAL TO S'SIZE" );
          ELSE 
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S3'SIZE IS GREATER THAN S'SIZE" );
          END IF;

          IF S4'SIZE < S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S4'SIZE IS LESS THAN S'SIZE" );
          ELSIF S4'SIZE = S'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S4'SIZE IS EQUAL TO S'SIZE" );
          ELSE 
               COMMENT ( "FOR SUBTYPES OF NE260, " &
                         "S4'SIZE IS GREATER THAN S'SIZE" );
          END IF;

     END;          

     RESULT;

END AD1A01B;
