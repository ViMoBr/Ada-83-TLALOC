-- B37309B.ADA

-- OBJECTIVE:
--     CHECK THAT IF A DISCRIMINANT HAS A STATIC SUBTYPE, AN OTHERS
--     CHOICE MUST NOT BE OMITTED IF ONE OR MORE VALUES IN THE
--     SUBTYPE'S RANGE ARE MISSING.
--     CHECK THAT VALUES OUTSIDE THE RANGE OF THE SUBTYPE ARE FORBIDDEN.

-- HISTORY:
--     ASL 07/10/81
--     SPS 12/07/82
--     RJW 01/21/86 RENAMED FROM -AB.
--                  ADDED TEST FOR CHOICE OUTSIDE OF RANGE.
--     DHH 08/15/88 REVISED HEADER AND REMOVED DYNAMIC SUBTYPES.

PROCEDURE B37309B IS

     SUBTYPE STATCHAR IS CHARACTER RANGE 'I'..'N';
     SUBTYPE SSTAT IS STATCHAR RANGE 'I'..'M';
     TYPE NEWSTAT IS NEW CHARACTER RANGE 'A'..'D';

     TYPE REC1(DISC : STATCHAR) IS
          RECORD
               CASE DISC IS
                    WHEN 'I' => NULL;
                    WHEN 'J' => NULL;
                    WHEN 'L' => NULL;
                    WHEN 'M' => NULL;
               END CASE; END RECORD;          -- ERROR: MISSING CHOICES.

     TYPE REC2(DISC : NEWSTAT) IS
          RECORD
               CASE DISC IS
                    WHEN 'B' => NULL;
                    WHEN 'C' => NULL;
                    WHEN 'D' => NULL;
               END CASE; END RECORD;          -- ERROR: MISSING OTHERS
                                              --        CHOICE.

     TYPE REC3(DISC : SSTAT) IS
          RECORD
               CASE DISC IS
                    WHEN 'I' => NULL;
                    WHEN 'J' => NULL;
                    WHEN 'K' => NULL;
                    WHEN 'L' => NULL;
                    WHEN 'M' => NULL;
                    WHEN 'N' => NULL;         -- ERROR: CHOICE OUTSIDE
                                              --        OF RANGE.
               END CASE; END RECORD;

BEGIN
     NULL;
END B37309B;
