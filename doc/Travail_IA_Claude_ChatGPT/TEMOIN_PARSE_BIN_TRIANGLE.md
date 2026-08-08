# TÉMOIN DISCRIMINANT — parse.bin : layout, IO, ou codegen du lecteur ?

Objectif : trancher en UNE manche entre les trois suspects TLALOC-side
(le contenu de parse.bin et l'algorithme sont déjà innocentés par la
référence gnat qui parse null_prog correctement avec le MÊME fichier) :
(a) layout STATOFS du record ≠ flux d'octets écrit par gnat ;
(b) SEQUENTIAL_IO.READ TLALOC d'un élément de ~21 Ko ;
(c) codegen TLALOC des ACCÈS à la table (signature Lb/ULb/Lw,
    stride 16 bits, dispatch sur négatifs) — famille du piège n° 108.

Principe : un fichier-sonde à sentinelles CALCULABLES par champ, écrit
par gnat, relu par DEUX compilations du même lecteur (gnat et TLALOC).
Les motifs de divergence désignent le coupable ET le chantier.


## Rappel d'arithmétique de layout (pourquoi le soupçon (a) est faible)

Tailles totales égales ⇒ tailles de composants honorées (1/2/4 octets).
À composants égaux, champs en ordre de déclaration :
```
ST_TBL       @     0   (4000)
ST_TBL_LAST  @  4000   (4)
AC_SYM       @  4004   (4800)
AC_TBL       @  8804   (12000)   -- 8804 pair : aucun padding possible
AC_SYM_LAST  @ 20804   (4)
AC_TBL_LAST  @ 20808   (4)
NTER_PG      @ 20812   (255)
NTER_LN      @ 21067   (255)
NTER_LAST    @ 21322 tassé / 21324 aligné-4 (gnat)  -- SEUL jeu : 2 octets
```
Une divergence de layout ne peut toucher que NTER_LAST (débug). Le
témoin le vérifie quand même — pas de bénédiction.


====================================================================
## OUTIL 1 — PROBE_WRITE (compilé par GNAT, environnement lalr_tools)
====================================================================

```
with GRMR_TBL;

procedure PROBE_WRITE
is
  use GRMR_TBL;
begin
  for I in ST_TBL_TYPE'RANGE loop
    GRMR.ST_TBL( I ) := I * 1009 - 500_000;			-- negatifs ET positifs
  end loop;
  GRMR.ST_TBL_LAST := 16#5EED1#;

  for I in AC_SYM_TYPE'RANGE loop
    GRMR.AC_SYM( I ) := AC_BYTE( (I*7) mod 256 );		-- couvre >= 128 (test ULb)
  end loop;

  for I in AC_TBL_TYPE'RANGE loop
    GRMR.AC_TBL( I ) := AC_SHORT( ((I*13) mod 60_001) - 30_000 );	-- couvre tout le short signe
  end loop;

  GRMR.AC_SYM_LAST := 16#5EED2#;				-- magies DISTINCTES :
  GRMR.AC_TBL_LAST := 16#5EED3#;				-- tout glissement d'offset
								-- entre LAST est visible
  for I in NTER_PG_TYPE'RANGE loop
    GRMR.NTER_PG( I ) := AC_BYTE( (I*3) mod 251 );
    GRMR.NTER_LN( I ) := AC_BYTE( (I*5) mod 253 );
  end loop;
  GRMR.NTER_LAST := 16#5EED4#;

  declare
    use GRMR_TBL_IO;
    F	: GRMR_TBL_IO.FILE_TYPE;
  begin
    CREATE( F, OUT_FILE, "parse_probe.bin" );
    WRITE( F, GRMR );
    CLOSE( F );
  end;
end PROBE_WRITE;
```


====================================================================
## OUTIL 2 — PROBE_READ (Ada 83 strict, compilé DEUX FOIS :
##            par gnat -gnat83, ET par la chaîne TLALOC)
====================================================================

