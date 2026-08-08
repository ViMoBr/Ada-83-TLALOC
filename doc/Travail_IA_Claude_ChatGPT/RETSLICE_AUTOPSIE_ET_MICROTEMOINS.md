# RETSLICE A MORDU DEUX FOIS — séparation des prises et micro-témoins

## 1. CE QUE LE CRASH ÉTABLIT (lecture du FINC joint + registres)

**Prise n° 1 — R1 A ÉCHOUÉ (la proie D-C7a est réelle).** Le code qui
segfaulte (boucle lods/stos = expansion BLKMOV) n'existe que dans la
branche ECHEC de CHECK : la branche a donc été PRISE — `TS = "NULL_PROG"`
a rendu FAUX (ou le booléen est arrivé corrompu, ce qui est une variante
de la même prise). La chaîne de retour de tranche dynamique est cassée
quelque part de réel, comme F2 le prédisait.

**Prise n° 2 — le chemin d'impression ECHEC segfaulte (le frère du
message « OG »).** Le BLKMOV fautif a dépilé, de haut en bas,
[9, 0x40b0e8, 0] là où l'émission attendait [@"ECHEC ", 6, @covar] :
- 0x40b0e8 est une adresse de CO-PILE (r13=0x40b0e0, r14=0x40b228 au
  fault) — c'est très vraisemblablement la valeur @covar attendue en
  DEST, lue UN CRAN TROP HAUT (en COUNT) ;
- le « 9 » au sommet est un fantôme — et 9 est la longueur du résultat
  de TS du site appelant ;
- la pile d'évaluation est décalée d'un cran dans le corps de CHECK.
C'est un concat avec un FORMEL composite dans un PRO de niveau 2 — la
même famille de constructions qui a fabriqué « OG » dans ERR_PHASE. Un
seul défaut peut nourrir les deux.

**Ce que la lecture statique a innocenté** (pour ne pas y retourner) :
le PRO TS lui-même est propre sur le papier — doublet source correct,
info COPIÉE PAR VALEUR (16 octets) dans la zone info de l'appelant
AVANT l'UNLINK, data écrite par SIq dans le doublet appelant : pas de
lecture fantôme dans le modèle. Le site R1 est propre : lieu-résultat
doubletté, ordre des actuels conforme, extraction et CEQ/BLKCMP
réguliers. La séquence de CHECK est équilibrée instruction par
instruction SI mes sémantiques de macros sont bonnes — d'où le point
suivant.

## 2. DÉCOUVERTE BLOQUANTE : mon codi_x86_64.finc n'est pas celui du build

`LVA` — employé par tous les FINC — n'est DÉFINI NULLE PART dans
l'exemplaire de codi_x86_64.finc du projet (grep exhaustif). Le build
assemble : la définition existe donc ailleurs (codi plus récent, ou
include séparé). CONSÉQUENCE : toute simulation pile-exacte au niveau
codi est suspecte tant que je n'ai pas le jeu de macros RÉEL.

