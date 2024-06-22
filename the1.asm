
LIST    P=18F8722

#INCLUDE <p18f8722.inc> 
    
CONFIG OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF


 last_led       udata 0X20
 last_led
 d1       udata 0X22
 d1
 d2       udata 0X24
 d2
 d3       udata 0X26
 d3
 ra4_pressed	    udata 0x28
 ra4_pressed
 number	    udata 0x30
 number
 number2	    udata 0x32
 number2

ORG     0x00
goto    main

init
    movlw b'00010000' 
    movwf TRISA 
    clrf  LATA ; output
    clrf PORTA ; input

    movlw h'00' 
    movwf TRISB 
    clrf  LATB 

    movlw h'00' 
    movwf TRISC 
    clrf  LATC 

    movlw h'00' 
    movwf TRISD 
    clrf  LATD 

    movlw b'00011000' 
    movwf TRISE 
    clrf  LATE 
    clrf PORTE 
    movlw h'0F'
    movwf LATB 
    movwf LATC
    movlw h'FF'
    movwf LATD 
    call delay 
    movlw h'00'
    movwf LATB 
    movwf LATC 
    movwf LATD 

    return

delay 
movlw h'35' 
movwf d1
movwf d2
movwf d3
dongu1:
decfsz d1
goto dongu2
goto delaycikis1
dongu2:
decfsz d2
goto dongu3
goto dongu1
dongu3:
decfsz d3
goto dongu3
goto dongu2
delaycikis1:
clrf d1
clrf d2
clrf d3
return
	  
calculator
movlw 0 
movwf ra4_pressed
movlw 1	
goto operation
	    
	
operation
	btfsc PORTE,3
	goto re3basildi
	btfss PORTA,4 
	goto operation
	goto ra4basildi
ra4basildi
	btfsc PORTA,4
	goto ra4basildi
	incf ra4_pressed
	goto operation

re3basildi
	btfsc PORTE,3
	goto re3basildi
	movlw 1
	btfss ra4_pressed,0
	goto subtraction
	goto addition
	
addition
	movlw 0
	movwf number
	movlw 0
	movwf number2	
	goto portb
portb	
btfsc PORTE,3
goto portccontrol
btfsc PORTE,4
goto incr
goto portb	

incr
btfsc PORTE,4
goto incr
incf number,1

one
movlw 1
cpfseq number
goto two
movlw b'00000001'
movwf LATB
goto portb	

two	
movlw 2
cpfseq number
goto three
movlw b'00000011'
movwf LATB
goto portb	

three
movlw 3
cpfseq number
goto four
movlw b'00000111'
movwf LATB
goto portb

four	
movlw 4
cpfseq number
goto ini
movlw b'00001111'
movwf LATB
goto portb

ini
movlw b'00000000'	
movwf LATB
clrf number
goto portb	

portccontrol
btfsc PORTE,3
goto portccontrol	

portc	
btfsc PORTE,3
goto portd
btfsc PORTE,4
goto incrc
goto portc

incrc
btfsc PORTE,4
goto incrc
incf number2,1

onec
movlw 1
cpfseq number2
goto twoc
movlw b'00000001'
movwf LATC
goto portc	

twoc	
movlw 2
cpfseq number2
goto threec
movlw b'00000011'
movwf LATC
goto portc	

threec
movlw 3
cpfseq number2
goto fourc
movlw b'00000111'
movwf LATC
goto portc

fourc	
movlw 4
cpfseq number2
goto inic
movlw b'00001111'
movwf LATC
goto portc

inic
movlw b'00000000'	
movwf LATC
clrf number2
goto portc
	
portd
btfsc PORTE,3
goto portd
movlw 0	
addwf number,0
addwf number2,1	

onecd
movlw 1
cpfseq number2
goto twocd
movlw b'00000001'
movwf LATD	

twocd	
movlw 2
cpfseq number2
goto threecd
movlw b'00000011'
movwf LATD	

threecd
movlw 3
cpfseq number2
goto fourcd
movlw b'00000111'
movwf LATD

fourcd	
movlw 4
cpfseq number2
goto fivecd
movlw b'00001111'
movwf LATD

fivecd
movlw 5
cpfseq number2
goto sixcd
movlw b'00011111'
movwf LATD	

sixcd
movlw 6
cpfseq number2
goto sevencd
movlw b'00111111'
movwf LATD

sevencd
movlw 7
cpfseq number2
goto eightcd
movlw b'01111111'
movwf LATD	

