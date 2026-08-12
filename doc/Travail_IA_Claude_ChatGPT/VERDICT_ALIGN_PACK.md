# VERDICT sur le patch STATIC_TYPE_ALIGN_BYTES (pragma pack) — et lot d'accompagnement

## Mon autre vision, en une phrase

Le patch est bien placé et probablement juste — mais un alignement ne corrompt
JAMAIS seul : il faut deux parties en DÉSACCORD sur la même donnée, et tant que
la seconde partie n'est pas nommée, le patch peut guérir comme il peut masquer.
Le lot ci-dessous nomme le désaccord, pose le témoin manquant (la méthode a
sauté une étape : le patch est parti sans rouge constaté), et adapte les
oracles — car changer un alignement bouge des offsets dans TOUTE la chaîne.

## Sur le patch lui-même — trois points

1. **La garde est meilleure que son apparence** : elle teste BASE (obtenu par
   SM_BASE_TYPE), donc les sous-types DN_CONSTRAINED_ARRAY d'un tableau packé
   remontent à la base porteuse de SM_IS_PACKED et déclenchent aussi. Rendre 1
   pour un tableau packé est sûr sur cette cible (LLIR/x86-64 adressé octet,
   BLKMOV par octets). Rien à retoucher au texte.
2. **L'avertissement de l'en-tête de la fonction s'applique mot pour mot** :
   « ne pas resserrer ici sans son test-miroir » (STATOFS fasmg, piège n° 110,
   chantier n° 117). Le patch resserre (1 < 2 pour un packé d'UDIGIT). À
   honorer : vérifier qu'aucun record REPRÉSENTÉ n'embarque de tableau packé
   (leurs offsets sont imposés, ils ne doivent pas bouger), et que la macro
   STATOFS de codi n'arrondit pas de son côté ce que l'expander n'arrondit
   plus.
3. **Réserve d'avenir à consigner** : `DB( SM_IS_PACKED, BASE )` sur un
   attribut JAMAIS POSÉ doit rendre FALSE. Sous T1-gnat les cellules vierges
   sont nulles — vrai. Le jour où T2 compilera l'expander (vague 4), les
   cellules vierges du bootstrappé ne sont PAS nulles (note SECV1) : ce DB
   pourrait rendre TRUE sur un tableau non packé. À mettre au piège.

## Le désaccord à nommer (vérification sur pièces, avant de clore)

La signature — quads hauts recopiés dans les quads bas, uniquement sur les
valeurs à ≥ 2 doublets — est celle d'un GLISSEMENT dans les copies ou
l'indexation de `VECTOR.D`. Les deux parties candidates :

- le TYPE-INFO de `_VECTOR` / `_VECTOR_DIGITS` (namespace émis dans
  `idl-sem_phase.FINC` : offset du champ `D`, `.size`, stride d'élément) ;
- ses CONSOMMATEURS dans `UNIV_OPS` (SPREAD, EVAL_NUM, V_MUL — indexation
  d'élément, BLKMOV de vecteurs, UNCHECKED_CONVERSION vers les attributs
  TREE).

Contrôle en quatre greps, AVANT/APRÈS patch, sur les FINC régénérés :

    grep -n -A6 "namespace _VECTOR"  IDL-SEM_PHASE.FINC
    grep -n "_VECTOR\." IDL-SEM_PHASE-UNIV_OPS.FINC | head -30
    grep -n "_VECTOR_DIGITS" IDL-SEM_PHASE.FINC | head
    diff des deux paires : le ou les nombres qui CHANGENT avec le patch
    sont le lieu exact du désaccord — le citer au journal et au piège.

## COMMIT 1 — témoin PACKV_TEST (à poser et constater ROUGE sur T1 AVANT patch,
puis VERT après — si l'AVANT n'est plus disponible, le constater au moins vert
après et le dire au journal)

### Nouveau fichier `packv_test.adb`

```ada
with TEXT_IO; use TEXT_IO;

procedure PACKV_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  type UD is range 0 .. 16_383;
  for UD'SIZE use 16;

  type DIGITS_T is array ( 1..6 ) of UD;
  pragma PACK( DIGITS_T );

  type VEC is record
    L	: NATURAL;
    S	: UD;
    D	: DIGITS_T;
  end record;
  pragma PACK( VEC );

  procedure CHECK ( COND :BOOLEAN; NUM :INTEGER ) is
  begin
    if COND then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT( "* ECHEC test" );
      PUT( INTEGER'IMAGE( NUM ) );
      NEW_LINE;
    end if;
  end CHECK;

  V	: VEC;
  W	: VEC;

begin
  V.L := 3;								--| motif SPREAD : ecriture chiffre a chiffre
  V.S := 1;
  for I in 1 .. 6 loop
    V.D( I ) := UD( I * 1000 + I );					--| 1001,2002,...,6006 : chaque case distincte
  end loop;

  CHECK( V.D( 1 ) = 1001 and V.D( 6 ) = 6006, 1 );			--| relecture indexee
  CHECK( V.L = 3 and V.S = 1, 2 );					--| les champs AVANT le tableau intacts

  W := V;								--| copie record entiere (BLKMOV .size)
  CHECK( W.D( 2 ) = 2002 and W.D( 5 ) = 5005, 3 );

  W.D( 4 ) := 4444;							--| ecriture apres copie : pas d'aliasing
  CHECK( V.D( 4 ) = 4004, 4 );

  CHECK( V.D( 1..3 ) = W.D( 1..3 ), 5 );				--| egalite de tranches packees (motif IS_ZERO)
  CHECK( not ( V.D( 3..6 ) = W.D( 3..6 ) ), 6 );

  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "PACKV_TEST PASSE" );
  else
    PUT_LINE( "PACKV_TEST ECHOUE" );
  end if;

exception
  when others =>
    PUT_LINE( "PACKV_TEST ECHOUE (EXCEPTION)" );
end PACKV_TEST;
```

## COMMIT 2 — le patch (déjà posé chez vous ; le consigner tel quel au dépôt)

## Oracles (dans l'ordre — c'est eux qui bénissent, pas moi)

1. gnat : PACKV_TEST `6 OK` / `PASSE` (juge validé).
2. T1 reconstruit AVEC patch : PACKV_TEST vert ; RECSTR/RECSTR2 verts
   (contrôles) ; les 4 greps du désaccord relevés et le nombre qui a changé
   cité au journal.
3. Filet : les FINC des témoins SANS packé BIT-IDENTIQUES ; ceux AVEC packé
   (PACKV_TEST seul a priori) listés au diff. Chaîne : diff confiné aux
   unités à tableaux packés (attendu : sem_phase et subunits UNIV_OPS/UARITH
   — `grep -ril "pragma pack" *.adb` donne la liste de référence). Trace S
   null_prog bit-exacte.
4. T2 reconstruit : sondes @PN1/2/3 = `002147483648 / 002147483648 /
   002147483647` ; puis LE JUGE FINAL : `_STANDRD_T.FINC` régénéré ≡
   `_STANDRD.FINC` À L'OCTET PRÈS après normalisation CRLF (les 6 lignes
   disparues). Si oui : retrait des sondes @PN ET @PD, commits documentation
   dus (pièges 139-142), et journal.
