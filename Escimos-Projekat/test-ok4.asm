
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$12,%15
@main_body:
		CMPS 	-0(%14),$20
		ADDS	-4(%14),$1,-4(%14)
		ADDS	$6,-12(%14),%0
		MOV 	%0,-8(%14)
		CMPS 	-0(%14),$5
		MOV 	$3,-0(%14)
		CMPS 	-0(%14),-4(%14)
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET