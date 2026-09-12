procedure POW_PROBE is
-- Sonde du 30/07 : resolution de "**" par le front-end TLALOC.
-- Resultat : ACCEPTEES = formes 3 et 5 (exposant LITTERAL seulement) ;
-- REJETEES << DESACCORD DE TYPE >> = 1, 2, 4, 6, 7.
-- Temoin FUTUR du chantier sem_phase (cf. carnet ETAT_PILIERS).
  V : INTEGER := 0;
  X : INTEGER := 3;
  N : INTEGER := 4;
  M : NATURAL := 4;
  C : constant INTEGER := 4;
begin
  V := X ** N;          -- 1 : var ** var (INTEGER)          REJETEE
  V := X ** M;          -- 2 : var ** var (NATURAL)          REJETEE
  V := X ** 4;          -- 3 : var ** litteral               ACCEPTEE
  V := 3 ** N;          -- 4 : litteral ** var               REJETEE
  V := 3 ** 4;          -- 5 : litteral ** litteral          ACCEPTEE
  V := X ** C;          -- 6 : var ** constante nommee       REJETEE
  V := 2 ** N;          -- 7 : la forme du pli, exposant var REJETEE
end POW_PROBE;
