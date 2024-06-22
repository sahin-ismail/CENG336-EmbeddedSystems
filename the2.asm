;THE2_V2 ON SIMULATION ENVIRONMENT
;Group22
;Muhammet ACAR 2264455 
;Ismail Sahin  2264653 
;Onur Ar?kan
    
list P=18F8722

#include <p18f8722.inc>
config OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF

ballCount         udata 0x20  ;how many ball was created?
ballCount	  		    
timeFactor      udata 0x21  ; Will be used for getting the desired 
timeFactor
timer1val_l	udata 0x22
timer1val_l
timer1val_h	udata 0x23
timer1val_h  
timer1val        udata 0x46
timer1val
rightBarPointer udata 0x47
rightBarPointer
leftBarPointer udata 0x48
leftBarPointer
healtyPower udata 0x49   ;this hold hp of gamer ,initial value is 5 and every missed ball decrement by one 
healtyPower 
levelPointer udata 0x51
levelPointer
tempA udata 0x24
tempA
tempB udata 0x25
tempB
tempC udata 0x26
tempC
tempD udata 0x27
tempD
tempE udata 0x28
tempE
tempF udata 0x29
tempF
isrFlag udata 0x30
isrFlag
counter udata 0x31
counter
 
 
 org     0x00
goto    init

org     0x08
goto    isr   
	
init:
    ; (Disable) clear interrupt & timer regs
    clrf    INTCON
    clrf    INTCON2
    clrf    RCON
    clrf    PIE1
    clrf    TMR1L
    clrf    TMR1H 
    clrf    TMR0L
    clrf    TMR0H 
    
    ; Configure Output Ports
    clrf    LATA
    clrf    LATB
    clrf    LATC
    clrf    LATD
    clrf    LATE
    clrf    LATF
    clrf    LATG
    clrf    LATH
    clrf    LATJ
    
    clrf    TRISA
    clrf    TRISB
    clrf    TRISC
    clrf    TRISD
    clrf    TRISE
    clrf    TRISF
    clrf    TRISG
    clrf    TRISH
    clrf    TRISJ
    
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    clrf    PORTF
    clrf    PORTG
    clrf    PORTH
    clrf    PORTJ
    
    movlw h'0F' ; Configure A/D
    movwf ADCON1 ; for digital inputs
    
    ;This is game area ... A to F 
    movlw   b'00111111'
    movwf    TRISA
    movwf    TRISB
    movwf    TRISC
    movwf    TRISD
    movwf    TRISE
    movwf    TRISF
    
    ;this is bar action button  0 for starting 2 for right move 3 for left move
    movlw   b'11111111'
    movwf    TRISG
    
    
   ; H and J port which is related with 7-segment display 
    movlw   b'11110000'
    movwf    TRISH
    
    movlw   b'00000000'    
    movwf    TRISJ  
            
    ;Initialize Timer0 -  Configure such that, it will overflow every 5ms
    
    movlw   b'01000111' ; Disable Timer0 by setting TMR0ON to 0 (for now)
    movwf   T0CON       ; T0CON = b'01000100'
	
    ;Initialize Timer1
    movlw   b'11000000' ;Disable Timer1 by setting T1CON to 0 (for now)
    movwf   T1CON 
    
    
; Enable Global and Timer0 overflow interrupts
    movlw   b'10100000'    ;Global interrupt and timer0 interrrupt active
    movwf   INTCON
    bsf     T1CON, 0        ; Start timer1

    
    main:
	btfss	PORTG, 0 ; check if RG0 is pressed
	goto	main
	goto   theGameIsStarted
   

		
    theGameIsStarted:
	movlw h'3D';500ms for level1  prevalue should be 100 with 1:32 prescale value
	movwf TMR0 
	bsf	T0CON, 7 ; Start Timer0 by setting TMR0ON to 1
	
	;level value=1
	movlw h'01'
	movwf levelPointer
	
	;isrFlag = 0
	movlw h'00'
	movwf isrFlag
	
	;healtypower initial value 5 assigned
	movlw h'05'
	movwf healtyPower
	
	;createdBallCounter = 0  initially
	movlw h'00'
	movwf ballCount
	
	;7-segment display 
	movlw   b'01100000' ; 1(one) is shown D3 display => Current Game level
	movwf   LATJ
	bsf	LATH, 0
	;wait a little
        movlw   b'10110110' ; 5(five) is shown D0 display => Current Healty Power
	movwf   LATJ
	bsf	LATH, 3
       
	; bar is generated initially,[RA5,RB5]
        movlw b'00100000'
	movwf LATA
	movwf LATB
	
	movlw h'00'
	movwf leftBarPointer
	movlw h'01'
	movwf rightBarPointer

		
 
	movff	TMR1L , timer1val_l  
	movff	TMR1H , timer1val_h
	goto menu
	

