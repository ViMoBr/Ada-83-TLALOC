	.text
	.globl	__catcc
__catcc
	jra	.L10000
.L10001
	move.l	sp,-8(a6)
	.data
	.globl	abhaaj5OAAB
abhaaj5OAAB
	.set ., abhaaj5OAAB+0	
	.long	5
	.set ., abhaaj5OAAB+4	
	.long	_Maacacw
	.set ., abhaaj5OAAB+8	
	.long	0
	.set ., abhaaj5OAAB+12	
	.long	0
	.set ., abhaaj5OAAB+16	
	.long	1
	.set ., abhaaj5OAAB+20	
	.long	2
	.text
	move.l	#abhaaj5OAAB,-(sp)
	jbsr	__ic_check
	addq.l	#4,sp
	.data
	.set ., abhaaj5OAAB+24	
	.text
	pea	1.w
	move.l	#abhaaj5OAAB,-(sp)
	jbsr	__indexing
	addq.l	#8,sp
	lea	-18(a6),a0
	move.b	11(a6),0(a0,d0.l)
	pea	2.w
	move.l	#abhaaj5OAAB,-(sp)
	jbsr	__indexing
	addq.l	#8,sp
	lea	-18(a6),a0
	move.b	15(a6),0(a0,d0.l)
	movea.l	16(a6),a0
	move.l	#abhaaj5OAAB,(a0)
	lea	-18(a6),a0
	move.l	a0,-16(a6)
	move.l	a0,d0
.L6
	jsr	__hardret
	unlk	a6
	rts	pc
.L5
	jra	.L6
.L10000
	link.w	a6,#-20
	jra	.L10001
