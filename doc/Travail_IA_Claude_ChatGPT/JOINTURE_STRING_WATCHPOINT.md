# LA JOINTURE FRAGILE `_STRING` — lecteur, écrivain(s), et l'instrument
# qui les confond en un run

## 1. CE QUI EST ÉTABLI (source + FINC + trace instrumentée)

**Le lecteur.** CODE_INDEXED, cas préfixe DN_COMPONENT_ID
(`USE_TYPE_INFO_DIRECT`, expressions l. 1036-1045 + les trois branches
de INDEX l. 901-991) : pour `SL.BDY( W_COL )`, EXP_TYPE remonte au type
de base et l'émission lit les bornes EN DIRECT dans
`STANDARD._STRING._FST_1 / _LST_1 / _COMP_SIZ` — le bloc statique
PARTAGÉ du type de base. Le FINC joint le montre aux deux occurrences
du rechargement (les deux `if W_COL <= LINE_LENGTH`). Contraste dans le
MÊME fragment : le rangement `TEXT(TOKEN_LENGTH) := CHR` lit ses bornes
par l'objet (`LId 0, TEXT__u, STANDARD._STRING.FST_1` — indirect,
offsets seulement) — le chemin sain.

**Le comportement.** À l'exécution du bootstrappé, ce bloc partagé
contient LST = 17 : les recharges passent pour W_COL = 12..17 et la
boucle meurt à W_COL = 18 — exactement l'arrêt %U%L%L%P%R observé,
TOKEN_LENGTH = 7, NULL_PR. Et 17 = la longueur de « ././null_prog.adb »
— une valeur d'EXÉCUTION, pas une borne statique : le bloc est PIÉTINÉ
par un écrivain runtime. (Même famille que F-c : la poubelle changeante
des défauts de MAKE.)

**La jointure.** expander-declarations-types_decls, INSERE_LES_CHAMPS /
PROCESS_INSERT_ONE_COMPONENT : un composant DN_CONSTRAINED_ARRAY
anonyme s'élabore sous COMP_TYPE_STR = '_' & nom-du-type-SOURCE — donc
littéralement `namespace _STRING` — avec PROCESS_CONSTRAINED_ARRAY_
TYPE_SPEC (écriture des bornes) et un USEINFO vers
`..._STRING.use__info`. Selon la RÉGION où ce namespace s'ouvre et
selon ce que résout REGIONS_PATH côté lecteurs, écrivains et lecteurs
peuvent viser DEUX blocs `_STRING` distincts — ou pire, le bloc partagé
de STANDARD peut servir de __u à des doublets qui reçoivent ensuite la
COPIE D'INFO de 16 octets du protocole C7 (le BLKMOV du retour) : un
seul retour de fonction à travers un tel doublet ÉCRASE les bornes du
type de base pour tout le programme. Un résultat de 17 caractères — le
chemin du fichier — colle à ce mécanisme.

TROIS hypothèses d'écrivain, indiscernables sans mesure :
- E1 : une élaboration de composant/objet anonyme qui écrit dans le
  bloc de STANDARD au lieu du sien (collision de namespace) ;
- E2 : la copie d'info C7 d'un retour de fonction à travers un doublet
  dont __u pointe le bloc partagé (branche « tableau contraint » du
  lieu-résultat quand le sous-type résout au nom de base) ;
- E3 : un troisième écrivain non encore imaginé.
On ne bénit pas : on mesure.

## 2. L'INSTRUMENT — point de surveillance matériel (un run, verdict)

1. Obtenir l'adresse du bloc : dans le listing fasmg (ou via un
   hexa_show ponctuel), les adresses de
   `STANDARD._STRING.SIZ / ._COMP_SIZ / ._FST_1 / ._LST_1`
   (4 dwords contigus).
2. Sous gdb, sur le bootstrappé :
```
(gdb) break *<adresse de l'entrée du main>        # ou start équivalent
(gdb) run ./ ./null_prog.adb S
(gdb) watch *(int*)<ADDR__LST_1>
(gdb) continue
```
3. Chaque arrêt donne le PC de l'ÉCRIVAIN → votre map → le site FINC.
   Attendu : un premier train d'écritures À L'ÉLABORATION (légitimes —
   noter lesquelles : elles disent QUI possède ce bloc par conception),
   puis L'ÉCRITURE DE 17 — le piétineur, nommé par son PC. Noter aussi
   `print *(int*)<ADDR__FST_1>` à cet instant (FST piétiné aussi ?
   pertinent pour « OG »).
4. Si les watchpoints matériels manquent (4 max) : surveiller _LST_1
   seul suffit.

## 3. LES PIÈCES POUR LA MANCHE CORRECTIONNELLE

- Le fragment LEX.FINC de l'ÉLABORATION du type LINE_OF_SOURCE (les
  lignes `namespace _STRING` / USEINFO / PROCESS_CONSTRAINED... émises
  pour BDY) — il dit dans QUELLE région le bloc écrivain vit, à
  confronter au `STANDARD._STRING` du lecteur ;
- les adresses map du §2 (contrôle croisé) ;
- la sortie du watchpoint (PC des écrivains + valeurs).

## 4. LE CORRECTIF ATTENDRA CES PIÈCES — et sa forme en dépend

Deux issues propres possibles, incompatibles, que les pièces
départagent :
- si la CONCEPTION veut des blocs `_STRING` par région (composants
  anonymes) : le LECTEUR est fautif (CODE_INDEXED doit adresser le
  bloc de la région du composant — correctif REGIONS_PATH côté
  USE_TYPE_INFO_DIRECT), et le bloc de STANDARD n'aurait jamais dû
  être consulté ;
- si le bloc de base doit rester IMMUABLE et canonique (FST=1,
  COMP=8, LST = borne du base) : le lecteur est légitime et c'est
  l'ÉCRIVAIN (E1 ou E2) qu'on corrige — E2 signifierait un défaut de
  protocole (info de type partagée utilisée comme réceptacle d'info
  de résultat), à corriger dans la branche contrainte du
  lieu-résultat (copie vers un bloc anonyme local, jamais vers
  use__info d'un type).
Dans les deux cas : commit ancré + témoin (record à composant STRING
anonyme, indexé sur toute sa plage APRÈS un appel de fonction à
résultat chaîne — le motif exact de la collision) + l'oracle
d'identité d'émission sur tout le corpus (leçon du commit 4).

NB — « OG » : si FST_1 est piétiné lui aussi (à 18 ?), le message
d'erreur s'explique enfin par le même mécanisme (bornes du slice du
message lues/contrôlées contre le bloc piétiné). Le §2 le dira au
passage.
