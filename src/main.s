.segment "BHDR"

		.word	$0801
		.word	hdrend
		.word	2026
		.byte	$9e, "2061", 0
hdrend:		.word	0

.code

entry:		sei
		lda	#$a0
		sta	romrd1+2
		sta	romwr1+2
		lda	#$e0
		sta	romrd2+2
		sta	romwr2+2
		ldx	#0
		ldy	#$20
romrd1:		lda	$f000,x
romwr1:		sta	$f000,x
romrd2:		lda	$f000,x
romwr2:		sta	$f000,x
		inx
		bne	romrd1
		dey
		beq	dopatch
		inc	romrd1+2
		inc	romwr1+2
		inc	romrd2+2
		inc	romwr2+2
		bne	romrd1
dopatch:	ldx	#kbchecklen-1
patchloop:	lda	kbcheck,x	; place new preamble code in
		sta	$e4b7,x		; unused area of original rom
		dex
		bpl	patchloop
		lda	#$b7		; update jmp command in the
		sta	$ea7c		; system IRQ routine to
		lda	#$e4		; point to our preamble instead
		sta	$ea7d
		lda	#$35		; bank out ROMs
		sta	$01
		cli
		rts

; new preamble to keyboard scanning, only call original scanning routine
; when there is no current control port activity.
kbcheck:	lda	#0
		sta	$dc02		; Configure PORT A for input only
		lda	$dc00		; Combine inputs of both ports
		and	$dc01
		dec	$dc02		; Configure PORT A for in/out again
		eor	#$ff		; Invert input
		and	#$1f		; Mask lowest 5 bits (from CP #1/#2)
		bne	kbskip		; On any input, skip keyboard scanning
		jmp	$ea87		; Original keayboard scan routine
kbskip:		rts
kbchecklen=	*-kbcheck
