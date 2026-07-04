# D7 — Bornage à zéro des longueurs dynamiques (pilier 3.6)

**Date** : 4 juillet 2026
**Motivation double** :
1. *Sémantique* : `P'LENGTH` doit rendre **0 pour un intervalle nul** (LRM annexe A) ;
   les trois chemins de CODE_LENGTH rendent aujourd'hui `LST−FST+1` négatif.
2. *Sûreté* : tout compte négatif transmis à `CO_VAR` (allocation co-pile) ou multiplié
   puis passé à `BLKMOV` (compteur RCX) produit une allocation absurde ou une copie
   géante. Les tableaux nuls et tranches nulles sont légaux et fréquents (3.6.1).

## 1. Macro LLIR `CLAMP0` (codi_x86_64.finc)

Remplace le sommet de pile par max(0, sommet). Sans branchement, pas de label.

```asm
;			------
macro			CLAMP0?				; sommet := max( 0, sommet )
;			------
	POP_RAX
	xor	edx, edx
	test	rax, rax
	cmovs	rax, rdx				; 48 0F 48 C2 si le mnemonique pose probleme a fasmg
	PUSH_RAX
end macro
```

(Adapter POP_RAX/PUSH_RAX aux idiomes exacts du finc — mêmes primitives que CALLI.
Si `cmovs` s'encode mal, piège de la famille 14/15/16 : `db 0x48,0x0F,0x48,0xC2`.)

## 2. Les 13 sites — ajouter `PUT_LINE( tab & "CLAMP0" );` après chaque paire SUB/INC

| # | Fichier : lignes | Contexte | Nature |
|---|---|---|---|
| 1 | expressions.adb 920-921 | CODE_SLICE : compte de la tranche (_LST_1−_FST_1+1) | sûreté (BLKMOV) |
| 2 | expressions.adb 1927-1928 | CODE_LENGTH, chemin access-to-array | **sémantique** |
| 3 | expressions.adb 1952-1953 | CODE_LENGTH, chemin paramètre | **sémantique** |
| 4 | expressions.adb 1968-1969 | CODE_LENGTH, chemin variable | **sémantique** |
| 5 | expressions.adb 2507-2508 | Concat : COUNT d'un opérande agrégat | sûreté (CO_VAR) |
| 6 | expressions.adb 2642-2643 | Concat : LEN_G | sûreté (CO_VAR+BLKMOV) |
| 7 | expressions.adb 2660-2661 | Concat : LEN_D | sûreté (CO_VAR+BLKMOV) |
| 8 | expressions.adb 3170-3171 | Agrégat : COUNT choix nommé dynamique | sûreté |
| 9 | expressions.adb 3201-3202 | Agrégat : COUNT HI−LO dynamique | sûreté |
| 10 | expressions.adb 3582-3583 | Agrégat (2e famille) | sûreté |
| 11 | expressions.adb 3659-3660 | Agrégat (2e famille) | sûreté |
| 12 | expressions.adb 4588-4589 | Agrégat dynamique | sûreté |
| 13 | types_decls.adb 611-612 | COMPILE_ARRAY_TYPE_DIMENSION : taille de dimension dynamique | sûreté (SIZ du descripteur) |

Le site 13 protège par ricochet la longueur du **patch B** (qui lit `[__u].SIZ/8`) :
un objet `S : STRING(5..2)` obtiendra SIZ=0 et non un SIZ négatif.

Les numéros de ligne sont ceux d'avant les patchs A/B — se recaler par le motif
(paire `PUT_LINE( tab & "SUB" ); PUT_LINE( tab & "INC" );`), qui n'a que ces
13 occurrences dans tout l'expander.

Option d'hygiène (non bloquante) : introduire dans UTILS une procédure
`EMIT_COUNT` qui émet le triplet `SUB / INC / CLAMP0`, et y rediriger les 13
sites — garantit que tout futur site de comptage hérite du bornage.

## 3. Validation

1. ARRAY_TEST1 v2 : inchangé, doit rester intégralement vert (aucune section
   n'a d'intervalle nul — le CLAMP0 doit être neutre).
2. ARRAY_TEST2, section D7 seule décommentée :
   - `C1( N .. N-1 )'LENGTH` → 0
   - `C3 := C1( N .. N-1 ) & "ABCDEFGHIJKL"` → ABCDEFGHIJKL
   - `C1( N .. N-1 ) := C2( N .. N-1 )` → no-op, C1 inchangé
3. Filet complet (séries A + tests maison + auto-compilation).

## 4. Pièges proposés

52. **Compte d'éléments dynamique** : tout `LST−FST+1` émis doit être suivi de
    `CLAMP0` (intervalle nul → compteur négatif → CO_VAR/BLKMOV corrompus ;
    et 'LENGTH doit rendre 0, annexe A). Utiliser EMIT_COUNT, ne jamais émettre
    la paire SUB/INC nue. (session 4 juillet, D7)
