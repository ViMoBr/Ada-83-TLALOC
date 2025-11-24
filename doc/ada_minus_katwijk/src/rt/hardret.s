	.globl	__hardret
	.globl	em_ret
em_ret:
	tst.l	(sp)+
| fake a new return environment
| donot be ashamed if the following code doesnot seem to make sense
| Three fases:
|     fase I: set up a context such that, after return from the
|	      calling function, control returns here
|     fase II:execute the return cycle of the caller
|     fase III: do final return
|
__hardret:
	move.l	4(a6),-(sp)
	move.l	(a6), -(sp)	| i.e. link.w a6, #0
	move.l	sp, (a6)
	move.l	#L1, 4(a6)	| i.e. return address of caller
	movea.l	8(sp), a1	| execute return code of caller
	jmp	(a1)
L1:	movea.l	a6, sp		| get a reasonable sp
	movea.l	(sp)+, a6	| restore a6
	rts

