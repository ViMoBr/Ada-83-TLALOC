-- BD3001B.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENUMERATION REPRESENTATION CLAUSE CANNOT BE GIVEN
--     FOR A NAME DECLARED BY AN OBJECT OR SUBTYPE DECLARATION, OR FOR
--     A PRIVATE OR INCOMPLETE TYPE PRIOR TO THE FULL DECLARATION.

-- HISTORY:
--     DHH 8/22/88 CREATED ORIGINAL TEST.

PROCEDURE BD3001B IS

     TYPE ENUM IS (A,B,C,D,E);

     TYPE ENUM1 IS (A,B,C,D,E);
     SUBTYPE ENUM1A IS ENUM1;

     FOR ENUM1A USE (1, 2, 3, 4, 5);                          -- ERROR:

     OBJ : ENUM;

     FOR OBJ USE (1, 2, 3, 4, 5);                             -- ERROR:

     PACKAGE P IS
          TYPE ENUM;
          TYPE ACC_ENUM IS ACCESS ENUM;

          FOR ENUM USE (1, 2, 3, 4, 5);                       -- ERROR:

          TYPE ENUM IS (A,B,C,D,E);

          TYPE PRIV IS PRIVATE;
          TYPE PRIV1 IS PRIVATE;

          FOR PRIV1 USE (1, 2, 3, 4, 5);                      -- ERROR:

     PRIVATE
          FOR PRIV USE (1, 2, 3, 4, 5);                       -- ERROR:

          TYPE PRIV IS (A,B,C,D,E);
          TYPE PRIV1 IS (A,B,C,D,E);
     END P;
BEGIN
     NULL;
END BD3001B;
