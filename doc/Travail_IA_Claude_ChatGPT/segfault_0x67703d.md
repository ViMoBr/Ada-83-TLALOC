#COMMANDE AU COMPILATEUR
 <pre>
 ./T2 ./ ../calendar.adb W
 </pre>
 
#PROGRAMME SOUMIS AU COMPILATEUR
<pre> 
calendar.adb
</pre>

#REMARQUES
Passe SEM_PHASE la commande
.$ ./T2 ./ ../calendar.adb M
ada83 compiling ./../calendar.adb ..... Ok 102 msec

Erreur avec option W en dernière phase WRITE_LIB.

#INSTRUCTION SEGFAULT 0x677075
 <pre>
(gdb) x/16i $rip-32
   0x677055:    lea    -0x8(%rbp),%ebp
   0x677058:    mov    %rax,0x10(%r15)
   0x67705c:    mov    0x0(%r13),%r13
   0x677060:    call   0x46bd31
   0x677065:    mov    0x8(%r15),%rbp
   0x677069:    mov    0x0(%rbp),%rax
   0x67706d:    lea    -0x8(%rbp),%rbp
   0x677071:    mov    %rax,0x8(%r15)
=> 0x677075:    mov    0x0(%r13),%r13
   0x677079:    ret
   0x67707a:    jmp    0x686560
   0x67707f:    mov    0x8(%r15),%rax
   0x677083:    mov    %rax,0x8(%rbp)
   0x677087:    lea    0x8(%rbp),%rbp
   0x67708b:    mov    %rbp,0x8(%r15)
   0x67708f:    lea    0x468(%rbp),%rbp

</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x7fffffc063e0      140737484186592   rbx            0x0                 0                 │
│rcx            0x406d0e            4222222           rdx            0x0                 0                 │
│rsi            0x7fffffc061d6      140737484186070   rdi            0x7fffffc06850      140737484187728   │
│rbp            0x7fffffc066d8      0x7fffffc066d8    rsp            0x7fffffbfdae0      0x7fffffbfdae0    │
│r8             0xffffffffffffffff  -1                r9             0x0                 0                 │
│r10            0x22                34                r11            0x206               518               │
│r12            0x7ffff7dda800      140737351886848   r13            0x101010101010101   72340172838076673 │
│r14            0x1948b58           26512216          r15            0x7fffffbfdaf0      140737484151536   │
│rip            0x67703d            0x67703d          eflags         0x10206             [ PF IF RF ]      │
</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc06698: 0x0000000000000000      0x0000000000000000
0x7fffffc066a8: 0x0000000000000000      0x0000000000000000
0x7fffffc066b8: 0x0000000000000000      0x0000000000000000
0x7fffffc066c8: 0x0000000000000000      0x0000000000000000
0x7fffffc066d8: 0x0000000000000000      0x00007fffffc063e0
0x7fffffc066e8: 0x00007fffffc066f0      0x0000000800040000
0x7fffffc066f8: 0x00007fff00000000      0x00000000018dced0
0x7fffffc06708: 0x00007fffffc066f0      0x00007fffffc06720
</pre>

#BACKTRACE ET MAP
<pre>
#0  0x000000000067703d in ?? ()
RECOPIE_POUR_COMPACTION_L29 0x0000000000672623
....
var elab COMP_UNIT 0x0000000000676BA2
 disp 0x00000000000000C0
 **zone segfault**
including sub body IDL-WRITE_LIB.FINC
PRETTY_DIANA_L14 0x0000000000677047

#1  0x0000000000d9c6fe in ?? ()
#2  0x0000000000d9d108 in ?? ()
</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT
dans WRITE_LIB
<pre>
   COMP_UNIT		: TREE;
  begin
				--------------------------------
				TRAITE_LES_UNITES_DE_COMPILATION:

    while  not IS_EMPTY( COMP_UNIT_SEQ )  loop
      POP( COMP_UNIT_SEQ, COMP_UNIT );
      if  D( AS_ALL_DECL, COMP_UNIT ).TY = DN_VOID  then							--| UNITE A PRAGMAS SEULEMENT
        NEW_UNIT_SEQ := APPEND( NEW_UNIT_SEQ, COMP_UNIT );							--| JUSTE LA RECHAINER DANS LA LISTE MISE A JOUR
      else											--| UNITE USUELLE
        MARK_DONT_MOVE_PAGES( COMP_UNIT );
        NEW_BLOCK;											--| FORCE A SE METTRE AU DEBUT D'UN NOUVEAU BLOC POUR ALIGNER LA RECOPIE COMPACTEE
        WRITE_UNIT( COMP_UNIT );									--| COMPACTER ET ECRIRE L UNITE DE COMPILATION
      end if;

    end loop	TRAITE_LES_UNITES_DE_COMPILATION;
		--------------------------------

    LIST( D( AS_COMPLTN_UNIT_S, COMPILATION ), NEW_UNIT_SEQ );						--| REMPLACER LA LISTE DES UNITES PAR CELLE DES COMPACTEES, SERA ECRIT A LA FERMETURE DU FICHIER ARBRE
  end;

  DELETE_IDL_TREE_FILE;										--| LE FICHIER $$$.TMP EST ABIME PAR LE PROCESSUS DE MARQUAGE