rightOneWithG2:
    btfsc PORTG,2
    goto rightOneWithG2
    movlw b'000000011'   ; right bar smaller than F block this means that it can move right
    cpfslt rightBarPointer
    goto menu
    incf rightBarPointer 
    incf leftBarPointer
    changeMoveBarRight:
	movlw b'00000001'
	cpfseq rightBarPointer
	goto next1
	
	
        bcf LATC,5
	bcf LATD,5
	goto menu
	
	next1:
	    movlw b'00000010'
	    cpfseq rightBarPointer
	    goto next2

	    bcf LATA,5
	  	    
	    bsf LATC,5
	    goto menu
	next2:
	    movlw b'00000011'
	    cpfseq rightBarPointer
	    goto menu

	    bcf LATB,5
	    bsf LATD,5
	     goto menu
       
	    
leftOneWithG3:
    btfsc PORTG,3
    goto leftOneWithG3
    movlw b'000000000'
    cpfsgt leftBarPointer
    goto menu
    decf rightBarPointer 
    decf leftBarPointer
    changeMoveBarLeft:
	movlw b'00000000'
	cpfseq leftBarPointer
	goto back1
		
	bcf LATC,5
	bsf LATA,5
	
	back1:
	    movlw b'00000001'
	    cpfseq leftBarPointer
	    goto back2

	    bcf LATD,5
	    bsf LATB,5
	back2:
	    movlw b'00000010'
	    cpfseq leftBarPointer
	    goto menu 
           
	   
	    bsf LATD,5
	    bsf LATC,5
	    
            goto menu 
    
	
newBall:
		
	  
		btfss timer1val_l , 0     ; last element checked
		goto lastBit__0
		goto lastBit__1

	    lastBit__0:

		btfsc timer1val_l , 1
		goto   lastBit_10
		goto   lastBit_00
		

	    lastBit__1:

		btfss timer1val_l , 1
		goto   lastBit_01
		goto   lastBit_11

	    lastBit_00:

		btfss timer1val_l , 2
		goto   lastBit000
		goto   lastBit100

	    lastBit_01:

		btfss timer1val_l , 2
		goto   lastBit001
		goto   lastBit101

	    lastBit_10:

		btfss timer1val_l , 2
		goto   lastBit010
		goto  lastBit110

	    lastBit_11:

		btfss timer1val_l , 2
		goto   lastBit011
		goto   lastBit111

	    lastBit000:

		bsf LATA,0
		incf ballCount
                goto shiftingRight
		   
		  	
	   lastBit100:

		bsf LATA, 0
		incf ballCount
		goto shiftingRight

	    lastBit001:

		bsf  LATB,0
		incf ballCount
		goto shiftingRight

	    lastBit101:

		bsf LATB,0
		incf ballCount
	        goto shiftingRight
	    lastBit010:

		bsf LATC,0
		incf ballCount
		goto shiftingRight

	    lastBit110:

		bsf LATC,0
		incf ballCount
		goto shiftingRight

	    lastBit011:

		bsf LATD,0
		incf ballCount
		goto shiftingRight
		   
	   lastBit111:
		bsf LATD,0
		incf ballCount
		goto shiftingRight
		
shiftingRight:  
	movlw   h'01'   
	cpfseq levelPointer
	goto level2.1check
	rrncf timer1val_l,1
	return
    level2.1check:
	movlw   h'02'   
	cpfseq levelPointer
	goto level3.1check
	rrncf timer1val_l,1
	rrncf timer1val_l,1
	rrncf timer1val_l,1
	return
    level3.1check:
	movlw   h'03'   
	cpfseq levelPointer
	goto shiftingRight
	rrncf timer1val_l,1
	rrncf timer1val_l,1
	rrncf timer1val_l,1
	rrncf timer1val_l,1
	rrncf timer1val_l,1
	return
	

	