5. Ensuite seulement : _standrd.adb (le segfault en file).

## Documentation — PIEGES.md, après le n° 142

BLOC À INSÉRER (ancre : dernière ligne du fichier) :

```
143. **STATIC_TYPE_ALIGN_BYTES ignorait pragma PACK : les tableaux
    packes recevaient l'alignement de leur composant.** Symptome
    bootstrap : U_VALUE/UARITH corrompait les universels a >= 2
    doublets (quads hauts recopies en bas -- 2**31-1 lu 2100214748),
    6 lignes de diff sur le FINC bootstrappe de _standrd, PRINT_NUM
    innocente (RECSTR/RECSTR2 verts). Garde posee : tableau packe ->
    alignement 1 (la garde teste la BASE : les sous-types contraints
    remontent a SM_IS_PACKED). DESACCORD DES DEUX PARTIES nomme au
    journal (type-info _VECTOR vs consommateurs UNIV_OPS) -- un
    alignement seul ne corrompt pas. MIROIRS a honorer : STATOFS
    fasmg (n 110) et chantier n 117 (l'en-tete de la fonction
    l'exigeait). RESERVE vague 4 : DB(SM_IS_PACKED) sur attribut
    vierge doit rendre FALSE -- cellules vierges non nulles sous
    bootstrappe (note SECV1). Gardien : PACKV_TEST ; RECSTR_TEST et
    RECSTR2_TEST restent au filet (squelette et chair de PRINT_NUM).
    (session 9 aout)
```
