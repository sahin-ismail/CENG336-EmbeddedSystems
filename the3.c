/*
  Muhammet Acar   2264455
  Ismail Sahin    2264653

  Let me explain what we did in this HW :

  * Program starts in main function as you know,in here we are checking which
  interrupt can be occur,There are 4 option  because of HW 
specification which are ADIF for ADC ,
  TMROIF,TMR1IF for timers interrupt and RBIF for RB button 4,5,6,7 
bits on change any time interrupt

  * We configure ports before start the main function after that in 
any time  if come interrupt
   program go on in the my_isr function. In here we checked which 
interrupt came.

  * After that,turn back the main function and go to related function 
after some flag is set.

  * These functions can be RB4pressed,tmr0interrupt,tmr1 
interrupt,AdcCalculate.

  * In RB4pressed => we are checking guess==special_function  if so, 
we blinking with TMR1 for 500ms

  * if not the case, we give a hint (down arrow or up 
arrow).Morover,maybe instead of RB4 there are different pins may cause 
interrupt for RBIF which are RB5,RB6,RB7 so we also
  handle this part in  the ISR.

  * In the TMR0interrupt JUST  start ADC by setting GODONE =1

  * IN TMR1interupt,we hold 5s in case of no correct answer in this time,
   and if correct answer comes in time (5s),we set timer1  for 500ms 
to blinking

  *In ADC_calcute, we have ADRESL,ADRESH.because of right justified 
,ADRESL register hold last8bits which is less significant
  also,ADRESH hold first 2 bit which is most significant. I calculate 
total digital number in here and show this value in 7 segment display.

  *There are 2 while loop in main function one of them is provide us 
if program finish somehow
  * again program will be started ,inside while loop is main loop this 
provide all operations actually handled with this part.



  */



#pragma config OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN 
= OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, 
DEBUG = OFF

#include <xc.h>
#include "breakpoints.h"
/*Global variable*/
int counter=0;          // JUST SET correct value for TMR0 AND TMR1
int tmr1Flag=0;       //TMR1 interrupt if entered ISR
int tmr0Flag=0;       //TMR0 interrupt if entered ISR
int adcFlag=0;        //ADC flag if entered ISR
int showAnswer=0;   // After game finish anyway this should be 1
int rB4pressed=0;
int guess=0;        // after player pressed the RB4 ,adc_value will be 
assigned guess

int last8bits=0;    //this is equal ADRESL after conversion
int first2bits=0;   //this is equal ADRESH after conversion
int bit9=0;    // this hold ADRESH -> 0.bit
int bit10=0;   // this hold ADRESH -> 1.bit
int blink=0;   // this is used for turn of and turn on 7 segment 
display like a counter according to mod2 => 1 is turn on, 0 is turn off
int finishedCounter=0; //We hold this counter to finish game if 
finishedCounter=5 this means game finihed and it shoul started again.
int startAgain=0;
int  portBval=0;       //read Port value after RBIF = 1


void init_ports(){
     GIE=0; //tüm interruptlar? aç?yor.

     TRISH0=0;
     TRISH1=0;
     TRISH2=0;
     TRISH3=0;

     TRISJ0=0;
     TRISJ1=0;
     TRISJ2=0;
     TRISJ3=0;
     TRISJ4=0;
     TRISJ5=0;
     TRISJ6=0;
     TRISJ7=0;

     TRISB4=1;
     TRISB5=0;
     TRISB6=0;
     TRISB7=0;

     TRISC1=0;
     TRISC2=0;

     TRISE1=0;
     TRISE2=0;

     TRISD0=0;
     TRISD1=0;
     TRISD2=0;
     TRISD3=0;

     LATJ=0;
     LATH=0;

     GIE=1;


}
void init(){

     INTCON=104; // 01101000 binary  GIE=0 I dont interrupt in this part
     //TMR0 configuration

     T0CON=6; //00001010 //ilk bit enable
                         //son 3 bit presclaer value ,
                         //bi önceki enable value
     TMR0=61629;
     TMR0ON=1;   //START  the TMR0;
     /* for 50sc
     40 MHz
     4 inst cycle = 1 clock cycle
     1 Mhz = 10^3 ns
     1 ins cycle 10 mhz
     1 inst cycle = 10*10^3 ns
     1 saniyede kac cycle  = 10^9--1 saniye--/10^4
                            = 100,000 cycle per nanosecond
      1   100,000
      256 X
     toplam = 25,600,000 ns hepsini döner
      for 16 bit
      65536*100 = 6.553.600 ns = 65536
      50ms = 50.000.000/8-presclaer value- = 6.250.000 = 62500 
//ikisini ç?kar ilk de?ere ver
                                                  //3036 TMR0 ya vercez
     */

     //TMR1 configuration

     T1CON=180;  // PIE GIE TM1IE =1
     TMR1IE=1;   // enable
     TMR1=45029; //ilk de?er         //TMR1=31474;

     guess=0;
     showAnswer=0;
     blink=0;
     finishedCounter=0;

     TMR1ON=1; //TMR1 congfigure
     GIE=1;

}