checkBallCatchOrLoss:
        
    ; this condition is bar located 'AB[5]'
    movlw h'00'
    cpfseq leftBarPointer
    goto x__xxx
    btfss LATC,6
    goto lookDport
    bcf LATC,6
    goto gameOver
    lookDport:
	btfss LATD,6
	goto lookEport
	bcf LATD,6
	goto gameOver
	lookEport:
	btfss LATE,6
	goto lookFport
	bcf LATE,6
	goto gameOver
	    lookFport:
	    btfss LATF,6
	    return
	    bcf LATF,6
	    goto gameOver
	    
 ; this condition is bar located 'BC[5]'
 x__xxx:
    movlw h'01'
    cpfseq leftBarPointer
    goto xx__xx
    btfss LATA,6
    goto lookDport2
    bcf LATA,6
    goto gameOver
    lookDport2:
	btfss LATD,6
	goto lookEport2
	bcf LATD,6
	goto gameOver
	lookEport2:
	btfss LATE,6
	goto lookFport2
	bcf LATE,6
	goto gameOver
	    lookFport2:
	    btfss LATF,6
	    return
	    bcf LATF,6
	    goto gameOver	
	    
 ; this condition is bar located 'CD[5]'
 xx__xx:
    movlw h'02'
    cpfseq leftBarPointer
    goto menu
    btfss LATA,6
    goto lookBport3
    bcf LATA,6
    goto gameOver
    lookBport3:
	btfss LATB,6
	goto lookEport3
	bcf LATB,6
	goto gameOver
	lookEport3:
	btfss LATE,6
	goto lookFport3
	bcf LATE,6
	goto gameOver
	    lookFport3:
	    btfss LATF,6
	    return
	    bcf LATF,6
	    goto gameOver
	    

gameOver: ;check gamer is gameOver ?
    decf healtyPower  ;decfsz healtyPower
    movlw h'00'
    cpfseq healtyPower
    goto update7segmentDisplay
    goto init    ;if game over goto init beginning of game!
    
  update7segmentDisplay:
    ;update 7 segment display
	movlw h'01'
	cpfseq healtyPower
	goto display2
	movlw   b'01100000' 
	movwf   LATJ
	bsf	LATH, 3
	display2:
	    movlw h'02'
	    cpfseq healtyPower
	    goto display3
	    movlw   b'11011010' 
	    movwf   LATJ
	    bsf	LATH, 3
	display3:
	     movlw h'03'
	    cpfseq healtyPower
	    goto display4
	    movlw   b'11110010' 
	    movwf   LATJ
	    bsf	LATH, 3
	display4:
	     movlw h'04'
	    cpfseq healtyPower
	    goto display5
	    movlw   b'01100110' 
	    movwf   LATJ
	    bsf	LATH, 3
	display5:
	     movlw h'05'
	    cpfseq healtyPower
	    return
	    movlw   b'10110110' 
	    movwf   LATJ
	    bsf	LATH, 3
	
    return
	
levelUp:
        movlw h'01'
	cpfseq levelPointer
	goto display2Level
	movlw   b'01100000' 
	movwf   LATJ
	bsf	LATH, 0
	return
	display2Level:
	    movlw h'02'
	    cpfseq levelPointer
	    goto display3Level
	    movlw   b'11011010' 
	    movwf   LATJ
	    bsf	LATH, 0
	    return
	display3Level:
	    movlw h'03'
	    cpfseq levelPointer
	    return
	    movlw   b'11110010' 
	    movwf   LATJ
	    bsf	LATH, 0
  	  
	return
	
newPlaces:
   ;condition0:
    
    movlw h'00'
    cpfseq leftBarPointer
    goto condition1
    
    movff LATA,tempA
    bcf tempA,5
    rlncf tempA 
    bsf tempA,5
     bcf tempA,7
    movff tempA,LATA
    
    movff LATB,tempB
    bcf tempB,5
    rlncf tempB 
    bsf tempB,5
    bcf tempB,7
   movff tempB,LATB
       
	 movff LATC,tempC
        rlncf tempC
	bcf tempC,7
	movff tempC,LATC
	
	 movff LATD,tempD
	rlncf tempD
	bcf tempD,7
	movff tempD,LATD

   
        RETURN 
    
 
