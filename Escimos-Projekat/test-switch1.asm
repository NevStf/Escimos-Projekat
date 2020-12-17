
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$16,%15
@main_body:
		ADDS	-8(%14),$1,-8(%14)
		ADDS	-8(%14),-16(%14),%0
		MOV 	%0,-12(%14)
		ADDS	-12(%14),$1,-12(%14)
		MULS	-4(%14),-12(%14),%0
		MULS	%0,-8(%14),%0
		MOV 	%0,-16(%14)
		MOV 	$0,-8(%14)
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET