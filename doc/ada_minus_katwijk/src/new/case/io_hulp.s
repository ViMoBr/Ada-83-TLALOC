	.data
	.globl	_XabeaacREPLY
	.text
	.globl	_E50
_E50
.L10000
	link.w	a6,#-32
.L10001
/	.ln 0
	.ln 1
	.ln 2
.L4
	.def IO_HULP.1
	.scl 2
	.type 36
	.val .L4	
	.endef
	.ln 3
	.def .bb	
	.line 3
	.endef
	.comm	_XaabaaaSTANDARD,4
	move.l	sp,_XaabaaaSTANDARD
	.data
_XabeaacREPLY
	.long	2
	.long	1
	.long	0
	.long	1
	.long	.L5
	.word	0
	.byte	89
	.byte	69
	.byte	83
	.byte	0
	.even
.L5
	.long	.L6
	.word	1
	.byte	78
	.byte	79
	.byte	0
	.even
.L6
	.long	0
	.text
	.ln 3
	.ln 4
	.ln 6
	.def .eb	
	.line 6
	.endef
.L1
	jbsr	__hardret
	unlk	a6
	rts
