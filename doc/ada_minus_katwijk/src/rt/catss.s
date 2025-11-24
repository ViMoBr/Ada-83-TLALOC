	.text
| This function is made by compiling the following function
| and patching some things
|
|	function catss (s1, s2: string) return string is
|	  temp : string (1 .. s1' length + s2' length);
|	begin
|		temp (1 .. s1' length) := s1;
|		temp (s1' length + 1 .. s1' length + s2' length) := s2;
|
|		return temp;
|	end;
| Patch the text such that the descriptor of the local temp
| contains the same elements as the descriptor for the parameters
|

	.globl	__catss
__catss
.L10000
	link.w	a6,#-88
	movem.l	d2/d7/a3-a5,(sp)
.L10001
	move.l	#__catss,-4(a6)
	movea.l	#__check,a5
	movea.l	#__slice,a4
	movea.l	#__assign,a3
	move.l	sp,-8(a6)
	moveq	#5,d0
	move.l	d0,-40(a6)
| base type is taken from parameter descriptor
	movea.l	16 (a6), a0
	move.l	4 (a0), d0
	move.l	d0, -36 (a6)
|	move.l	#_Maacacw,-36(a6)
	clr.l	-32(a6)
	clr.l	-28(a6)
	moveq	#1,d0
	move.l	d0,-24(a6)
	movea.l	16(a6),a0
	move.l	20(a0),d0
	move.l	16(a0),d1
	sub.w	d1,d0
	addq.w	#2,d0
	movea.l	20(a6),a0
	move.l	20(a0),d1
	move.l	16(a0),d2
	sub.w	d2,d1
	add.w	d1,d0
	extw.l	d0
	move.l	d0,-20(a6)
	pea	-40(a6)
	jbsr	__ic_check
	addq.l	#4,sp
~TEMP = -44.
	move.l	-32(a6),d0
	addq.l	#1,d0
	moveq	#-2,d1
	and.l	d1,d0
	suba.l	d0,sp
	move.l	sp,-44(a6)
	tst.b	0(sp)
	move.l	sp,-8(a6)
	movea.l	16(a6),a0
	move.l	20(a0),d0
	move.l	16(a0),d1
	sub.w	d1,d0
	addq.w	#1,d0
	extw.l	d0
	move.l	d0,-(sp)
	pea	1.w
	pea	-68(a6)
	pea	-40(a6)
	move.l	-44(a6),-(sp)
	jbsr	(a4)
	lea	16(sp),sp
	move.l	d0,(sp)
	move.l	8(a6),-(sp)
	move.l	16(a6),-(sp)
	pea	-68(a6)
	jbsr	(a5)
	addq.l	#8,sp
	move.l	d0,(sp)
	pea	-68(a6)
	jbsr	(a3)
	lea	12(sp),sp
	movea.l	-8(a6),sp
	movea.l	16(a6),a0
	move.l	20(a0),d0
	move.l	16(a0),d1
	sub.w	d1,d0
	move.l	d0,d7
	addq.w	#2,d7
	movea.l	20(a6),a0
	move.l	20(a0),d0
	move.l	16(a0),d1
	sub.w	d1,d0
	add.w	d7,d0
	extw.l	d0
	move.l	d0,-(sp)
	move.w	d7,d0
	extw.l	d0
	move.l	d0,-(sp)
	pea	-68(a6)
	pea	-40(a6)
	move.l	-44(a6),-(sp)
	jbsr	(a4)
	lea	16(sp),sp
	move.l	d0,(sp)
	move.l	12(a6),-(sp)
	move.l	20(a6),-(sp)
	pea	-68(a6)
	jbsr	(a5)
	addq.l	#8,sp
	move.l	d0,(sp)
	pea	-68(a6)
	jbsr	(a3)
	lea	12(sp),sp
	movea.l	-8(a6),sp
	lea	-40(a6),a0
	movea.l	24(a6),a1
	move.l	a0,(a1)
	move.l	-44(a6),-16(a6)
.L2
	move.l	-16(a6),d0
.L3
	jbsr	__hardret
	movem.l	-88(a6),d2/d7/a3-a5
	unlk	a6
	rts
	.data
	.globl	_S380
_S380