Auto-jugeant. Pour AC_TBL, le verdict SÉPARE cellules attendues
négatives / positives (signature Lw vs ULw) et donne la parité du
premier indice divergent (signature de stride).

```
with TEXT_IO;			use TEXT_IO;
with GRMR_TBL;

procedure PROBE_READ
is
  use GRMR_TBL;

  KO_TOTAL	: NATURAL := 0;

  procedure VERDICT( LABEL :STRING; BAD :NATURAL; FIRST :INTEGER )
  is
  begin
    if  BAD = 0  then
      PUT_LINE( LABEL & " : OK" );
    else
      PUT_LINE( LABEL & " : DIVERGE," & NATURAL'IMAGE( BAD )
	      & " cellules, premiere a l'indice" & INTEGER'IMAGE( FIRST ) );
      KO_TOTAL := KO_TOTAL + BAD;
    end if;
  end VERDICT;

  procedure SCALAR( LABEL :STRING; LU :INTEGER; ATTENDU :INTEGER )
  is
  begin
    if  LU = ATTENDU  then
      PUT_LINE( LABEL & " : OK" );
    else
      PUT_LINE( LABEL & " : DIVERGE, lu" & INTEGER'IMAGE( LU )
	      & " attendu" & INTEGER'IMAGE( ATTENDU ) );
      KO_TOTAL := KO_TOTAL + 1;
    end if;
  end SCALAR;

begin
  declare
    use GRMR_TBL_IO;
    F	: GRMR_TBL_IO.FILE_TYPE;
  begin
    OPEN( F, IN_FILE, "parse_probe.bin" );
    READ( F, GRMR );
    CLOSE( F );
  end;

  declare
    BAD	: NATURAL := 0;
    FIRST	: INTEGER := 0;
  begin
    for I in ST_TBL_TYPE'RANGE loop
      if  GRMR.ST_TBL( I ) /= I * 1009 - 500_000  then
        if  BAD = 0  then FIRST := I; end if;
        BAD := BAD + 1;
      end if;
    end loop;
    VERDICT( "ST_TBL ", BAD, FIRST );
  end;

  SCALAR( "ST_TBL_LAST ", GRMR.ST_TBL_LAST, 16#5EED1# );

  declare
    BAD	: NATURAL := 0;
    FIRST	: INTEGER := 0;
  begin
    for I in AC_SYM_TYPE'RANGE loop
      if  GRMR.AC_SYM( I ) /= AC_BYTE( (I*7) mod 256 )  then
        if  BAD = 0  then FIRST := I; end if;
        BAD := BAD + 1;
      end if;
    end loop;
    VERDICT( "AC_SYM ", BAD, FIRST );
  end;

  declare
    BAD_NEG	: NATURAL := 0;					-- attendu < 0 : juge la charge SIGNEE (Lw)
    BAD_POS	: NATURAL := 0;					-- attendu >= 0
    FIRST	: INTEGER := 0;
    ATTENDU	: INTEGER;
  begin
    for I in AC_TBL_TYPE'RANGE loop
      ATTENDU := ((I*13) mod 60_001) - 30_000;
      if  GRMR.AC_TBL( I ) /= AC_SHORT( ATTENDU )  then
        if  BAD_NEG + BAD_POS = 0  then FIRST := I; end if;
        if  ATTENDU < 0  then BAD_NEG := BAD_NEG + 1;
	          else  BAD_POS := BAD_POS + 1;
        end if;
      end if;
    end loop;
    VERDICT( "AC_TBL (attendus negatifs)", BAD_NEG, FIRST );
    VERDICT( "AC_TBL (attendus positifs)", BAD_POS, FIRST );
    if  BAD_NEG + BAD_POS > 0  then
      if  FIRST mod 2 = 0  then
        PUT_LINE( "AC_TBL : premier divergent PAIR" );
      else
        PUT_LINE( "AC_TBL : premier divergent IMPAIR" );
      end if;
    end if;
  end;

  SCALAR( "AC_SYM_LAST ", GRMR.AC_SYM_LAST, 16#5EED2# );
  SCALAR( "AC_TBL_LAST ", GRMR.AC_TBL_LAST, 16#5EED3# );

  declare
    BAD	: NATURAL := 0;
    FIRST	: INTEGER := 0;
  begin
    for I in NTER_PG_TYPE'RANGE loop
      if  GRMR.NTER_PG( I ) /= AC_BYTE( (I*3) mod 251 )  then
        if  BAD = 0  then FIRST := I; end if;
        BAD := BAD + 1;
      end if;
    end loop;
    VERDICT( "NTER_PG", BAD, FIRST );
  end;

  declare
    BAD	: NATURAL := 0;
    FIRST	: INTEGER := 0;
  begin
    for I in NTER_LN_TYPE'RANGE loop
      if  GRMR.NTER_LN( I ) /= AC_BYTE( (I*5) mod 253 )  then
        if  BAD = 0  then FIRST := I; end if;
        BAD := BAD + 1;
      end if;
    end loop;
    VERDICT( "NTER_LN", BAD, FIRST );
  end;

  SCALAR( "NTER_LAST ", GRMR.NTER_LAST, 16#5EED4# );

  if  KO_TOTAL = 0  then
    PUT_LINE( "PROBE PASSE" );
  else
    PUT_LINE( "PROBE ECHOUE" );
  end if;

end PROBE_READ;
```


