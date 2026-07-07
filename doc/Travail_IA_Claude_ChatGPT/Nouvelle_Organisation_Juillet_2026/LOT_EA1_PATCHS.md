# LOT E-A1 — CHAÎNE RAISE → DÉROULAGE → SENTINELLE (doctrine auto-hébergée)

Recadrage acté : plus AUCUN fichier finc/fas écrit ou retouché à la main.
- _standrd.adb (Ada 83, compilé par TLALOC) : variables de service, type
  EXCEPTION_CONTEXT, EXC_CTX0, les cinq prédéfinies — FAIT (session du jour).
- CODE_EXCEPTION_DECL : émet `STR <nom>__exc, "<nom>"` — FAIT.
- codi : les deux capacités que la machine à pile ne sait pas exprimer,
  EXC_MACH (photographie de l'état caché) et EXC_RAISE (restauration + saut).
- Le wrapper généré (CREATE_FAS_MAIN_FILE) : seul lieu d'émission libre —
  init sentinelle + instance unique du déroulage + dispatch sentinelle.
- Tout le protocole : LLIR ordinaire émise par l'expander.

Le layout binaire du contexte est SPÉCIFIÉ par le record Ada (STATOFS) :
PREV_CTX +0, DISPATCH +8, RBP +16, RSP +24, R13 +32, R14 +40, NXT_LVL +48,
FRAME_POINTERS +56. Les macros ci-dessous s'y conforment ; toute évolution
du record impose leur mise à jour (consigner en commentaire des deux côtés).

Identité d'une exception X : l'adresse `<REGIONS_PATH>X__exc.data_ptr`.
Instance unique du déroulage : label `exc_raise_` (wrapper, niveau STANDARD),
atteinte par `BRA STANDARD.exc_raise_` — 5 octets par site de raise, ce qui
compte pour les futurs checks.

---

## PATCH 1 — codi_x86_64.finc : SYS_EXIT paramétrée

ANCRE : la macro SYS_EXIT (juste avant l'entête ELF). REMPLACER par :

```
;			---------
macro			SYS_EXIT?	code:0			; retour au systeme, code de retour parametrable (defaut 0)
;			---------
  db 0x6A, 0x3C							; push x3C  (sys_exit rax=60)
  db 0x58								; pop rax
  if code = 0
    db 0x31, 0xFF							; xor edi, edi		(err_code=0)
  else
    db 0xBF								; mov edi, imm32		(err_code)
    dd code
  end if
  db 0x0F, 0x05							; syscall
end macro
```

Rétrocompatible : `SYS_EXIT` sans argument émet les mêmes octets.

## PATCH 2 — codi_x86_64.finc : macro EXC_MACH

ANCRE : après la macro UNLINK. INSÉRER :

```
;			--------
macro			EXC_MACH?	lvl*, ctx*		; PILIER 11 : photographie de l'etat machine cache
;			--------					; dans le contexte de reprise a [FP(lvl) + ctx].
								; Layout = record STANDARD.EXCEPTION_CONTEXT
								; (_standrd.adb) : remplit RBP +16 (pile de travail,
								; frontiere d'instruction), RSP +24 (micro-pile),
								; R13 +32 / R14 +40 (co-pile), NXT_LVL +48 = lvl+1,
								; FRAME_POINTERS +56 = FP(0..lvl).
								; PREV_CTX +0 et DISPATCH +8 : protocole LLIR emis
								; par l'expander -- pas ici.
								; Clobbere RAX, RCX, RSI, RDI. Chemin froid (une fois
								; par entree de frame porteur) : disp32 uniformes.
  assert lvl >= 0 &	lvl <= 31
  FP_IN_RAX	lvl						; rax := FP(lvl)
  db 0x48, 0x89, 0xA8						; mov [rax + ctx+16], rbp
  dd ctx + 16
  db 0x48, 0x89, 0xA0						; mov [rax + ctx+24], rsp
  dd ctx + 24
  db 0x4C, 0x89, 0xA8						; mov [rax + ctx+32], r13
  dd ctx + 32
  db 0x4C, 0x89, 0xB0						; mov [rax + ctx+40], r14
  dd ctx + 40
  db 0x48, 0xC7, 0x80						; mov qword [rax + ctx+48], lvl+1	(NXT_LVL)
  dd ctx + 48
  dd lvl + 1
  db 0x48, 0x8D, 0xB8						; lea rdi, [rax + ctx+56]	(FRAME_POINTERS)
  dd ctx + 56
  db 0x4C, 0x89, 0xFE						; mov rsi, r15		(source : le display)
  db 0xB9								; mov ecx, lvl+1
  dd lvl + 1
  db 0xF3, 0x48, 0xA5						; rep movsq		(FP(0..lvl) -> ctx+56..)
end macro
```

## PATCH 3 — codi_x86_64.finc : macro EXC_RAISE

ANCRE : sous EXC_MACH. INSÉRER :

```
;			---------
macro			EXC_RAISE?	top*			; PILIER 11 : deroulage. Corps de l'INSTANCE UNIQUE,
;			---------					; posee par le wrapper sous le label exc_raise_ ;
								; top = deplacement VARzone niveau 0 du sommet de
								; pile des contextes (EXCEPTIONS_TOP_CTX_disp).
								; Precondition : EXCEPTIONS_CURRENT pose.
								; POP AVANT dispatch (LRM 11.4.1 : raise dans un
								; handler -> appelant ; fond de dispatch -> re-BRA).
								; Atteint par BRA, jamais par CALL.
  db 0x49, 0x8B, 0x1F						; mov rbx, [r15]		(rbx := FP(0))
  db 0x48, 0x8B, 0x83						; mov rax, [rbx + top]	(rax := contexte sommet)
  dd top
  db 0x48, 0x8B, 0x08						; mov rcx, [rax]		(PREV_CTX)
  db 0x48, 0x89, 0x8B						; mov [rbx + top], rcx	(POP avant dispatch)
  dd top
  db 0x4C, 0x8B, 0x68, 0x20						; mov r13, [rax+32]		(frame pointer co-pile)
  db 0x4C, 0x8B, 0x70, 0x28						; mov r14, [rax+40]		(sommet co-pile : balaye
								;  frames abandonnes et temporaires d'instruction)
  db 0x48, 0x8B, 0x60, 0x18						; mov rsp, [rax+24]		(micro-pile : jette les
								;  adresses de retour des frames deroules)
  db 0x48, 0x8B, 0x48, 0x30						; mov rcx, [rax+48]		(NXT_LVL)
  db 0x48, 0x8D, 0x70, 0x38						; lea rsi, [rax+56]
  db 0x4C, 0x89, 0xFF						; mov rdi, r15
  db 0xF3, 0x48, 0xA5						; rep movsq		(restaurer FP(0..lvl))
  db 0x48, 0x8B, 0x68, 0x10						; mov rbp, [rax+16]		(pile de travail)
  db 0xFF, 0x60, 0x08						; jmp [rax+8]		(DISPATCH du frame porteur)
end macro
```

## PATCH 4 — expander.adb, CREATE_FAS_MAIN_FILE : le wrapper

ANCRE A : la ligne `PUT_LINE( tab & "LINK" & tab & "0, loc_siz" );`
INSÉRER APRÈS :

```ada
	-- PILIER 11 : contexte-sentinelle en fond de la pile des contextes de reprise
	PUT_LINE( tab & "EXC_MACH" & tab & "0, EXC_CTX0__dat" );					-- photo niveau 0 (NXT_LVL=1 : FP(0))
	PUT_LINE( tab & "LCA" & tab & "exc_uncaught_" );
	PUT_LINE( tab & "Sa" & tab & "0, EXC_CTX0__dat + _EXCEPTION_CONTEXT.DISPATCH" );
	PUT_LINE( tab & "LVA" & tab & "0, EXC_CTX0__dat" );
	PUT_LINE( tab & "Sa" & tab & "0, EXCEPTIONS_TOP_CTX_disp" );				-- (PREV_CTX de la sentinelle : jamais lu)
```

ANCRE B : la ligne `PUT_LINE( tab & "SYS_EXIT" );`
INSÉRER APRÈS :

```ada
	-- PILIER 11 : region inatteignable (apres SYS_EXIT) -- deroulage + sentinelle
	PUT_LINE( "exc_raise_:" );								-- instance unique ; les raise viennent par BRA
	PUT_LINE( tab & "EXC_RAISE" & tab & "EXCEPTIONS_TOP_CTX_disp" );
	PUT_LINE( "exc_uncaught_:" );								-- dispatch du contexte-sentinelle
	PUT_LINE( tab & "STR" & tab & "EXC_MSG__, 'EXCEPTION NON RATTRAPEE : '" );
	PUT_LINE( tab & "STR" & tab & "EXC_NL__, 10" );
	PUT_LINE( tab & "LCA" & tab & "EXC_MSG__.data_ptr" );
	PUT_LINE( tab & "SYS_PUT_STR" );
	PUT_LINE( tab & "La" & tab & "0, EXCEPTIONS_CURRENT_disp" );				-- le symbole EST son diagnostic
	PUT_LINE( tab & "SYS_PUT_STR" );
	PUT_LINE( tab & "LCA" & tab & "EXC_NL__.data_ptr" );
	PUT_LINE( tab & "SYS_PUT_STR" );
	PUT_LINE( tab & "SYS_EXIT" & tab & "1" );
```

(Tout le wrapper est dans `namespace STANDARD` : références non préfixées.
Micro-arbitrage laissé ouvert : l'en-tête du message pourrait à terme vivre
en Ada dans _standrd.adb via un CALL TEXT_IO — coût d'un protocole d'appel
dans le wrapper pour un gain de pureté marginal ; l'émission LLIR directe
est recommandée.)

## PATCH 5 — expander-instructions.adb : CODE_RAISE réécrit

REMPLACER le corps entier de CODE_RAISE (l'ancien design EXL/CD_LABEL
commenté est SUPPRIMÉ — piège n° 59) :

```ada
  procedure			CODE_RAISE		( ADA_RAISE :TREE )
  is			----------
    NAME	: TREE	:= D( AS_NAME, ADA_RAISE );
  begin
    if  NAME = TREE_VOID  then								-- raise; nu (re-raise, LRM 11.3)
      PUT_LINE( "ANOMALIE : raise nu non modelise -- dump prealable, lot E-C" );		-- bruyant a l'assemblage
    else
      declare
	EXCEPTION_ID	: TREE	:= D( SM_DEFN, NAME );
      begin
	PUT( tab & "LCA" & tab );
	CODI.REGIONS_PATH( EXCEPTION_ID );
	PUT_LINE( PRINT_NAME( D( LX_SYMREP, EXCEPTION_ID ) ) & "__exc.data_ptr" );	-- l'ADRESSE fait identite
	PUT_LINE( tab & "Sa" & tab & "0, STANDARD.EXCEPTIONS_CURRENT_disp" );
	PUT_LINE( tab & "BRA" & tab & "STANDARD.exc_raise_" );				-- derouler
      end;
    end if;
  end	CODE_RAISE;
```

REGIONS_PATH( EXCEPTION_ID ) donne « STANDARD. » pour les prédéfinies et
« STANDARD.EXC_TEST0_L1. » pour MON_ERREUR — aligné sur l'imbrication réelle
des namespaces du FINC. Le raise d'une prédéfinie passe donc par le même
code, zéro cas particulier — et c'est le chemin que les checks emprunteront.

## VERDICT E-A1

1. Recompiler l'expander ; _STANDRD.FINC déjà régénéré (fait).
2. **Supprimer EXC_TEST0.fas s'il existe** : le wrapper n'est écrit que dans
   la branche NAME_ERROR (« already exists » sinon) — un .fas ancien ne
   recevrait ni l'init sentinelle ni la région inatteignable.
3. Compiler exc_test0.adb, assembler, exécuter. Attendu :

```
EXCEPTION NON RATTRAPEE : MON_ERREUR        (stdout, ligne unique)
$? = 1
```

C'est le raise de la ligne 11 (premier bloc) : aucun handler n'est encore
câblé, TOUT raise est non rattrapé — la chaîne identité → EXCEPTIONS_CURRENT
→ déroulage → sentinelle est jugée de bout en bout, restaurations comprises
(le déroulage traverse le frame du bloc et celui de la procédure).

4. Filet : un témoin ancien SANS exception, .fas supprimé puis régénéré —
   doit compiler, assembler et donner la même sortie qu'avant (le wrapper
   gagne 5 lignes d'init exécutées une fois + une région morte ; le flux des
   unités est octet-à-octet inchangé, SYS_EXIT sans argument compris).

## SUITE (E-A2, prochain incrément)

CODE_BLOCK_BODY (VAR contexte + protocole push/pop + BRA par-dessus la
section dispatch), CODE_EXCEPTIONS_ALTERNATIVE_S réel (La/LCA/CEQ/BT, others,
chute = BRA exc_raise_), drapeau HANDLER_CTX_AT + pops dans CODE_RETURN /
CODE_EXIT (note v2 §5bis). Verdict : exc_test0 complet — sortie vide, $?=0,
les trois handlers exercés ; puis mutation du témoin (commenter le handler
others) pour re-vérifier la sentinelle.
