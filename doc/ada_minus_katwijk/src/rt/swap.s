	.data
	.comm	_swap_s,4
	.comm	_swap_t,4
	.text
	.globl	_swap
_swap
	movea.l _myself,a0
	addq.l	#4,a0
	move.l	a0,_swap_t
	movea.l	4(sp),a0
	move.l	a0,_myself	| swap tdp's : myself := current
	addq.l	#4,a0
	move.l	a0,_swap_s
	movea.l	_swap_t, a0
	movem.l	d0-d7/a0-a7,(a0)
	movea.l _swap_s, a0
	movea.l	60(a0),a0	| get sp from other process
	move.l	(sp),(a0)	| get rts from swap into st_frame other process
	movea.l	_swap_s,a0
	movem.l	(a0),d0-d7/a0-a7
	rts
