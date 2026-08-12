# DIAGNOSTIC — les nombres corrompus sont tous des 2**k : triangulation UARITH

## Re-dérivation après deux témoins verts

RECSTR_TEST et RECSTR2_TEST verts : le motif d'impression (récursion en
caténation, tranches pleines, agrégat à bornes dynamiques, SHORT représenté,
mod) est SAIN sous T1 — PRINT_NUM est présumé innocent. Relecture des six
lignes du diff : `2147483647` = 2**31−1, `536870912` = 2**29,
`−17179869184` = −2**34 — TOUTES les valeurs corrompues sont des puissances
de deux CALCULÉES (le source _standrd.ads écrit `2**31-1`, pas le littéral),
donc produites par UARITH **sous T2** — le territoire ouvert au lot
opérateurs — pendant que toute valeur tenant en UN doublet d'attribut
(≤ 8 chiffres : 2**15, offsets, codes) est juste. Corrélation parfaite :
corruption ⟺ résultat UARITH sur ≥ 2 attributs ⟺ propagation
multi-précision (retenue/report entre doublets) du code d'UARITH émis par T1.
Le motif « 4 premiers chiffres justes puis les 8 premiers recopiés » devient
une signature de PROPAGATION : l'attribut haut juste, l'attribut bas
recevant une copie décalée du haut.

Trois sondes @PN départagent U_VALUE (analyse de littéral), `**`
(multiplication multi-précision) et l'impression en contexte réel — en un run.

## COMMIT DIAG — sondes @PN dans idl-sem_phase-fix_pre.adb (1 modification)

ANCRE (texte existant, inchangé, unique — les sondes s'insèrent APRÈS le
bloc @PD3 déjà en place, donc immédiatement AVANT cette ligne) :

```ada
         ID_LIST := NEW_ID_LIST;
```

BLOC À SUPPRIMER : (néant — insertion AU-DESSUS de l'ancre)

BLOC À INSÉRER :

```ada
         declare
	    use UARITH;
	    PA	: TREE	:= U_VALUE( "2147483648" );
	    PB	: TREE	:= U_VALUE( "2" ) ** U_VALUE( "31" );
	    PC	: TREE	:= U_VALUE( "2" ) ** U_VALUE( "31" ) - U_VALUE( "1" );
         begin
	    PUT( "@PN1 " );
	    PUT_LINE( PRINT_NUM( PA ) );
	    PUT( "@PN2 " );
	    PUT_LINE( PRINT_NUM( PB ) );
	    PUT( "@PN3 " );
	    PUT_LINE( PRINT_NUM( PC ) );
         end;
```

## Oracle du run diagnostic

Recompiler FIX_PRE, relancer les DEUX compilateurs sur `_standrd.ads` :

- TLALOC(gnat), référence attendue :
  `@PN1 2147483648` / `@PN2 2147483648` / `@PN3 2147483647`.
- TLALOC(TLALOC), grille :
  1. @PN1 FAUX → U_VALUE : l'ANALYSE du littéral casse déjà la propagation
     multi-doublets (acc × 10 + chiffre à travers la frontière d'attribut) —
     ou PRINT_NUM en contexte réel malgré les témoins ; le point 3 tranche.
  2. @PN1 JUSTE, @PN2 FAUX → la MULTIPLICATION multi-précision de `**` ;
     @PN3 dira si la soustraction aggrave ou suit.
  3. @PN1 et @PN2 JUSTES, mais les LI du FINC toujours faux → alors c'est
     bien l'impression/lecture en contexte réel (niveau d'imbrication,
     DABS/UNCHECKED_CONVERSION) — on itérera sur PRINT_NUM in situ.
  4. Tout JUSTE et FINC devenu juste → non-reproductible : me le dire.

## Pièces à joindre au retour (avec les 6 lignes @PN des deux runs)

- **idl-sem_phase-uarith.adb** et **IDL-SEM_PHASE-UARITH.FINC** — demandés
  aux deux lots précédents, jamais encore joints : quel que soit le verdict
  de la grille, la famille vit dedans, et le correctif devra s'y ancrer.
- Le diff FINC de `_standrd` régénéré après ce run (les 6 lignes doivent
  être inchangées : les sondes ne touchent pas l'émission).

Retrait des sondes @PN avec les @PD au commit de clôture, même protocole.
