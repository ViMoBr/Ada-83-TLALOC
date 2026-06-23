-- DATSPEC.ADA

-- PURPOSE:
--     THIS PACKAGE IS FOR USE WITH THE 'AVAT' SYSTEM.
--     IT LISTS THE FEATURES WHOSE SUPPORT IS TO BE
--     CHECKED AND COLLECTS THE DATA AS THE SEPARATE TESTS EXECUTE.
--     IT ALSO CONTAINS THE REPORTING PROCEDURE.

-- HISTORY:
--      PWB 01/10/87  CREATED ORIGINAL PACKAGE.
--      TBN 03/20/87  ADDED FEATURES AND REFINED STORAGE AND OUTPUT.
--      PWB 08/15/87  RESTRUCTURED AND ADDED FEATURES.
--      TBN 11/16/87  ADDED OTHER FEATURES.
--      RJW 07/18/89  REMOVED FEATURES WHICH ARE NO LONGER OPTIONAL.

PACKAGE DATA_COLLECTION IS

     -- THE ORDER OF THE OUTPUT IS GIVEN BY THE DECLARATION OF TYPE
     -- THINGS_TO_SUPPORT", NOT BY THE ORDER OF THE FILE NAMES.
     -- TO OUTPUT A HEADER COMMENT BEFORE A GROUP OF FEATURES, INSERT
     -- AN IDENTIFIER BEFORE THE GROUP OF FEATURES IT DESCRIBES.
     -- (E.G., PREDEFINED_TYPES REPRESENTS THE HEADER FOR THE GROUP
     -- SHORT_INT, LONG_INT, OTHER_INT, SHORT_FLO, LONG_FLO, AND
     -- OTHER_FLO.)

     TYPE THINGS_TO_SUPPORT IS       -- PROVIDES INDEX TYPE FOR STORAGE
                                     -- OF RESULTS; DETERMINES OUTPUT
                                     -- ORDER.
        (
          ---------------
          HEADER_PART_ONE,           -- HEADER COMMENT FOR PART ONE.
          ---------------            -- FILE: AVAT000.ADA

          ----------------
          PREDEFINED_TYPES,          -- HEADER COMMENT FOR PREDEFINED
          ----------------           -- NUMERIC TYPES.
                                     -- FILE: AVAT001.ADA

          SHORT_INT,                 -- TEST FOR SHORT_INTEGER.
                                     -- FILES: AVAT002.ADA, AVAT003.ADA

          LONG_INT,                  -- TEST FOR LONG_INTEGER.
                                     -- FILES: AVAT004.ADA, AVAT005.ADA

          OTHER_INT,                 -- TEST FOR OTHER INTEGER TYPE.
                                     -- FILES: AVAT006.ADA, AVAT007.TST

          SHORT_FLO,                 -- TEST FOR SHORT_FLOAT.
                                     -- FILES: AVAT008.ADA, AVAT009.ADA

          LONG_FLO,                  -- TEST FOR LONG_FLOAT.
                                     -- FILES: AVAT010.ADA, AVAT011.ADA

          OTHER_FLO,                 -- TEST FOR OTHER FLOATING TYPES.
                                     -- FILES: AVAT012.ADA, AVAT013.TST

          OTHER_FIX,                 -- TEST FOR OTHER FIXED TYPES.
                                     -- FILES: AVAT014.ADA, AVAT015.TST

          ----------------
          PRECISION_HEADER,          -- HEADER COMMENT FOR PRECISION.
          ----------------           -- FILE: AVAT016.ADA

          CHECK_MAX_MANTISSA,        -- TEST TO VERIFY
                                     -- SYSTEM.MAX_MANTISSA.
                                     -- FILES: AVAT017.ADA THRU
                                     -- AVAT019.ADA

          CHECK_MAX_MANTISSA1,       -- OUTPUT OF MAX_MANTISSA N/A LIST.

          CHECK_MAX_DIGITS,          -- TEST TO VERIFY
                                     -- SYSTEM.MAX_DIGITS.
                                     -- FILES: AVAT020.ADA THRU
                                     -- AVAT022.ADA

          CHECK_FINE_DELTA,          -- TEST TO VERIFY
                                     -- SYSTEM.FINE_DELTA.
                                     -- FILES: AVAT023.ADA THRU
                                     -- AVAT025.ADA

          CHECK_FINE_DELTA1,         -- OUTPUT OF FINE_DELTA N/A LIST.

          -------------------
          SMALL_CLAUSE_HEADER,       -- HEADER COMMENT FOR 'SMALL
          -------------------        -- CLAUSES WHICH ARE NEITHER BINARY
                                     -- NOR DECIMAL.
                                     -- FILE: AVAT144.ADA

          ARBITRARY_SMALL_CLAUSE,    -- TEST FOR 'SMALL CLAUSES WHICH
                                     -- ARE NEITHER BINARY
                                     -- NOR DECIMAL.

                                     -- FILES: AVAT145.ADA THRU
                                     -- AVAT148.ADA

          ------------------
          ACCESS_SIZE_HEADER,        -- HEADER FOR NON-DEFAULT ACCESS
          ------------------         -- 'SIZE CLAUSES. FILE: AVAT101.ADA

          ACCESS_SIZE_CLAUSE,        -- TEST FOR NON-DEFAULT 'SIZE
                                     -- CLAUSES FOR ACCESS TYPES.

                                     -- FILES: AVAT134.ADA, AVAT135.ADA
          ---------------
          ENUM_REP_HEADER,           -- HEADER COMMENT FOR TEST FOR
          ---------------            -- NON DEFAULT BOOLEAN ENUMERATION
                                     -- REPRESENTATION CLAUSES.
                                     -- FILE: AVAT201.ADA

          NON_DEFAULT_BOOLEAN,       -- TEST FOR BOOLEAN ENUMERATION
                                     -- REPRESENTATION CLAUSES
                                     -- (VALUES OTHER THAN 0, 1).
                                     -- FILES: AVAT208.ADA, AVAT209.ADA

          MACHINE_CODE,              -- TEST FOR 'WITH' CLAUSE WHICH
                                     -- SPECIFIES MACHINE_CODE.
                                     -- FILES: AVAT220.ADA, AVAT221.ADA

          --------------
          GENERIC_HEADER,            -- HEADER COMMENT FOR GENERICS
          --------------             -- FILE: AVAT301.ADA

          SEP_LIB_SUBPR_BODY,        -- TEST FOR GENERIC LIBRARY
                                     -- SUBPROGRAM BODY COMPILED APART
                                     -- FROM SPECIFICATION.
                                     -- FILES: AVAT302.ADA THRU
                                     -- AVAT305.ADA

          SEP_LIB_PACK_BODY,         -- TEST FOR GENERIC LIBRARY PACKAGE
                                     -- BODY COMPILED APART FROM
                                     -- SPECIFICATION.
                                     -- FILES: AVAT306.ADA THRU
                                     -- AVAT308.ADA

          NONLIB_SUBPR_SUBUNIT,      -- TEST FOR GENERIC NONLIBRARY
                                     -- SUBPROGRAM BODY AS A SUBUNIT
                                     -- COMPILED APART FROM
                                     -- SPECIFICATION.
                                     -- FILES: AVAT309.ADA THRU
                                     -- AVAT312.ADA

          NONLIB_PACK_SUBUNIT,       -- TEST FOR GENERIC NONLIBRARY
                                     -- PACKAGE BODY AS A SUBUNIT
                                     -- COMPILED APART FROM
                                     -- SPECIFICATION.
                                     -- FILES: AVAT313.ADA THRU
                                     -- AVAT316.ADA

          SUBPR_SUBUNIT_OF_GEN,      -- TEST FOR SUBPROGRAM SUBUNIT OF
                                     -- A GENERIC SUBPROGRAM COMPILED
                                     -- APART FROM SPECIFICATION.
                                     -- FILES: AVAT317.ADA THRU
                                     -- AVAT319.ADA

          PACK_SUBUNIT_OF_GEN,       -- TEST FOR PACKAGE BODY SUBUNIT OF
                                     -- A GENERIC SUBPROGRAM COMPILED
                                     -- APART FROM SPECIFICATION.
                                     -- FILES: AVAT320.ADA THRU
                                     -- AVAT322.ADA
          ----------
          I_O_HEADER,                -- HEADER COMMENT FOR INPUT/OUTPUT.
          ----------                 -- FILE: AVAT323.ADA

          TEXT_FILES,                -- TEST FOR SUPPORT OF TEXT FILES.
                                     -- FILE: AVAT324.ADA

          SEQ_FILES,                 -- TEST FOR SUPPORT OF SEQUENTIAL
                                     -- FILES.  FILE: AVAT325.ADA

          DIR_FILES,                 -- TEST FOR SUPPORT OF DIRECT
                                     -- FILES.  FILE: AVAT326.ADA

          SEQ_UNCONSTR_ARRAY,        -- TEST FOR INSTANTIATION OF
                                     -- SEQUENTIAL_IO WITH UNCONSTRAINED
                                     -- ARRAY TYPE.
                                     -- FILES: AVAT327.ADA, AVAT328.ADA

          SEQ_NO_DEF_DISCR_REC,      -- TEST FOR INSTANTIATION OF
                                     -- SEQUENTIAL_IO WITH RECORD TYPE
                                     -- WITH DISCRIMINANTS WITHOUT
                                     -- DEFAULTS.
                                     -- FILES: AVAT329.ADA, AVAT330.ADA

          DIR_UNCONSTR_ARRAY,        -- TEST FOR INSTANTIATION OF
                                     -- DIRECT_IO WITH UNCONSTRAINED
                                     -- ARRAY TYPE.
                                     -- FILES: AVAT331.ADA, AVAT332.ADA

          DIR_NO_DEF_DISCR_REC,      -- TEST FOR INSTANTIATION OF
                                     -- DIRECT_IO WITH RECORD TYPE WITH
                                     -- DISCRIMINANTS WITHOUT DEFAULTS.
                                     -- FILES: AVAT333.ADA, AVAT334.ADA
          -------------
          SYSTEM_REPORT,             -- HEADER COMMENT FOR REPORT OF
          -------------              -- VALUES IN PACKAGE SYSTEM.
                                     -- FILE: AVAT401.ADA

          NAME_VALUES,               -- LIST ENUMERATION LITERALS OF
                                     -- TYPE SYSTEM.NAME.
                                     -- FILE: AVAT402.ADA

          MEMORY_VALUES,             -- LIST VALUES OF
                                     -- SYSTEM.STORAGE_UNIT AND
                                     -- SYSTEM.MEMORY_SIZE.
                                     -- FILE: AVAT403.ADA

          INTEGER_LIMITS,            -- LIST VALUES OF SYSTEM.MIN_INT
                                     -- AND SYSTEM.MAX_INT.
                                     -- FILE: AVAT404.ADA

          REAL_LIMITS,               -- LIST VALUES OF
                                     -- SYSTEM.MAX_DIGITS,
                                     -- SYSTEM.MAX_MANTISSA, AND
                                     -- SYSTEM.FINE_DELTA.
                                     -- FILE: AVAT405.ADA

          OTHER_SYSTEM_VALUES,       -- LIST VALUES OF
                                     -- SYSTEM.TICK,
                                     -- SYSTEM.PRIORITY'FIRST, AND
                                     -- SYSTEM.PRIORITY'LAST.
                                     -- FILE: AVAT406.ADA
          ---------------
          STANDARD_REPORT,           -- HEADER COMMENT FOR VALUES
          ---------------            -- IN PACKAGE STANDARD.
                                     -- FILE: AVAT407.ADA

          FLOAT_VALUES,              -- LIST VALUES OF FLOAT'FIRST,
                                     -- FLOAT'LAST, FLOAT'DIGITS.
                                     -- FILE: AVAT408.ADA

          INTEGER_VALUES,            -- LIST VALUES OF INTEGER'FIRST
                                     -- AND INTEGER'LAST.
                                     -- FILE: AVAT409.ADA

          DURATION_VALUES,           -- LIST VALUES OF DURATION'FIRST,
                                     -- DURATION'LAST, DURATION'DELTA.
                                     -- FILE: AVAT410.ADA

          -----------------
          TRAILER_PART_FIVE          -- TRAILER FOR AVAT PART FIVE.
          -----------------          -- FILE AVAT411.ADA
        );

     SUBTYPE IMAGE_LENGTH IS NATURAL RANGE 0 .. 72;
     SUBTYPE MAX_LINES IS NATURAL RANGE 1 .. 7;

     TYPE LINE_RECORD (LINE_LEN : IMAGE_LENGTH := 0) IS
          RECORD
               STR : STRING (1 .. LINE_LEN);
          END RECORD;

     TYPE ARRAY_TYPE IS ARRAY (MAX_LINES RANGE <>) OF LINE_RECORD;

     TYPE SUPPORT_RECORD (NO_OF_LINES : MAX_LINES := 1) IS
          RECORD
               ARRAY_OF_LINES : ARRAY_TYPE (1 .. NO_OF_LINES);
          END RECORD;

     TYPE FEATURE_TYPE IS ARRAY (THINGS_TO_SUPPORT) OF SUPPORT_RECORD;

     FEATURE : FEATURE_TYPE;

     PROCEDURE REPORT_DATA (START  : IN THINGS_TO_SUPPORT;
                            FINISH : IN THINGS_TO_SUPPORT);

END DATA_COLLECTION;
