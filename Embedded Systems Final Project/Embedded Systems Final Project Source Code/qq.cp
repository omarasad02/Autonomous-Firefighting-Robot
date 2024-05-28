#line 1 "C:/Users/TOSHIBA/Desktop/Embedded Systems Final Project Source Code/qq.c"
void init();
void interrupt();

void stop();
void left();
void right();
void forward();
void backward();
void adjust();
void check_fire();

void my_delay(int x);

unsigned int read_ATD_A0();

void check_right();
void check_left();
void check_front_obstacle();


int cnt;
int cnt1;
unsigned int sensor_voltage;
unsigned char Hi_Lo_flag;
unsigned int angle;


void main() {
 init();
 while(1){

 check_right();
 check_left();
 check_front_obstacle();

 adjust();

 check_fire();
 if (PORTB & 0b10000000){
 PORTD = PORTD | 0b00000010;
 my_delay(3000);
 PORTD = PORTD & 0b11111101;
 my_delay(3000);

 }
 }
}



void init(){

 TRISA = 0x01;
 TRISB = 0b01000000;
 TRISC = 0x00;
 TRISD = 0b11111101;

 PORTB = 0x00;
 PORTC = 0x00;
 PORTD = PORTD & 0b11111101;



 OPTION_REG= 0x87;
 TMR0=248;
 INTCON = 0b11100000;

 T1CON=0x01;
 TMR1H=0;
 TMR1L=0;

 CCP1CON=0x08;
 PIE1=PIE1|0x04;
 CCPR1H=2000>>8;
 CCPR1L=2000;

 Hi_Lo_flag = 1;




ADCON0 = 0x41;
ADCON1 = 0xCE;


}





void interrupt(){
 if(INTCON & 0x04){
 TMR0=248;
 cnt++;
 cnt1++;
 INTCON = INTCON & 0xFB;
 }
if(PIR1&0x04){
 if(Hi_Lo_flag){
 CCPR1H= angle >>8;
 CCPR1L= angle;
 Hi_Lo_flag=0;
 CCP1CON=0x09;
 TMR1H=0;
 TMR1L=0;
 }
 else{
 CCPR1H= (40000 - angle) >>8;
 CCPR1L= (40000 - angle);
 CCP1CON=0x08;
 Hi_Lo_flag=1;
 TMR1H=0;
 TMR1L=0;

 }

PIR1=PIR1&0xFB;
 }
 if(PIR1&0x01){

 PIR1=PIR1&0xFE;
 }
}




unsigned int read_ATD_A0(){
ADCON0 = ADCON0 | 0x04;
while(ADCON0 & 0x04);
return ((ADRESH<<8) | ADRESL);
}


void my_delay(int const x){
 cnt=0;
 while(cnt<x);

}

 void check_right(){

if(PORTD & 0b00010000){
 cnt1 = 0;

 while(!(PORTD & 0b10000000)){

 if (cnt1 >= 5000) break;
 right();

 }

stop();
}
 }

void check_front_obstacle(){
sensor_voltage = read_ATD_A0();


 while(sensor_voltage >= 100 && sensor_voltage <= 990){

 if(!(PORTB & 0b01000000))
 break;
 sensor_voltage = read_ATD_A0();
 forward();
 }
 stop();
}

void check_left(){

if (PORTD & 0b00100000){
 cnt1 = 0;

 while(!(PORTD & 0b10000000)){
 if (cnt1 >= 5000) break;
 left();
 }

stop();
}
}





void right(){
 PORTC = (PORTC & 0b00001111) | 0b10010000;

 my_delay(4);
 stop();
 my_delay(4);

}


void left(){
 PORTC = (PORTC & 0b00001111)| 0b01100000;

 my_delay(4);
 stop();
 my_delay(4);

}


void stop(){
 PORTC = PORTC & 0b00001111;
}


void forward(){
 PORTC = (PORTC & 0b00001111)| 0b10100000;

 my_delay(3);
 stop();
 my_delay(3);

}

void backward(){
 PORTC = (PORTC & 0b00001111)| 0b01010000;

 my_delay(3);
 stop();
 my_delay(3);
}



void adjust(){
 sensor_voltage = read_ATD_A0();
 while(sensor_voltage < 100){
 backward();
 sensor_voltage = read_ATD_A0();
}
stop();
}

void check_fire(){


 sensor_voltage = read_ATD_A0();
 while (PORTD & 0b10000000)
 {
 if(sensor_voltage < 100 || sensor_voltage > 950) break;


 PORTD = PORTD | 0b00000010;
 my_delay(3000);
 PORTD = PORTD & 0b11111101;
 my_delay(3000);


 angle=3500;
 my_delay(1500);
 angle=1000;
 my_delay(1500);
 }

PORTD = PORTD & 0b11111101;
angle = 2250;
}
