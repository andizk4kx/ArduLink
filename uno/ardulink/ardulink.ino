 /*
 * Copyright © 2011-2012 Stéphane Raimbault <stephane.raimbault@gmail.com>
 * License ISC, see LICENSE for more details.
 */

#include <Modbusino.h>

/* Initialize the slave with the ID 1 */
ModbusinoSlave modbusino_slave(1);
/* Allocate a mapping of 10 values */
uint16_t tab_reg[10];

void setup() {
    /* The transfer speed is set to 115200 bauds */
    modbusino_slave.setup(115200);

pinMode(8, INPUT_PULLUP); //Connected to a switch
pinMode(9, INPUT_PULLUP); //Connected to a switch
pinMode(4, OUTPUT); //Connected to a LED
pinMode(5, OUTPUT); //Connected to a LED
pinMode(6, OUTPUT); //Connected to a LED
pinMode(77, OUTPUT);//Connected to a LED
}


void loop() {
    /* Initialize the first register to have a value to read */
    tab_reg[0] = 0x1234;
    tab_reg[2]=analogRead(A0); //Connected to a Poti
    tab_reg[3]=analogRead(A2); //Connected to a LDR
    
    
    digitalWrite(4,tab_reg[6]);
    digitalWrite(5,tab_reg[7]);
    digitalWrite(6,tab_reg[8]);
    digitalWrite(7,tab_reg[9]);
    
    
    tab_reg[4]=digitalRead(8);
    tab_reg[5]=digitalRead(9);
    /* Launch Modbus slave loop with:
       - pointer to the mapping
       - max values of mapping */
    modbusino_slave.loop(tab_reg, 10);
}
