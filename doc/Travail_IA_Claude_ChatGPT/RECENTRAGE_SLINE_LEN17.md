# RECENTRAGE — la chaîne se referme sur GET_LINE( IFILE, SLINE.BDY, SLINE.LEN )

## 1. CE QUE VOTRE DEBUG ÉTABLIT (et qui corrige mon dossier)

`Source Line={procedure NULL_PR}` = 17 caractères = BDY(1..17) de la
ligne correcte : **BDY est bien rempli, c'est SLINE.LEN qui vaut 17**.
Conséquences en cascade, toutes vérifiées sur les traces déjà en main :
- le scanner est INNOCENT : la boucle meurt par la garde
  `W_COL <= LINE_LENGTH` (17) → CHR := ' ' → ACCEPT → NULL_PR ; les
  lectures directes `_STRING._LST` de CODE_INDEXED (mon dossier
  précédent) ne sont que spectatrices ici — leur défaut reste réel
  mais n'est PAS le mécanisme de cette panne ;
- si GET_LINE s'est ARRÊTÉ à 17 (voir §2), « OG » reste dans le
  fichier → la « ligne 2 » suivante est « OG » → token OG en (2,1)
  → ERREUR DE SYNTAXE avec tranche BDY(1..2) = « OG » : le message,
  la position, le caret col 1 — TOUTE la pièce « OG » se referme
  enfin, sans mécanisme d'affichage exotique.

## 2. LE MÉCANISME, ÉCRIT DANS VOTRE FINC

Au site d'appel (SELARG de l'actual out composite sélectionné) :
```
	LIVA 	0, STANDARD.LEX.SLINE_disp, STANDARD.LEX._LINE_OF_SOURCE.BDY
	Sa	3, SELARG_L20_disp
	La 0, STANDARD._STRING.use__info          ← __u du doublet BDY
	Sa	3, SELARG_L20__u                     =  LE BLOC PARTAGÉ DU TYPE DE BASE
```
Et à l'élaboration du record (votre LEX.FINC) :
```
USEINFO 0, BDY, 	La 0, STANDARD._STRING.use__info
```
Le doublet remis à GET_LINE porte comme info **le bloc statique partagé
de STANDARD._STRING** — pas les bornes du composant (1..255). GET_LINE
consulte légitimement les bornes d'ITEM par ce doublet : si le bloc
partagé dit LST = 17 à cet instant, GET_LINE remplit/rend 17. Le
composant `BDY : STRING(1..MAX_STRING)` n'a NULLE PART de bloc de
bornes à lui : l'élaboration du record a pris la branche « type
nommé » (USEINFO vers le use__info du nom résolu = le base _STRING),
pas la branche DN_CONSTRAINED_ARRAY (namespace local + PROCESS_
CONSTRAINED_ARRAY_TYPE_SPEC). Autrement dit : **SM_OBJ_TYPE de BDY
résout au STRING de base, la contrainte (1..MAX_STRING) est perdue en
amont de l'expander** — à vérifier au point 5.

Note de cohérence : LEX_ECHO passait — sa variable ÉTAIT locale
(`BDY : STRING(1..255)` objet), avec son propre `_BDY__type` élaboré
et un __u sain. Le bug exige le COMPOSANT DE RECORD. Le témoin du §4
reproduit exactement cela.

## 3. MICRO-VÉRIFICATION m1/m2 (une ligne de debug de plus)

Après le GET_LINE, imprimer AUSSI `SLINE.BDY( 18..19 )` :
- « OG » présent → GET_LINE a ÉCRIT les 19 caractères mais rendu
  LAST = 17 (m2 : la borne coupe le calcul de LAST, pas le
  remplissage) ;
- résidu autre → GET_LINE s'est ARRÊTÉ à 17 et « OG » est resté dans
  le FICHIER (m1) — c'est m1 qui prédit la pseudo-ligne « OG » et
  ferme la pièce du message ; si m2, « OG » du message vient du
  résidu du tampon et la ligne 2 lue ensuite est « is » — la trace
  LEX_DEBUG (Source Line={...} de la ligne suivante) tranche de
  toute façon.

## 4. TÉMOIN GETREC — le motif exact, en quinze lignes (dual build)

```
with TEXT_IO;			use TEXT_IO;

procedure GETREC
is
  type LIGNE	is record
		  LEN	: NATURAL;
		  BDY	: STRING( 1..255 );
		end record;

  F	: FILE_TYPE;
  SL	: LIGNE;
  N	: NATURAL := 0;
begin
  OPEN( F, IN_FILE, "null_prog.adb" );
  while  not END_OF_FILE( F )  loop
    N := N + 1;
    GET_LINE( F, SL.BDY, SL.LEN );
    PUT( "LIGNE" & NATURAL'IMAGE( N ) & " LEN" & NATURAL'IMAGE( SL.LEN ) & " [" );
    if  SL.LEN > 0  then
      PUT( SL.BDY( 1..SL.LEN ) );
    end if;
    PUT_LINE( "]" );
  end loop;
  CLOSE( F );
  PUT_LINE( "GETREC FIN" );
end GETREC;
```
LEX_ECHO (variable locale) passe ; GETREC (composant de record) doit
reproduire LEN=17 côté bootstrappé si le diagnostic est bon — et son
FINC minuscule est le banc de correction. Variante à ajouter au besoin :
le même record déclaré dans un PAQUETAGE (le cas SLINE exact).

## 5. LES DEUX QUESTIONS QUI FIXENT LE CORRECTIF

1. **Où la contrainte de BDY se perd-elle ?** Votre outil le dit sans
   nouvelle instrumentation : `PRETTY_DIANA` (option U) sur lex — le
   nœud de BDY : SM_OBJ_TYPE pointe-t-il un DN_CONSTRAINED_ARRAY
   (alors c'est PROCESS_INSERT_ONE_COMPONENT qui l'a mal classé) ou
   directement le DN_ARRAY de base (alors la contrainte est perdue au
   front-end / à la sémantique, et le correctif est en amont) ?
2. **Que contient STANDARD._STRING et qui y a écrit 17 ?** Le
   watchpoint du dossier précédent reste l'instrument (une exécution,
   PC de chaque écrivain) — avec en plus la valeur INITIALE du bloc
   après l'élaboration de STANDARD (si LST y est déjà petit, même la
   lecture de CMD_FROM_STDIN au démarrage passe par cette jointure et
   la question de sa survie se pose ; si LST démarre grand et devient
   17, le piétineur existe et se nomme au premier arrêt).

Le correctif — donner au composant ses bornes propres (bloc élaboré du
sous-type contraint anonyme, ou immédiats statiques) et faire pointer
USEINFO/SELARG dessus — s'écrira au protocole ancré une fois 5.1
tranché, avec GETREC au filet et l'oracle d'identité d'émission sur le
corpus (leçon du commit 4).
