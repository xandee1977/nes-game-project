    .inesprg 1   ; um (1) banco do codigo do programa
    .ineschr 1   ; um (1) banco de dados de imagem
	.inesmap 0   ; mapper 0
	.inesmir 1   ; espelhamento (mirror) sempre 1.

    .bank 1   ; following goes in bank 1
    .org $FFFA  ; start at $FFFA
    .dw 0    ; dw stands for Define Word and we give 0 as address for NMI routine
    .dw Start ; give address of start of our code for execution on reset of NES.
    .dw 0   ; give 0 for address of VBlank interrupt handler, we tell PPU not to
    ; make an interrupt for VBlank.         

    ; Banco de codigo
	.bank 0   ; bank 0.
    .org $8000  ; vai para o endereco $8000.        

    ;;; CODIGO DA ROM INICIA AQUI
    
	Start:    
    	;Configurando o Picture Processor Unit (PPU)
    	lda #%00001000
    	sta $2000
    	lda #%00011110
    	sta $2001
    
    	;; PALETA
    	lda #$3F   ; Grava o endereco onde a paleta sera armaznada 
		sta $2006  ; $2007 vai comecar a leitura a partir do endereco
		lda #$00   ; informado: $3F00 (Nota: ja que so podemos gravar 1 byt	e por vez
		sta $2006  ; gravamos o endereco em duas partes)
	
	;; Carregamento da paleta
	ldx #$00   ; Carrega X com 0.
	loadpal:   ; Note que as labels sao sequidas por : e TAB
		lda tilepal, x   ; Carrega A com o endereco da paleta (ourpal) incrementado de x
		sta $2007       ; Grava a proxima paleta no endereco $2007
		inx             ; incrementa x
		cpx #32         ; Compara X com 32 que e o numero de paletas que podemos carregar
		bne loadpal     ; enquanto X nao for igual a 32 (Branch on Not Equal) carrega a paleta    

    waitblank:         ; Ira esperar pelo VBlank acima
    	lda $2002  ; Carrega A com o endereco de $2002
    	bpl waitblank  ; Se o bit 7 nao esta setado (not VBlank) continua chegando

    	lda #$00   ; Linhas inseridas em $2003
    	sta $2003  ; para dizer 
    	lda #$00   ; para $2004 iniciar
    	sta $2003  ; em $0000.

    	lda #50  ; Carrega valor Y
    	sta $2004 ; Grava Y em A
    	lda #$00  ; ladrilho numero 0
    	sta $2004 ; amazena o numero do ladrilho
    	lda #$00 ; especial "junk"
    	sta $2004 ; armazena especial "junk"
    	lda #20  ; Carrega valor X
    	sta $2004 ; Armazena valor X ;e sim, PRECISA ser nessa ordem.

	infin:
    	jmp infin   ; Pula para infin. este loop nao acaba. :)

	;; Arquivo da paleta
	tilepal: .incbin "nes.pal" ; include and label our palette		
		
	; Banco de imagem
    .bank 2        ; Mudando para o banco 2
    .org $0000    ; start at $0000
	;.incbin "our.bkg"  ; Incluindo arquivo binario com imagem de fundo
    ; data.
    .incbin "tileset01.chr"  ; Incluindo binario com com personagem