====================================================================
## PROTOCOLE ET TABLE DE DÉCISION
====================================================================

1. `PROBE_WRITE` (gnat) → parse_probe.bin.
2. `PROBE_READ` compilé par gnat -gnat83, exécuté → doit dire
   « PROBE PASSE » (sinon : bug de la sonde elle-même, improbable).
3. `PROBE_READ` compilé par la chaîne TLALOC, exécuté sur le même
   fichier.

| gnat-READ | TLALOC-READ | Verdict |
|---|---|---|
| PASSE | PASSE | parse.bin, layout, SEQUENTIAL_IO et les accès élémentaires sont INNOCENTS. Le bug est dans la BOUCLE du parser (dispatch des classes de valeurs, arithmétique des réductions) — session PAR_PHASE sur sources + FINC. |
| PASSE | ÉCHOUE | Codegen/IO TLALOC coupable ; la signature désigne le chantier : AC_TBL négatifs seuls → charge 16 bits non signée (ULw au lieu de Lw) ; AC_SYM à partir de valeurs ≥ 128 → Lb au lieu de ULb (réplique n° 108, vérifier le chemin composant-de-tableau) ; un indice sur deux → stride 16 bits ; tout un champ à partir d'un offset → layout STATOFS ou READ ; seul NTER_LAST → le pad de 2 octets (bénin, à consigner). |
| ÉCHOUE | — | Sonde ou WRITE en cause ; reprendre ici. |

Complément instantané, sans nouvelle sonde : le même PROBE_READ amputé
de ses vérifications, réduit à l'impression des quatre LAST et de
AC_SYM(1..10) / AC_TBL(1..10) du VRAI parse.bin, compilé des deux
côtés — la concordance des trois premiers LAST innocente layout + IO
jusqu'à l'offset 20812 en une exécution.


====================================================================
## SUITE — quel que soit le verdict
====================================================================

Pour la manche suivante (le site exact de l'erreur), il faudra la
session PAR_PHASE de votre propre guide d'upload :
- src/par_phase/ : grmr_tbl.ads (complet), grmr_ops.adb, lex.adb,
  idl-par_phase.adb — et notamment le site qui imprime
  « ERREUR DE SYNTAXE - OG » (que signe le tag OG ?) ;
- le FINC généré pour les zones d'accès AC_TBL / AC_SYM de la boucle
  (les Lw/ULb et le dispatch par classes de valeurs).

Indice comportemental à garder en tête : deux tokens décalés
proprement, échec au premier pas non trivial (première valeur négative
d'AC_TBL ou premier code ≥ 1000) — la signature d'une CLASSE de valeur
mal lue, pas d'un fichier décalé, qui casserait au token 1.
