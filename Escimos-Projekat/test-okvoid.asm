
funkcija:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$4,%15
@funkcija_body:
		ADDS	8(%14),12(%14),%0
		MOV 	%0,-4(%14)
@funkcija_exit:
		MOV 	%14,%15
		POP 	%14
		RET
f2:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$12,%15
@f2_body:
		MOV 	$3,-4(%14)
		ADDS	-4(%14),-12(%14),%0
		MOV 	%0,-8(%14)
@f2_exit:
		MOV 	%14,%15
		POP 	%14
		RET
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$12,%15
@main_body:
		ADDS	-4(%14),-8(%14),%0
		MOV 	%0,-12(%14)
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET