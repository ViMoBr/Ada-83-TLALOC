.data
	.comm	_environ,4
	.comm	exceptio,4
	.comm	__parbase,4
	.comm	temp_sta,200
	.comm	_XaabaaaSTANDARD,4
	.comm   __univ_stack_seg_top,4
	.comm   __univ_stack_seg_bottom,4
	.globl	__short
	.globl	__integer
	.globl	__long
	.globl	__mach_real
	.globl	__std_boolean
	.globl	_XaabaadBOOLEAN
	.globl	__any_integer
	.globl	__std_master
__std_master:
	.long 0
	.long 0
	.long 0
__short:
	.long	2
	.long	1
	.long	-128
	.long	127
__integer:
	.long	2
	.long	2
	.long	-32768
	.long	32767
__any_integer:
	.long	2
	.long	4
	.long	-2147483648
	.long	2147483647
__long:
	.long	2
	.long	4
	.long	-2147483648
	.long	2147483647
__mach_real:
	.long	2
	.long	8
	.long	0
	.long	0
__std_boolean:
_XaabaadBOOLEAN:
	.long	2
	.long	1
	.long	0
	.long	1
dumm:
	.long	0
.text
	move.l	8(sp),_environ
	move.l	sp,__parbase
	movea.l	#temp_sta-200,a6
	movea.l	#dumm,a5
	move.l	sp,_XaabaaaSTANDARD
	move.l	sp, __univ_stack_seg_top
	fmove.l	#144, fpcr
	move.l	sp, __univ_stack_seg_bottom
| the next sets the stdout buffer size to zero
	tst.b	-12(sp)
	clr.l	-(sp)
	move.l	#__iob+14,-(sp)
	jsr	_setbuf
	addq.l	#8,sp
	jsr	_E529
	jsr	_E528
	jsr	_E542
	jsr	_E520
	jsr	_E536
	jsr	_E588
	movea.l	_S336,a0
	jsr	(a0)
	jmp	_exit