void adc_init(){

     ADCON0=0X30; // 110000
     ADCON1=0;
     ADCON2=0XAA; //ADCON2=0X82; //10101010
     ADON=1; // ENABLE ADC INTERRUPT BUT NOT START
             // godone convert start

}

void tmr0interrupt(){


     /* I JUST ENABLE ADC enable bits which are  ADIE and GODONE to 
start ADC */
     ADIE=1; //ADC ile alakal? enable
     GODONE=1 ; // now started conversion


     //TMR0 is set again for 50ms

     T0CON=6;
     TMR0=61629;  //61730
     TMR0ON=1;   //START  the TMR0;


     }

void adcCalculate(){
/* We need to calculate binary value to convert decimal value which 
comes from voltage
  We use right justified mode in ADCON2 so ,we need gain last 2 bits 
from the ADRESH and 8bits(all)
ADRESL which compose binary value of the given voltage after that we 
need to calculate
decimal value of this binary value and then lastly,we need to map 
according to HW table and gain result value
for example 5 or 7 etc..
*/
     GIE=0; //interrupt almas?n hesaplarken

     last8bits=ADRESL;

     first2bits=ADRESH;

     bit9=first2bits%2;

     bit9=bit9*256;

     bit10=0;

     if(first2bits>1){

         bit10=512;
     }

     //adc_value means that decimal value of voltage value


     adc_value=bit10+bit9+last8bits;


     adc_complete();

     // after that we map this value according to HW table

     if(0<= adc_value &&  adc_value <=102)
     {
         guess=0;

         LATH = 0b00001000 ;

         LATJ = 0b11111100 ; //write (0)on the D0

     }
     else if(102< adc_value &&  adc_value<=204)
     {
         guess=1;

        LATH = 0b00001000 ;

        LATJ=0b11000000 ;


     }
     else if(204< adc_value &&  adc_value<=306)
     {
         guess=2;

        LATH = 0b00001000 ;

                LATJ = 0b11011010 ; //write (2)on the D0
     }
     else if(306< adc_value && adc_value<=408)
     {
         guess=3;

         LATH = 0b00001000 ;

                LATJ = 0b11110010 ; //write (3)on the D0
     }
     else if(408< adc_value &&  adc_value<=510)
     {
         guess=4;

         LATH = 0b00001000 ;

                LATJ = 0b01100110 ; //write (4)on the D0
     }
     else if(510< adc_value &&  adc_value<=612)
     {
         guess=5;

         LATH = 0b00001000 ;

                LATJ = 0b10110110 ; //write (5)on the D0
     }
     else if(612< adc_value &&  adc_value<=714)
     {
         guess=6;

         LATH = 0b00001000 ;

                LATJ = 0b10111110 ; //write (6)on the D0
     }
     else if(714< adc_value &&  adc_value<=816)
     {
         guess=7;

         LATH = 0b00001000 ;

                LATJ = 0b11100000 ; //write (7)on the D0
     }
     else if(816< adc_value &&  adc_value<=918)
     {
         guess=8;

         LATH = 0b00001000 ;

                LATJ = 0b11111110 ; //write (8)on the D0
     }
     else if(918< adc_value &&  adc_value<=1023)
     {
         guess=9;

         LATH = 0b00001000 ;
                LATJ = 0b11110110 ; //write (9)on the D0
     }
     latjh_update_complete();
     GIE=1; //interrupt alabiliriz
}


void rb4_pressed(){

  rb4_handled();

  rB4pressed = 0 ;

     if(guess<special_number()){

       //This is up arrow
         LATC2=0;
         LATE2=0;
         LATC1=1;
         LATE1=1;
         LATD0=1;
         LATD1=1;
         LATD2=1;
         LATD3=1;
     }
     else if(guess>special_number()){

       //This is down arrow
         LATC1=0;
         LATE1=0;
         LATC2=1;
         LATE2=1;
         LATD0=1;
         LATD1=1;
         LATD2=1;
         LATD3=1;
     }



     else if(special_number()==guess){


         //All interrupts disabled except TMR1
         ADIE=0;
         RBIE=0;
         TMR0ON=0;

          //TURN OFF leds (hint)

         LATC1=0;
         LATE1=0;
         LATC2=0;
         LATE2=0;
         LATD0=0;
         LATD1=0;
         LATD2=0;
         LATD3=0;


         correct_guess();

         //correct Answer..

         //new value for TMR1  for 500ms
         T1CON=180;  // 10110100 // PIE GIE TM1IE =1
         TMR1IE=1;
         TMR1=30257;
         TMR1ON=1;   //TMR1 start
         counter=0;
         showAnswer=1;

     }
      latjh_update_complete();
      latcde_update_complete();

}



