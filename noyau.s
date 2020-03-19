; ce programme est pour l'assembleur RealView (Keil)
	thumb

; variables du noyau ---------------------------------------------------
	area	kerdat, data, readwrite

pid	dcd	-1	; num du process courant

sp_tab	dcd	0	; tableau des SP, pour chaque process suspendu
	dcd	0	; sp = 0 <==> process termine
	dcd	0

; espace pour les piles ------------------------------------------------
	area	proc_stacks, data, noinit, readwrite, align=3

ST_SIZE	equ	0x800		; taille totale d'une pile de process
PC_OFF	equ	(14*4)		; position de PC dans un contexte empile 
PSR_OFF	equ	(15*4)		; position de PSR (flags) "   "       "
CTX_SIZ	equ	(16*4)		; taille d'un contexte entier
R0_OFF	equ	(8*4)		; position de R0 dans un contexte empile 
DEF_PSR	equ	0x01000000	; valeur de PSR par defaut (flags)

pstacks	space	(ST_SIZE * 3)	; reservation d'espace pour 3 processes


; code du noyau --------------------------------------------------------
	area	kercode, code, readonly

;	fonction d'initialisation d'un process - AVANT demarrage du kernel
;	le process sera demarre lors d'une interrupt future
;			r0 = PID numero de process
;			r1 = adresse point d'entree
;			r2 = donnee passee au process
	export init_1
init_1	proc
; pointeur de pile initial 
	ldr	r3, =pstacks		; zone des piles
	mov	r12, #ST_SIZE
	add	r3, r12			; sommet de la premiere pile
	mla	r3, r0, r12, r3		; ajouter PID * ST_SIZE -> sommet de la pile choisie
	sub	r3, #CTX_SIZ		; espace pour pile pre-remplie de 16 mots de 32 bits 
	ldr	r12, =sp_tab		; table des SP's
	str	r3, [r12, r0, LSL #2]	; SP du process
; contenu minimal pour cette pile : PC et PSR
	str	r1,  [r3, #PC_OFF]	; point d'entree
	ldr	r12, =DEF_PSR
	str	r12, [r3, #PSR_OFF]
	str	r2,  [r3, #R0_OFF]	; voila, on a prepare un contexte compatible avec un "faux" retour 
	bx	lr
; 
	endp

;	appel systeme de terminaison d'un process. Doit etre appelee par lui-meme
	export termine
termine proc
	svc	1	; pour le moment l'argument de svc est ignore
	bx	lr
	endp

;	traitement systick interrupt
;	c'est un point d'entree du kernel
	export	SysTick_Handler
	import	icnt
SysTick_Handler	proc
	push	{ r4, r5, r6, r7, r8, r9, r10, r11 }
; comptage pour mesure du temps
	ldr	r1, =icnt
	ldr	r0, [r1]
	add	r0, #1
	str	r0, [r1]
; recuperer le numero du process interrompu
	ldr	r1, =pid
	ldr	r0, [r1]
	cmp	r0, #0
	bmi	coldstart	; pid = -1 au demarrage
; sauver son SP dans la table
	ldr	r2, =sp_tab
	str	sp, [r2, r0, LSL #2]
scheduler
	cpsid	f		; interdire interrups car sp peut etre invalide
; changer le numero de process
next_pid
	add	r0, #1
	cmp	r0, #3		; limite -> bouclage
	blo	r0_ok
	mov	r0, #0
r0_ok	str	r0, [r1]
; changer de contexte
	ldr	sp, [r2, r0, LSL #2]
	cmp	sp, #0		; sauter process invalide
	beq	next_pid
; et voila on retourne sur un autre process
	pop	{ r4, r5, r6, r7, r8, r9, r10, r11 }
	bx	lr
; demarrage a froid
coldstart
	mov	r0, #0
	ldr	r2, =sp_tab
	b	r0_ok
;
	endp

;	traitement SVC soft interrupt
;	c'est un point d'entree du kernel, pour les appels systeme
	export	SVC_Handler
SVC_Handler	proc
	push	{ r4, r5, r6, r7, r8, r9, r10, r11 }
; recuperer le numero du process interrompu
	ldr	r1, =pid
	ldr	r0, [r1]
; terminer ce process = sauver son SP invalide dans la table
	ldr	r2, =sp_tab
	mov	r12, #0
	str	r12, [r2, r0, LSL #2]
	b	scheduler
	endp

	end
