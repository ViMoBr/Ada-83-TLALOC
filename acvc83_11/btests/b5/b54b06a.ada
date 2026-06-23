-- B54B06A.ADA

-- OBJECTIVE:
--     CHECK THAT IF THE CASE EXPRESSION IS AN ENUMERATION LITERAL, ALL
--     THE VALUES OF THE LITERAL'S BASE TYPE MUST BE COVERED IF OTHERS
--     IS OMITTED.

-- HISTORY:
--     BCB 02/29/88  CREATED ORIGINAL TEST.

PROCEDURE B54B06A IS

     TYPE ENUM IS (JOHN, VINCE, TOM, DOUG, BRIAN, PHIL, ROSA, JODIE);

BEGIN
     CASE JOHN IS                                      -- OK.
         WHEN JOHN  => NULL;
         WHEN VINCE => NULL;
         WHEN TOM   => NULL;
         WHEN DOUG  => NULL;
         WHEN BRIAN => NULL;
         WHEN PHIL  => NULL;
         WHEN ROSA  => NULL;
         WHEN JODIE => NULL;
     END CASE;

     CASE VINCE IS                                     -- OK.
         WHEN JOHN   => NULL;
         WHEN VINCE  => NULL;
         WHEN TOM    => NULL;
         WHEN DOUG   => NULL;
         WHEN BRIAN  => NULL;
         WHEN PHIL   => NULL;
         WHEN ROSA   => NULL;
         WHEN OTHERS => NULL;
     END CASE;

     CASE TOM IS                                       -- ERROR:
         WHEN JOHN   => NULL;
         WHEN VINCE  => NULL;
         WHEN TOM    => NULL;
         WHEN DOUG   => NULL;
         WHEN BRIAN  => NULL;
         WHEN PHIL   => NULL;
         WHEN ROSA   => NULL;
     END CASE;

END B54B06A;
