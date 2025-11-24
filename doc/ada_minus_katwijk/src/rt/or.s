	.data
	.file "or.c"
	.data
	.text
	.globl	__or
__or
	jra	.L10000
.L10001
	movea.l	16(a6),a0
	movea.l	20(a6),a1
	move.l	8(a0),d0
	cmp.l	8(a1),d0
	jeq	.L33
	move.l	__constraint_error,-(sp)
	jbsr	__raise
	addq.l	#4,sp
.L33
	movea.l	16(a6),a0
	move.l	(a0),-36(a6)
	movea.l	16(a6),a0
	move.l	4(a0),-32(a6)
	movea.l	16(a6),a0
	move.l	8(a0),-28(a6)
	movea.l	16(a6),a0
	move.l	12(a0),-24(a6)
	movea.l	16(a6),a0
	move.l	16(a0),-20(a6)
	movea.l	16(a6),a0
	move.l	20(a0),-16(a6)
	move.l	-28(a6),d0
	suba.l	d0,sp
	move.l	sp,d0
	subq.l	#1,d0
	moveq	#-2,d1
	and.l	d1,d0
	movea.l	d0,sp
	move.l	sp,-12(a6)
	clr.l	-8(a6)
.L37
	move.l	-28(a6),d0
	subq.l	#1,d0
	cmp.l	-8(a6),d0
	jlt	.L36
	move.l	-8(a6),d0
	movea.l	8(a6),a0
	move.b	0(a0,d0.l),d0
	extb.l	d0
	move.l	-8(a6),d1
	movea.l	12(a6),a0
	move.b	0(a0,d1.l),d1
	extb.l	d1
	or.l	d1,d0
	move.l	-8(a6),d1
	movea.l	-12(a6),a0
	move.b	d0,0(a0,d1.l)
.L35
	addq.l	#1,-8(a6)
	jra	.L37
.L36
	lea	-36(a6),a0
	movea.l	24(a6),a1
	move.l	a0,(a1)
	move.l	-12(a6),d0
	jra	.L32
.L32
	jsr	__hardret
	unlk	a6
	rts	pc
.L10000
	link.w	a6,#-36
	jra	.L10001
	.data
	.globl	__raise
	.globl	__constraint_error
