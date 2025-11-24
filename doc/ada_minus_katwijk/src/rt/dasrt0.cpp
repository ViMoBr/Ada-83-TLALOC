#include	"names.h"
.data
	.comm	_environ,4
	.comm	exceptio,4
	.comm	__parbase,4
	.comm	temp_sta,200
	.comm	_STANDARD,4

	.comm   __univ_stack_seg_top,4
	.comm   __univ_stack_seg_bottom,4

	.globl	memcatch
	.globl	_SHORT
	.globl	_INTEGER
	.globl	_LONG
	.globl	_FLOAT
	.globl	__std_boolean
	.globl	_BOOLEAN
	.globl	_ANY_INT
	.globl	__std_master

__std_master:
	.long 0
	.long 0
	.long 0


_SHORT:
	.long	2
	.long	1
	.long	-128
	.long	127

_INTEGER:
	.long	2
	.long	2
	.long	-32768
	.long	32767

_ANY_INT:
	.long	2
	.long	4
	.long	-2147483648
	.long	2147483647

_LONG:
	.long	2
	.long	4
	.long	-2147483648
	.long	2147483647

_FLOAT:
	.long	2
	.long	8
	.long	0
	.long	0

__std_boolean:
_BOOLEAN:
	.long	2
	.long	1
	.long	0
	.long	1

dumm:
	.long	0

	.globl	_FP_xini
.text
	move.l	8(sp),_environ
	move.l	sp,__parbase
	movea.l	#temp_sta-200,a6
	movea.l	#dumm,a5
	move.l	sp,_STANDARD
	move.l	sp, __univ_stack_seg_top
	move.l	#memcatch, -(sp)
	move.l	#21, -(sp)
	jsr	_signal
	adda.l	#8, sp
	jsr	_FP_xini
	addq.l	#4, sp
#ifdef TASKING
| take a common stack pool for taskstorage of 1024 K bytes
	subi.l 	#1048576, sp
#endif
	move.l	sp, __univ_stack_seg_bottom

| the next sets the stdout buffer size to zero
	tst.b	-12(sp)
	clr.l	-(sp)
	move.l	#__iob+14,-(sp)
	jsr	_setbuf
	addq.l	#8,sp
