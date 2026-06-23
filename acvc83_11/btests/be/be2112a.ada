-- BE2112A.ADA

-- OBJECTIVE:
--     CHECK THAT THE USE OF TEXT_IO IS REQUIRED FOR THE EMPLOYMENT
--     OF THE FOLLOWING SUBPROGRAMS:
--
--       CREATE            CLOSE             OPEN
--       RESET             MODE              NAME
--       FORM              IS_OPEN           SET_INPUT
--       SET_OUTPUT        STANDARD_INPUT    STANDARD_OUTPUT
--       CURRENT_INPUT     CURRENT_OUTPUT    SET_LINE_LENGTH
--       SET_PAGE_LENGTH   LINE_LENGTH       PAGE_LENGTH
--       NEW_LINE          SKIP_LINE         END_OF_LINE
--       NEW_PAGE          SKIP_PAGE         END_OF_PAGE
--       END_OF_FILE       SET_COL           SET_LINE
--       COL               LINE              PAGE
--       GET               PUT               GET_LINE
--       PUT_LINE          DELETE

-- HISTORY:
--     ABW  08/13/82  CREATED ORIGINAL TEST.
--     JLH  08/22/88  REVISED TO INCLUDE CHECKS FOR PUT_LINE AND
--                    GET_LINE.


PROCEDURE BE2112A IS

     PACKAGE PKG IS
          TYPE FILE_TYPE IS LIMITED PRIVATE;
     PRIVATE
          TYPE FILE_TYPE IS NEW INTEGER;
     END PKG;
     USE PKG;
     TYPE FILE_MODE IS (IN_FILE, OUT_FILE, INOUT_FILE);
     TYPE COUNT IS RANGE 0..10;
     SUBTYPE POSITIVE_COUNT IS COUNT RANGE 1..10;
     FILE : FILE_TYPE;
     X_COUNT : COUNT := 4;
     P_COUNT : POSITIVE_COUNT := 8;
     LAST : NATURAL;
     CHAR : CHARACTER := 'C';
     ITEM : STRING (1..10) := "STRING ONE";

BEGIN

     CREATE (FILE, "BE2112A.DAT");             -- ERROR: CREATE
     CLOSE (FILE);                             -- ERROR: CLOSE
     OPEN (FILE);                              -- ERROR: OPEN
     RESET (FILE);                             -- ERROR: RESET
     SET_INPUT (FILE);                         -- ERROR: SET_INPUT
     SET_OUTPUT (FILE);                        -- ERROR: SET_OUTPUT
     SET_LINE_LENGTH (FILE, X_COUNT);          -- ERROR: SET_LINE_LENGTH
     SET_PAGE_LENGTH (FILE, X_COUNT);          -- ERROR: SET_PAGE_LENGTH
     NEW_LINE (FILE, P_COUNT);                 -- ERROR: NEW_LINE
     SKIP_LINE (FILE, P_COUNT);                -- ERROR: SKIP_LINE
     NEW_PAGE (FILE);                          -- ERROR: NEW_PAGE
     SKIP_PAGE (FILE);                         -- ERROR: SKIP_PAGE
     SET_COL (FILE, P_COUNT);                  -- ERROR: SET_COL
     SET_LINE (FILE, P_COUNT);                 -- ERROR: SET_LINE
     GET (FILE, CHAR);                         -- ERROR: GET
     PUT (FILE, CHAR);                         -- ERROR: PUT
     GET_LINE (FILE, ITEM, LAST);              -- ERROR: GET_LINE
     PUT_LINE (FILE, ITEM);                    -- ERROR: PUT_LINE

     DECLARE

          AA : FILE_MODE := MODE (FILE);       -- ERROR: MODE
          BB : CONSTANT STRING := NAME (FILE); -- ERROR: NAME
          CC : CONSTANT STRING := FORM (FILE); -- ERROR: FORM
          DD : BOOLEAN := IS_OPEN (FILE);      -- ERROR: IS_OPEN
          II : COUNT := LINE_LENGTH (FILE);    -- ERROR: LINE_LENGTH
          JJ : COUNT := PAGE_LENGTH (FILE);    -- ERROR: PAGE_LENGTH
          KK : BOOLEAN := END_OF_LINE (FILE);  -- ERROR: END_OF_LINE
          LL : BOOLEAN := END_OF_PAGE (FILE);  -- ERROR: END_OF_PAGE
          MM : BOOLEAN := END_OF_FILE (FILE);  -- ERROR: END_OF_FILE
          NN : POSITIVE_COUNT := COL (FILE);   -- ERROR: COL
          OO : POSITIVE_COUNT := LINE (FILE);  -- ERROR: LINE
          PP : POSITIVE_COUNT := PAGE (FILE);  -- ERROR: PAGE

          PROCEDURE SORT (D : FILE_TYPE) IS
               BEGIN
                    NULL;
               END;

     BEGIN

          DELETE (FILE);                       -- ERROR: DELETE
          SORT (STANDARD_INPUT);               -- ERROR: STANDARD_INPUT
          SORT (STANDARD_OUTPUT);              -- ERROR: STANDARD_OUTPUT
          SORT (CURRENT_INPUT);                -- ERROR: CURRENT_INPUT
          SORT (CURRENT_OUTPUT);               -- ERROR: CURRENT_OUTPUT

     END;

END BE2112A;
