.segment "BHDR"

		.word	$0801
		.word	hdrend
		.word	2026
		.byte	$9e, "2061", 0
hdrend:		.word	0

; print string 't' with length 'l'
.macro print t, l
		ldx	#(l ^ $ff) + 1
		lda	t-$100+l,x
		jsr	$ffd2
		inx
		bne	*-7
.endmacro

.code

entry:		ldx	#2
checkloop1:	lda	$ea7b,x		; check original JSR to keyboard scan
		cmp	origjsr,x
		bne	error
		dex
		bpl	checkloop1
		ldx	#kbchecklen-1
checkloop2:	lda	$e4b7,x		; check "empty" space in KERNAL ROM
		cmp	#$aa
		bne	error
		dex
		bpl	checkloop2
		print	patching, patchinglen
		sei
		lda	#$a0
		sta	romrd1+2
		sta	romwr1+2
		lda	#$e0
		sta	romrd2+2
		sta	romwr2+2
		ldx	#0
		ldy	#$20
romrd1:		lda	$f000,x		; Copy all ROM to RAM
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
		sta	$e4b7,x		; unused area of original ROM
		dex
		bpl	patchloop
		lda	#$b7		; update JSR command in the
		sta	$ea7c		; system IRQ routine to
		lda	#$e4		; point to our preamble instead
		sta	$ea7d
		lda	#$35		; bank out ROMs
		sta	$01
		cli
		print	done, donelen
		rts

error:		print	err, errlen
		rts

; new preamble to keyboard scanning, only call original scanning routine
; when there is no current control port activity.
kbcheck:	lda	#0
		sta	$dc02		; Configure PORT A
		sta	$dc03		; and PORT B for input only
		lda	$dc00		; Combine inputs of both ports
		and	$dc01
		dec	$dc02		; Configure PORT A for in/out again
		eor	#$ff		; Invert input
		and	#$1f		; Mask lowest 5 bits (from CP #1/#2)
		bne	kbskip		; On any input, skip keyboard scanning
		jmp	$ea87		; Original keayboard scan routine
kbskip:		rts
kbchecklen=	*-kbcheck

origjsr:	jsr	$ea87

patching:	.byte	"patching kernal ... "
patchinglen=	*-patching
done:		.byte	"done.", $d
donelen=	*-done
err:		.byte	"kernal is unsupported or", $d, "already patched!", $d
errlen=		*-err