void tmr1interrupt(){

     // 500ms DO --> special_number should be shown and 500 ms --> turn off
     //         and special_number should be shown and 500 ms --> turn off


     tmr1Flag=0;

     showAnswer=1;

     blink++;//at the end of game 7 segment turn on if

     finishedCounter++; //this counter hold blink two times to finish game

     //this if block means game finish...
      if(finishedCounter==4) {
          startAgain=0;//restart counter if 0 which means game will 
start again.
          showAnswer=0;
      }

      else{

       //new value for TMR1  for 500ms
         T1CON=180;  // PIE GIE TM1IE =1
         TMR1IE=1;
         TMR1=30257;
         TMR1ON=1;   //TMR1 start

         // Game finish and we should show special number in  7 
Segment display for 2 sec.
     if(blink%2==0){
         //SHOW RESULT TURN ON
         LATH = 0b00001000 ;

         if(special_number()== 0 )
         {

           LATJ = 0b11111100 ;

         }

         else if(special_number()== 1 )
         {

            LATJ = 0b01100000 ;

         }

         else if(special_number()== 2 )
         {

            LATJ = 0b11011010 ;

         }

         else if(special_number()== 3 )
         {

             LATJ = 0b11110010 ;

         }

         else if(special_number()== 4 )
         {

             LATJ = 0b01100110  ;

         }

         else if(special_number()== 5 )
         {

             LATJ = 0b10110110 ;

         }

         else if(special_number()== 6 )
         {

             LATJ = 0b10111110 ;

         }

         else if(special_number()== 7 )
         {

             LATJ = 0b11100000 ;

         }

         else if(special_number()== 8 )
         {

            LATJ = 0b11111110 ;

         }

         else if(special_number()== 9 )
         {

            LATJ = 0b11110110 ;

         }
       }
     else{
         //TURN OFF RESULT FOR 500ms

         LATJ = 0b00000000 ;
         LATH = 0b00001000 ;




     }
      }

          hs_passed();
     latjh_update_complete();
}



void __interrupt() my_isr(void) {


        if(RBIF == 1 ){
                /* For PORTB change interrupt */

         portBval = PORTB ;    //To uncheck flag(RBIF)

         RBIF=0;

         if(PORTBbits.RB4 == 1)
             rB4pressed = 1 ;

         else if(PORTBbits.RB4 == 0 )
             rB4pressed= 0 ;

         else if(PORTBbits.RB5 == 1 || PORTBbits.RB5 == 0)
             rB4pressed = 0 ;

         else if(PORTBbits.RB6 == 1 || PORTBbits.RB6 == 0)
             rB4pressed = 0 ;

         else if(PORTBbits.RB7 == 1 || PORTBbits.RB7 == 0)
             rB4pressed = 0 ;



        }

        if(TMR0IF == 1) {
                /* For Timer0 interrupt */

         tmr0Flag = 1 ;
                TMR0IF = 0 ;
        }

        if(TMR1IF == 1) {
                /* For Timer1 interrupt */
        counter++;
          //When the correct answer come this if block used
        if(showAnswer){

           if(counter>=10){

             tmr1Flag=1;

             counter=0;

            }

         }
         //If not correct answer for 5s used this else block
         else{

             if(counter>=96){

                 tmr1Flag = 1 ;
                 counter=0;
                 game_over();
                 latcde_update_complete();
                 latjh_update_complete();
                }

         }

                TMR1IF = 0 ;
        }

        if(ADIF == 1) {
                /* For ADC interrupt */

                ADIF = 0 ;
         adcFlag=1;

                ADIE = 0 ;
        }
}

void main(void) {

   while(1){

     startAgain = 1 ; //this provide run again if finish program someway
     init_ports();
     init();
     init_complete();
     adc_init();

     while(startAgain){

         if(tmr0Flag){
                 // when the timer0 interrupt ,ADC convert and read value
             tmr0Flag=0;
             tmr0interrupt();
         }
         if(tmr1Flag){
             tmr1Flag=0;
             tmr1interrupt();
         }
         if(adcFlag){
              adcFlag=0;
             adcCalculate();
         }
         if(rB4pressed){

             rb4_pressed();
         }




     }
   }
     return;
}