end	WRITE_LIB;

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS IDL.WRITE_LIB.FINC
<pre>
 hexa_show 'var elab COMP_UNIT ', $
VAR COMP_UNIT_disp, q			; variable record : pointeur aux data record
VAR COMP_UNIT__u, q				; variable record : pointeur aux useinfo
VAR COMP_UNIT__dat, STANDARD.IDL._TREE.size
	LVA	2, COMP_UNIT__dat
	Sa	2, COMP_UNIT_disp			; record fin
	LVA	2, STANDARD.IDL._TREE.SIZ
	Sa	2, COMP_UNIT__u
	La  2, COMP_UNIT_disp
					; store represented component PT range 0 .. 1 width 2
	DUP
	Ld
	LI	0
	LI	0
	LI	2
	BFI
	Sd

 hexa_show ' disp ', COMP_UNIT_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
TRAITE_LES_UNITES_DE_COMPILATION:
	LI	0					; lieu resultat sur pile
	LVA 2,	COMP_UNIT_SEQ_disp
	CALL	STANDARD.IDL. ,IS_EMPTY_L23
	LI	1
	OUX
	BF	L77
	LVA  2,	STANDARD.IDL.WRITE_LIB_L13.BLOCK__5.COMP_UNIT_disp
	LVA  2,	STANDARD.IDL.WRITE_LIB_L13.BLOCK__5.COMP_UNIT_SEQ_disp
	CALL	STANDARD.IDL. ,POP_L24
					; debut if
VAR	ANON_253_11_disp, q
VAR	ANON_253_11__u,    q
VAR	ANON_253_11__dat, STANDARD.IDL._TREE.size
	LVA 2, ANON_253_11__dat
	Sa  2, ANON_253_11_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  2, ANON_253_11__u
	LVA 2, ANON_253_11_disp
					; doublet resultat record anonyme
	LVA 2,	COMP_UNIT_disp
	LI  138
	CALL	STANDARD.IDL. ,D_L17
	La
	Ld
	LI	24
	LI	8
	UBFX
	LI	11
	CEQ
	BF	L79
	LVA 1,	STANDARD.IDL.WRITE_LIB_L13.NEW_UNIT_SEQ_disp
	La
	LI	STANDARD.IDL._SEQ_TYPE.size
VAR	ANON_254_25_disp, q
VAR	ANON_254_25__u,    q
VAR	ANON_254_25__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 2, ANON_254_25__dat
	Sa  2, ANON_254_25_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  2, ANON_254_25__u
	LVA 2, ANON_254_25_disp
					; doublet resultat record anonyme
	LVA 2,	COMP_UNIT_disp
	LVA 1,	STANDARD.IDL.WRITE_LIB_L13.NEW_UNIT_SEQ_disp
	CALL	STANDARD.IDL.IDL_MAN. ,APPEND_L34
	La
	BLKMOV
	BRA	L78
L79:
	LVA 2,	COMP_UNIT_disp
	CALL	STANDARD.IDL.WRITE_LIB_L13. ,MARK_DONT_MOVE_PAGES_L1
	CALL	STANDARD.IDL.PAGE_MAN. ,NEW_BLOCK_L17
	LVA 2,	COMP_UNIT_disp
	CALL	STANDARD.IDL.WRITE_LIB_L13. ,WRITE_UNIT_L15
L78:					; post if
	BRA	TRAITE_LES_UNITES_DE_COMPILATION
L77:					; post loop TRAITE_LES_UNITES_DE_COMPILATION
	LVA 1,	STANDARD.IDL.WRITE_LIB_L13.NEW_UNIT_SEQ_disp
VAR	ANON_264_11_disp, q
VAR	ANON_264_11__u,    q
VAR	ANON_264_11__dat, STANDARD.IDL._TREE.size
	LVA 2, ANON_264_11__dat
	Sa  2, ANON_264_11_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  2, ANON_264_11__u
	LVA 2, ANON_264_11_disp
					; doublet resultat record anonyme
	LVA 2,	COMPILATION_disp
	LI  136
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.IDL_MAN. ,LIST_L36
	UNLINK 2
endPRO
	CALL	STANDARD.IDL. ,DELETE_IDL_TREE_FILE_L8
ret_lbl:
	UNLINK 1
	RTD
excep:
endPRO					;---------- end PRO WRITE_LIB

 </pre>
