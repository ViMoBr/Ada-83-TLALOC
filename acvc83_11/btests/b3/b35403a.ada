-- B35403A.ADA

-- CHECK THAT AN INTEGER TYPE IS REJECTED IF ITS UPPER BOUND EXCEEDS 
-- SYSTEM.MAX_INT OR IF ITS LOWER BOUND IS LESS THAN SYSTEM.MIN_INT.

-- RJW 2/26/86


WITH SYSTEM; USE SYSTEM;

PROCEDURE B35403A IS
     TYPE INT1 IS RANGE MAX_INT - 1 .. MAX_INT + 1;          -- ERROR: 
                                                             -- UPPER 
                                                             -- BOUND.
     TYPE INT2 IS RANGE MIN_INT - 1 .. MIN_INT + 1;          -- ERROR: 
                                                             -- LOWER 
                                                             -- BOUND.
BEGIN
     NULL;
END B35403A;
