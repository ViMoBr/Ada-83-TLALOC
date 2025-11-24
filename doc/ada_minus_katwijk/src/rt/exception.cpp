#include	"names.h"
|
|	handling exceptions
|
|	On initalizing the handler the static link is
|	to be pushed
|
|

	.globl	__hinit
	.globl	__hrestore
	.globl	__raise
	.globl	__reraise
	.globl	_myself
	.globl	_getexc

__hinit:
	movea.l	(sp)+,a0
	move.l	a6,-(sp)
	move.l	a5,-(sp)
	movea.l	_myself, a1
	move.l	_EXH(a1), -(sp)
	move.l	sp, _EXH(a1)
	| push a dummy argument again, it will be popped
	| by the caller
	move.l	a5,-(sp)
	jmp	(a0)
memcatch:			| memory fault, translate into exception
	movea.l	_myself, a0
	move.l  #STORAGE_ERROR, _EXC (a0)
	br	__reraise
__raise:
	tst.l	(sp)+
	movea.l	_myself, a0	| get the environment
	move.l	(sp)+,_EXC (a0)	|
__reraise:
	movea.l	_myself, a0	| just for the reaise
	tst.l	_EXH(a0)
	beq	no_handl
	movea.l	_EXH(a0), sp
	move.l	(sp)+, _EXH(a0)
	movea.l	(sp)+,a5
	movea.l	(sp)+,a6
__db_except:
	rts			|handler address on top

	.data
s:	.asciz "Reached the bottom without handlers, exception = %s\n"
	.text
no_handl:
	movea.l	_myself, a0
	move.l	_EXC (a0), -(sp)
	move.l	#s, -(sp)
	jbsr	_printf
	jbsr	_exit
__hrestore:
	movea.l	(sp)+, a0
	movea.l _myself, a1
	movea.l _EXH(a1), sp
	move.l	(sp)+, _EXH (a1)
	jmp	(a0)

	.globl	_getexc
_getexc:
	movea.l	_myself, a0
	move.l	_EXC(a0), d0
	rts


	.globl	_prochandler
	.globl	_blockhandler
	.globl	_accepthandler
	.globl	_taskhandler

_taskhandler:
	jsr	_terminate

_blockhandler:
_prochandler:
	jsr	_leave_master
	jmp	__reraise

_accepthandler:
	movea.l	_myself, a0
	move.l	_EXC(a0), -(sp)
	jsr	_end_rdv