;-----------------------------------
condition1:
   
    movlw h'01' 
    cpfseq   leftBarPointer
    goto condition2
    
    movff LATC,tempC
     bcf tempC,5
    rlncf tempC 
    bsf tempC,5
     bcf tempC,7
    movff tempC,LATC
    
    movff LATB,tempB
    bcf tempB,5
    rlncf tempB 
    bsf tempB,5
    bcf tempB,7
   movff tempB,LATB
       
       movff LATA,tempA
        rlncf tempA
	bcf tempA,7
	movff tempA,LATA
	
	 movff LATD,tempD
	rlncf tempD
	bcf tempD,7
	movff tempD,LATD

   
        RETURN 
    
   ;-----------------------------------
condition2:	
    movff LATC,tempC
    movlw h'02'
    cpfseq  leftBarPointer
    return
    
   bcf tempC,5
    rlncf tempC 
    bsf tempC,5
     bcf tempC,7
    movff tempC,LATC
    
    movff LATD,tempD
    bcf tempD,5
    rlncf tempD 
    bsf tempD,5
    bcf tempD,7
   movff tempD,LATD
       
        movff LATA,tempA
        rlncf tempA
	bcf tempA,7
	movff tempA,LATA
	
	 movff LATB,tempB
	rlncf tempB
	bcf tempB,7
	movff tempB,LATB
	return
;**********************************************************

updateGame:
     
   
    
  bcf isrFlag,0
  movlw   h'01'   
  cpfseq levelPointer
  goto level2check
  movlw h'3D';   500ms for level1  prevalue shoul be 61 with 1:256 prescale value
  movwf TMR0 
  
   
    incf counter
    movlw h'64'
    cpfseq counter
   
    goto menu
   
    movlw h'00'
    movwf counter
   
  
    call newPlaces
    call newBall
    call checkBallCatchOrLoss
  
     ;if gamer have healtyPower goto level2
    movlw h'00'
    cpfsgt healtyPower  
    goto gameOver
    movlw h'05'
    cpfseq ballCount
    goto menu
    incf levelPointer
    call levelUp 
    goto menu

    

  level2check:
     movlw   h'02'   
     cpfseq levelPointer
     goto level3check
     movlw h'64';400ms for level2  '100'
     movwf TMR0 
     
    incf counter
    movlw h'64'
    cpfseq counter
   
    goto menu
   
    movlw h'00'
    movwf counter
   
     
	call newPlaces
	call newBall
	call checkBallCatchOrLoss
	
;if gamer have healtyPower goto level3
	movlw h'00'
	cpfsgt healtyPower  
	goto gameOver
	movlw h'0F'
	cpfseq ballCount
	goto menu
	incf levelPointer
	call levelUp 
	goto menu
    

  level3check:
      movlw   h'03'   
      cpfseq levelPointer
      return
      movlw h'78';350ms for level3
      movwf TMR0 
      
      incf counter
    movlw h'64'
    cpfseq counter
   
    goto menu
   
    movlw h'00'
    movwf counter
   
          
	call newPlaces
	call newBall
        call checkBallCatchOrLoss
	
	movlw h'00'
	cpfsgt healtyPower  
	goto gameOver
	movlw h'1E'
	cpfseq ballCount
	goto menu
		
	goto init
	
      
;**********************************************************

menu:
	btfsc PORTG,2     ;move bar right side
	goto rightOneWithG2
	btfsc PORTG,3     ;move bar left side 
	goto leftOneWithG3
	btfsc isrFlag,0   ; if interrupt happen
	goto updateGame
	goto menu
		
	

;..........ISR START.............
	
isr: 
  
  btfss	INTCON, 2 ; check if tmr0 flag is set
  retfie
  bcf	INTCON, 2 ; clear tmr0 flag 
 
 
	
 bsf isrFlag ,0
 ; movwf   TMR0L
  
  retfie	FAST  
  
  ;..........ISR END...........................
    

  
   end