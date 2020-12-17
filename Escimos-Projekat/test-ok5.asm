
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$16,%15
@main_body:
		MULS	-8(%14),-12(%14),%0
		MOV 	%0,-4(%14)
		DIVS	-4(%14),$5,%0
		MOV 	%0,-16(%14)
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET