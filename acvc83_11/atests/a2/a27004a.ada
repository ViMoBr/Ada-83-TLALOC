-- A27004A.ADA

-- CHECK THAT EVERY GRAPHIC CHARACTER CAN APPEAR IN A COMMENT.

-- RJW 2/27/86

WITH REPORT; USE REPORT;

PROCEDURE A27004A IS

BEGIN

     TEST ("A27004A", "CHECK THAT EVERY GRAPHIC CHARACTER CAN " &
                      "APPEAR IN A COMMENT." );

     BEGIN
          -- ABCDEFGHIJKLMNOPQRSTUVWXYZ
          -- 0123456789
          -- " # & ' ( ) * + , - . / : ; < = > _ |
          -- => <=  THE SPACE CHARACTER
          -- abcdefghijklmnopqrstuvwxyz
          -- ! $ % ? @ [ \ ] ^ ` { } ~
          NULL;
     END;
     
     RESULT;

END A27004A;