**Demande n° 1 : joindre le(s) .finc de macros effectivement inclus par
le build** (au minimum la définition de LVA ; idéalement le codi
courant complet si l'exemplaire du projet a vieilli). Les macros que
j'ai pu lire et sur lesquelles je m'appuie déjà : BLKMOV (pops SRC,
COUNT, DEST — donc pousser DEST, LEN, SRC), CO_VAR (pop taille, push
r14, avance r14), La=Lq (push [frame(lvl)+disp]), LId (push dword à
[[frame+disp]+ofs]), Sa/Sd (pop), SIq (pop data, range à [[slot]+ofs]).

## 3. DEUX MICRO-TÉMOINS SÉPARATEURS (dual-build, comme d'habitude)

Chacun isole UNE prise avec le minimum de machinerie — leurs FINC
feront quelques dizaines de lignes, et gdb y devient trivial.

### RETMICRO1 — la chaîne de retour seule, sans CHECK, sans concat

```
with TEXT_IO;			use TEXT_IO;

procedure RETMICRO1
is
  BUF	: STRING( 1..255 );
  LEN	: NATURAL := 0;

  function TS return STRING
  is
  begin
    return BUF( 1..LEN );
  end TS;

  R9	: STRING( 1..9 );
  N	: NATURAL;

begin
  BUF( 1..9 ) := "NULL_PROG";
  LEN := 9;

  PUT( "M1 brut    [" );
  PUT( TS );						-- consommation la plus directe
  PUT_LINE( "]" );

  R9 := TS;						-- affectation depuis le resultat
  PUT( "M2 affecte [" );
  PUT( R9 );
  PUT_LINE( "]" );

  if  TS = "NULL_PROG"  then				-- l'egalite de R1, jugee sans CHECK
    PUT_LINE( "M3 egalite VRAI" );
  else
    PUT_LINE( "M3 egalite FAUX" );
  end if;

  N := 0;						-- longueur observee, sans 'LENGTH ni concat
  for I in 1..9 loop
    if  R9( I ) = "NULL_PROG"( I )  then
      N := N + 1;
    end if;
  end loop;
  PUT( "M4 octets egaux :" );
  PUT( NATURAL'IMAGE( N ) );
  NEW_LINE;

  PUT_LINE( "RETMICRO1 FIN" );
end RETMICRO1;
```

Attendu :
```
M1 brut    [NULL_PROG]
M2 affecte [NULL_PROG]
M3 egalite VRAI
M4 octets egaux : 9
RETMICRO1 FIN
```
Lecture : M1 faux/partiel → le doublet résultat lui-même (modèle C7 ou
consommateur PUT) ; M1 bon mais M3 FAUX → la comparaison composite sur
résultat de fonction ; M2 partiel → l'affectation depuis le résultat.
M4 compte les octets un à un dans R9 : il dit ce qui a VRAIMENT été
copié, indépendamment de toute longueur de doublet.

### RETMICRO2 — le chemin ECHEC seul, sans TS, sans tranche dynamique

```
with TEXT_IO;			use TEXT_IO;

procedure RETMICRO2
is
  procedure P( LABEL :STRING )				-- la forme exacte de CHECK/ECHEC
  is
  begin
    PUT_LINE( "ECHEC " & LABEL );
  end P;

begin
  P( "R1 egalite directe" );				-- l'appel exact du site R1
  PUT_LINE( "RETMICRO2 FIN" );
end RETMICRO2;
```

Attendu : `ECHEC R1 egalite directe` puis `RETMICRO2 FIN`.
S'il segfaulte comme CHECK : la prise n° 2 est INDÉPENDANTE de D-C7a —
concat avec formel composite dans un PRO imbriqué — et son FINC
minuscule devient la table d'autopsie. S'il passe : la prise n° 2
dépend d'un état laissé par la chaîne TS (le « 9 » fantôme prend alors
tout son poids), et on l'attaquera après la prise n° 1.

## 4. COMPLÉMENT GDB SUR RETSLICE (deux commandes, si la session est
     encore chaude)

Au point du fault :
```
(gdb) x/8gx $rbp-56          # la fenetre de pile d'evaluation sous le BLKMOV
(gdb) info symbol 0x40b0e8   # confirmer la nature co-pile de la fausse "longueur"
```
Et un point d'arrêt `b *0x4068E9` (CHECK_L6) au run suivant, puis
`x/4gx $rbp-24` À L'ENTRÉE : on verra les DEUX slots de paramètres
(LABEL, COND) tels que reçus — tranchant net si le booléen arrive
corrompu (prise 1 en amont) ou sain (prise 2 pure).

## 5. ORDRE DE MARCHE PROPOSÉ

1. RETMICRO2 (10 lignes, verdict immédiat sur la prise n° 2).
2. RETMICRO1 (verdict ventilé sur la prise n° 1).
3. Le jeu de macros réel du build (demande n° 1).
Avec ces trois pièces, la manche suivante est correctionnelle : les
FINC des micro-témoins sont assez petits pour une autopsie
instruction par instruction contre les vraies macros, et les
correctifs repartiront au protocole ancré habituel — chacun avec son
témoin déjà en place.