eightcd
movlw 8
cpfseq number2
goto inicd
movlw b'11111111'
movwf LATD	

	
inicd
call delay		
movlw b'00000000'	
movwf LATC
movwf LATB
movwf LATD	
goto calculator	
	

	
subtraction
movlw 0
movwf number
movlw 0
movwf number2	
goto portbs

portbs	
btfsc PORTE,3
goto portccontrols
btfsc PORTE,4
goto incrs
goto portbs	

incrs
btfsc PORTE,4
goto incrs
incf number,1

zeros
movlw 0
cpfseq number
goto ones
movlw b'00000000'
movwf LATB
goto portbs
	
ones
movlw 1
cpfseq number
goto twos
movlw b'00000001'
movwf LATB
goto portbs	

twos	
movlw 2
cpfseq number
goto threes
movlw b'00000011'
movwf LATB
goto portbs	

threes
movlw 3
cpfseq number
goto fours
movlw b'00000111'
movwf LATB
goto portbs

fours	
movlw 4
cpfseq number
goto inis
movlw b'00001111'
movwf LATB
goto portbs

inis
movlw b'00000000'	
movwf LATB
clrf number
goto portbs	

portccontrols
btfsc PORTE,3
goto portccontrols	

portcs	
btfsc PORTE,3
goto portds
btfsc PORTE,4
goto incrcs
goto portcs

incrcs
btfsc PORTE,4
goto incrcs
incf number2,1

zerocs
movlw 0
cpfseq number2
goto onecs
movlw b'00000000'
movwf LATC
goto portcs
	
onecs
movlw 1
cpfseq number2
goto twocs
movlw b'00000001'
movwf LATC
goto portcs	

twocs	
movlw 2
cpfseq number2
goto threecs
movlw b'00000011'
movwf LATC
goto portcs	

threecs
movlw 3
cpfseq number2
goto fourcs
movlw b'00000111'
movwf LATC
goto portcs

fourcs	
movlw 4
cpfseq number2
goto inics
movlw b'00001111'
movwf LATC
goto portcs

inics
movlw b'00000000'	
movwf LATC
clrf number2
goto portcs
	
portds
btfsc PORTE,3
goto portds
movlw 0	
addwf number,0
subwf number2,1	

zerocds
movlw 0
cpfseq number2
goto onecds
movlw b'00000000'
movwf LATD
	
onecds
movlw 1
cpfseq number2
goto twocds
movlw b'00000001'
movwf LATD	

twocds	
movlw 2
cpfseq number2
goto threecds
movlw b'00000011'
movwf LATD	

threecds
movlw 3
cpfseq number2
goto fourcds
movlw b'00000111'
movwf LATD

fourcds	
movlw 4
cpfseq number2
goto fivecds
movlw b'00001111'
movwf LATD

fivecds
movlw 5
cpfseq number2
goto sixcds
movlw b'00011111'
movwf LATD	

sixcds
movlw 6
cpfseq number2
goto sevencds
movlw b'00111111'
movwf LATD

sevencds
movlw 7
cpfseq number2
goto eightcds
movlw b'01111111'
movwf LATD	

eightcds
movlw 8
cpfseq number2
goto onecdsn
movlw b'11111111'
movwf LATD	


	
onecdsn
movlw -1
cpfseq number2
goto twocdsn
movlw b'00000001'
movwf LATD	

twocdsn	
movlw -2
cpfseq number2
goto threecdsn
movlw b'00000011'
movwf LATD	

threecdsn
movlw -3
cpfseq number2
goto fourcdsn
movlw b'00000111'
movwf LATD

fourcdsn	
movlw -4
cpfseq number2
goto fivecdsn
movlw b'00001111'
movwf LATD

fivecdsn
movlw -5
cpfseq number2
goto sixcdsn
movlw b'00011111'
movwf LATD	

sixcdsn
movlw -6
cpfseq number2
goto sevencdsn
movlw b'00111111'
movwf LATD

sevencdsn
movlw -7
cpfseq number2
goto eightcdsn
movlw b'01111111'
movwf LATD	

eightcdsn
movlw -8
cpfseq number2
goto inicds
movlw b'11111111'
movwf LATD	
	
	
	
inicds
call delay		
movlw b'00000000'	
movwf LATC
movwf LATB
movwf LATD	
goto calculator	
	
	

	
	
main:
    call init
    goto calculator
    end