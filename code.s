.include "LAMAlib.inc"
.include "LAMAlib-sprites.inc"

MUSIC_BASE=$c000
install_file "assets/backgroundmusic.prg"
SCREEN_BASE=$400

clrscr ;clear screen

;init object
install_file "assets/object.prg",$3000
setSpriteMultiColor1 3
setSpriteMultiColor2 5
setSpriteCostume 0,$3000
setSpriteXY 0,100,100
updateSpriteAttributes 0
showSprite 0

;init player
install_file "assets/player.prg",$3040
setSpriteMultiColor1 13
setSpriteMultiColor2 5
setSpriteCostume 1,$3040
setSpriteXY 1,180,220
updateSpriteAttributes 1
showSprite 1


init:
	;init music
	lda #$00 ; select first tune
	jsr MUSIC_BASE ; init music
	set_raster_irq 0,isr

	;set interrupt
	sei
	ldax #isr
	stax $314
	cli


mainloop:

;set X to a random position
rand16 300
setSpriteX 0,AX
sync_to_rasterline256

;move object downwards
for X,0,to,250
	store X
	setSpriteY 0,X
	sync_to_rasterline256
	restore X
	
next

jmp mainloop

isr:
	asl $d019 ;to clear the interrupt

	;music
	jsr MUSIC_BASE+3

	read_keys_WASDspace
	and $dc00
	and $dc01
	sta joyvalue
	lsr joyvalue ;Player move up
	if cc
	endif
	lsr joyvalue ;Player move down
	if cc
	endif
	lsr joyvalue ;Player move left
	if cc
		dec $d002 
	endif
	lsr joyvalue ;Player move right
	if cc
		inc $d002 
	endif
	lsr joyvalue ;Space
	if cc
	endif
	

	lda $d01e         ; Read sprite-sprite collision register
	and #%00000010    ; Check if sprite 1 collided with sprite 0 (bit 1 set)

	beq nocollision   ; If not, skip color change

	; COLLISION DETECTED
	lda #$0d          ; Reset to original color (light red)
	sta $d028

	jmp $ea31

	nocollision:
	lda #$02          ; Set new color (example: red)
	sta $d028         ; Sprite 1 color

	jmp $ea31


;variables
joyvalue: .byte 00
