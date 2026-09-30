.L46:
	cmpq	$2, %r10
	jbe	.L56
.L48:
	leaq	(%r8,%rdi,8), %rdx
	xorl	%eax, %eax
	vxorpd	%xmm1, %xmm1, %xmm1
	.p2align 5
	.p2align 4,,10
	.p2align 3
.L52:
	vmovupd	(%rbx,%rax), %ymm0
	vmulpd	(%rdx,%rax), %ymm0, %ymm0
	addq	$32, %rax
	cmpq	%rax, %rcx
	vaddpd	%ymm0, %ymm1, %ymm1
	jne	.L52
	vextractf128	$0x1, %ymm1, %xmm0
	testb	$3, %r13b
	vaddpd	%xmm1, %xmm0, %xmm0
	vunpckhpd	%xmm0, %xmm0, %xmm1
	vaddpd	%xmm0, %xmm1, %xmm1
	je	.L71
	movq	%r13, %rax
	andq	$-4, %rax
.L54:
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	je	.L50
	leaq	(%rdi,%rax), %r11
	vmovupd	(%rbx,%rax,8), %xmm2
	testb	$1, %dl
	vfmadd231pd	(%r8,%r11,8), %xmm2, %xmm0
	vunpckhpd	%xmm0, %xmm0, %xmm1
	vaddpd	%xmm0, %xmm1, %xmm1
	je	.L51
	andq	$-2, %rdx
	addq	%rdx, %rax
.L50:
	leaq	(%rdi,%rax), %rdx
	vmovsd	(%r8,%rdx,8), %xmm3
	vfmadd231sd	(%rbx,%rax,8), %xmm3, %xmm1
.L51:
	vmovsd	%xmm1, (%rsi)
	addq	$8, %rsi
	addq	%r13, %rdi
	cmpq	%r9, %rsi
	jne	.L46
