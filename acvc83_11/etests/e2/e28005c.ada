-- E28005C.ADA

-- OBJECTIVE:
--     CHECK THAT PRAGMAS LIST AND PAGE WORK CORRECTLY WHEN THEY APPEAR
--     IN THE FOLLOWING CONTEXTS :
--         THE PRAGMAS APPEAR AT THE BEGINNING OF A SEQUENCE OF
--         STATEMENTS, DECLARATIONS, ALTERNATIVES, OR CLAUSES;
--         LIST (OFF) OR PAGE APPEARS IN THE MIDDLE OF A LINE;
--         LIST (OFF) APPEARS AT THE BEGINNING OF A PRIVATE PART;
--         THE PRAGMAS APPEAR AFTER A COMMENT.
--     SUBTESTS ARE:
--         PART (A). TESTS OF LIST PRAGMA.
--         PART (B). TESTS OF PAGE PRAGMA.

-- PASS/FAIL CRITERIA:
--     THE TEST MUST COMPILE AND EXECUTE WITH A 'PASSED' RESULT.
--     IN ADDITION:
--     PART (A) OF THIS TEST PASSES IF THE FOUR INSTANCES OF
--     'LIST (OFF);' APPEAR.  BETWEEN THE LINE ON WHICH AN OCCURRENCE
--     OF 'LIST (OFF)' APPEARS AND THE LINE ON WHICH AN OCCURRENCE OF
--     'LIST (ON)' APPEARS, NO OTHER LINES SHOULD BE PRINTED.  ALSO,
--     THE LINE NUMBERS ON THE RIGHT HAND SIDE OF THE LISTING ARE
--     CONSISTENT WITH THESE COMMENTS (FOUR SKIPPED SEQUENCES).
--     PART (B) OF THIS TEST PASSES IF THE LAST TEXT APPEARING ON A
--     PAGE IS THE LINE CONTAINING 'PRAGMA PAGE'.  EACH OF THE SIX
--     COMMENTS WHICH CONTAIN THE WORDS 'TOP OF A NEW PAGE.' MUST
--     ACTUALLY APPEAR AT THE TOP OF A PAGE.

-- HISTORY:
--     RJW 02/28/86  CREATED ORIGINAL TEST.
--     BCB 10/21/87  CHANGED HEADER TO STANDARD FORMAT.  REMOVED TEST
--                   OF REST OF LINE AFTER 'PRAGMA LIST (OFF)'.  ALLOWED
--                   'PRAGMA LIST (ON)' TO BE PRINTED.

WITH REPORT; USE REPORT;
PROCEDURE E28005C IS

  BEGIN

     TEST ("E28005C", "CHECK THAT LIST AND PAGE WORK " &
                      "CORRECTLY AT THE BEGINNING OF " &
                      "A SEQUENCE OF STATEMENTS, " &
                      "DECLARATIONS, ALTERNATIVES, OR CLAUSES");

     SPECIAL_ACTION ("THE COMPILER LISTING FOR THIS TEST MUST BE " &
                     "EXAMINED");
                                                         -- LINE NOS.

     DECLARE -- PART (A)                                     -- 1
                                                             -- 2
                        -- 'LIST OFF' AT BEGINNING OF        -- 3
                        --     SEQUENCE OF DECLARATIONS.     -- 4 OFF
          PRAGMA LIST (OFF);                                 -- 5
                                                             -- 6
          A, B, C : INTEGER := 5;                            -- 7
                                                             -- 8
          BOOL : BOOLEAN := TRUE;                            -- 9
                                                             -- 10
          PACKAGE P1 IS END P1;                              -- 11
          PACKAGE BODY P1 IS END P1;                         -- 12
                                                             -- 13
          PACKAGE P2 IS END P2;                              -- 14
          PACKAGE BODY P2 IS END P2;                         -- 15
                                                             -- 16
                        -- THIS PRAGMA SHOULD HAVE           -- 17
                        -- NO EFFECT - PRAGMA LIST (ON);     -- 18
                                                             -- 19
          PACKAGE P3 IS END P3;                              -- 20
          PACKAGE BODY P3 IS END P3;                         -- 21
                                                             -- 22
          PRAGMA LIST (ON); -- THIS COMMENT MUST BE LISTED.  -- 23 ON
                        -- 'LIST ON' AT BEGINNING OF         -- 24
                        --       SEQUENCE OF CLAUSES.        -- 25
          USE P1;                                            -- 26
          USE P2;                                            -- 27
          USE P3;                                            -- 28
                                                             -- 29
          PROCEDURE TOP IS                                   -- 30
          BEGIN                                              -- 31
               NULL;                                         -- 32
          END TOP;                                           -- 33
                                                             -- 34
          PACKAGE PKG IS                                     -- 35
               TYPE KEY IS PRIVATE;                          -- 36
               TYPE ARR IS PRIVATE;                          -- 37
          PRIVATE                                            -- 38
                        -- 'LIST OFF' AT THE BEGINNING       -- 39
                        --      OF A PRIVATE PART.           -- 40 OFF
               PRAGMA LIST (OFF);                            -- 41
                                                             -- 42
               TYPE KEY IS NEW NATURAL;                      -- 43
               TYPE ARR IS ARRAY (4 .. 5) OF POSITIVE;       -- 44
          END PKG;                                           -- 45
                                                             -- 46
          PACKAGE BODY PKG IS                                -- 47
          END PKG;                                           -- 48
                                                             -- 49
     BEGIN                                                   -- 50
          PRAGMA LIST (ON); -- THIS COMMENT MUST BE LISTED.  -- 51 ON
                            -- 'LIST ON' AT BEGINNING OF     -- 52
                            --  SEQUENCE OF STATEMENTS.      -- 53
          BEGIN                                              -- 54
               NULL;                                         -- 55
          END;                                               -- 56
          IF (A = B) THEN                                    -- 57
               NULL;                                         -- 58
          END IF;                                            -- 59
                        -- 'LIST OFF' IN THE MIDDLE OF A     -- 60
                        --      LINE.                        -- 61 OFF
          B:=A; PRAGMA LIST(OFF); C:=B;                      -- 62
                                                             -- 63
          PRAGMA LIST (ON); -- THIS COMMENT MUST BE LISTED.  -- 64 ON
                        -- 'LIST ON' FOLLOWING A COMMENT.    -- 65
                                                             -- 66
          IF IDENT_INT (C) /= 5 THEN                         -- 67
               FAILED ( "LIST (OFF) SUPPRESSED CODE" );      -- 68
          END IF;                                            -- 69
                                                             -- 70
          CASE BOOL IS                                       -- 71
                        -- 'LIST OFF' AT THE BEGINNING OF    -- 72
                        --     SEQUENCE OF ALTERNATIVES.     -- 73 OFF
               PRAGMA LIST (OFF);                            -- 74
                                                             -- 75
               WHEN TRUE =>                                  -- 76
                    NULL;                                    -- 77
               WHEN FALSE =>                                 -- 78
                    NULL;                                    -- 79
               WHEN OTHERS =>                                -- 80
                    NULL;                                    -- 81
          END CASE;                                          -- 82
     END;                                                    -- 83
               PRAGMA LIST (ON); -- THIS COMMENT MUST BE     -- 84 ON
                                 -- LISTED.                  -- 85
                        -- 'LIST ON'.                        -- 86
-----------------------------------------------------------------------

     DECLARE -- PART (B).                                    -- 1
                                                             -- 2
                        -- 'PAGE' AT BEGINNING OF            -- 3
                        --     SEQUENCE OF DECLARATIONS.     -- 4
          PRAGMA PAGE;
                        -- TOP OF A NEW PAGE.                -- 5 PAGE
                                                             -- 6
          A, B, C : INTEGER := 5;                            -- 7
          BOOL : BOOLEAN := TRUE;                            -- 8
                                                             -- 9
          PACKAGE P1 IS END P1;                              -- 10
          PACKAGE BODY P1 IS END P1;                         -- 11
                                                             -- 12
          PACKAGE P2 IS END P2;                              -- 13
          PACKAGE BODY P2 IS END P2;                         -- 14
                                                             -- 15
                        -- THIS PRAGMA SHOULD HAVE           -- 16
                        -- NO EFFECT - PRAGMA PAGE;          -- 17
                                                             -- 18
          PACKAGE P3 IS END P3;                              -- 19
          PACKAGE BODY P3 IS END P3;                         -- 20
                                                             -- 21
                        -- 'PAGE' AT BEGINNING OF            -- 22
                        --       SEQUENCE OF CLAUSES.        -- 23
          PRAGMA PAGE;
                        -- TOP OF A NEW PAGE.                -- 24 PAGE
                                                             -- 25
          USE P1;                                            -- 26
          USE P2;                                            -- 27
          USE P3;                                            -- 28
                                                             -- 29
          PROCEDURE TOP IS                                   -- 30
          BEGIN                                              -- 31
               NULL;                                         -- 32
          END TOP;                                           -- 33
                                                             -- 34
          PACKAGE PKG IS                                     -- 35
               TYPE KEY IS PRIVATE;                          -- 36
               TYPE ARR IS PRIVATE;                          -- 37
          PRIVATE                                            -- 38
                        -- 'PAGE' AT THE BEGINNING           -- 39
                        --      OF A PRIVATE PART.           -- 40
               PRAGMA PAGE;
                            -- TOP OF A NEW PAGE.            -- 41 PAGE
                                                             -- 42
               TYPE KEY IS NEW NATURAL;                      -- 43
               TYPE ARR IS ARRAY (1 .. 5) OF POSITIVE;       -- 44
          END PKG;                                           -- 45
                                                             -- 46
          PACKAGE BODY PKG IS                                -- 47
          END PKG;                                           -- 48
                                                             -- 49
     BEGIN                                                   -- 50
                        -- 'PAGE' AT BEGINNING OF            -- 51
                        --     SEQUENCE OF STATEMENTS.       -- 52
          PRAGMA PAGE;
                        -- TOP OF A NEW PAGE.                -- 53 PAGE
                                                             -- 54
          BEGIN                                              -- 55
               NULL;                                         -- 56
          END;                                               -- 57
          IF (A = B) THEN                                    -- 58
                    NULL;                                    -- 59
          END IF;                                            -- 60
                        -- 'PAGE' IN THE MIDDLE OF A         -- 61
                        --      LINE.                        -- 62
          B := C; PRAGMA PAGE; C := A + B;
                                           -- TOP OF PAGE.   -- 63
                                                             -- 64 PAGE
                                                             -- 65
          CASE BOOL IS                                       -- 66
                        -- 'PAGE' AT THE BEGINNING OF        -- 67
                        --     SEQUENCE OF ALTERNATIVES.     -- 68
               PRAGMA PAGE;
                             -- TOP OF A NEW PAGE.           -- 69 PAGE
                                                             -- 70
               WHEN TRUE =>                                  -- 71
                    NULL;                                    -- 72
               WHEN FALSE =>                                 -- 73
                    NULL;                                    -- 74
               WHEN OTHERS =>                                -- 75
                    NULL;                                    -- 76
          END CASE;                                          -- 77
     END;                                                    -- 78

     RESULT;
END E28005C;
