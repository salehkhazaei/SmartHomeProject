
;CodeVisionAVR C Compiler V2.05.3 Standard
;(C) Copyright 1998-2011 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega32A
;Program type             : Application
;Clock frequency          : 12.000000 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : int, width
;(s)scanf features        : int, width
;External RAM size        : 0
;Data Stack size          : 512 byte(s)
;Heap size                : 0 byte(s)
;Promote 'char' to 'int'  : Yes
;'char' is unsigned       : Yes
;8 bit enums              : Yes
;Global 'const' stored in FLASH     : No
;Enhanced function parameter passing: Yes
;Enhanced core instructions         : On
;Smart register allocation          : On
;Automatic register allocation      : On

	#pragma AVRPART ADMIN PART_NAME ATmega32A
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2143
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0060
	.EQU __SRAM_END=0x085F
	.EQU __DSTACK_SIZE=0x0200
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _buf=R5
	.DEF _state=R6
	.DEF _lcd_backlight=R8
	.DEF __lcd_x=R4
	.DEF __lcd_y=R11
	.DEF __lcd_maxx=R10

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  _ext_int0_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _adc_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

__base_y_G100:
	.DB  0x80,0xA0,0xC0,0xE0
_tbl10_G101:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G101:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

_0x0:
	.DB  0x57,0x65,0x6C,0x63,0x6F,0x6D,0x65,0x2E
	.DB  0x0,0x53,0x74,0x61,0x72,0x74,0x69,0x6E
	.DB  0x67,0x20,0x53,0x79,0x73,0x74,0x65,0x6D
	.DB  0x2E,0x0,0x52,0x65,0x63,0x65,0x69,0x76
	.DB  0x69,0x6E,0x67,0x0,0x53,0x65,0x6E,0x64
	.DB  0x20,0x73,0x65,0x6E,0x73,0x6F,0x72,0x73
	.DB  0x20,0x64,0x61,0x74,0x61,0x0,0x43,0x6C
	.DB  0x65,0x61,0x72,0x20,0x6F,0x75,0x74,0x70
	.DB  0x75,0x74,0x0,0x53,0x65,0x74,0x20,0x6F
	.DB  0x75,0x74,0x70,0x75,0x74,0x0,0x50,0x75
	.DB  0x6C,0x6C,0x20,0x6F,0x75,0x74,0x70,0x75
	.DB  0x74,0x0,0x49,0x6E,0x76,0x61,0x6C,0x69
	.DB  0x64,0x20,0x72,0x65,0x71,0x0
_0x2040060:
	.DB  0x1
_0x2040000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x09
	.DW  _0x1D
	.DW  _0x0*2

	.DW  0x11
	.DW  _0x1D+9
	.DW  _0x0*2+9

	.DW  0x0A
	.DW  _0x1D+26
	.DW  _0x0*2+26

	.DW  0x12
	.DW  _0x1D+36
	.DW  _0x0*2+36

	.DW  0x0D
	.DW  _0x1D+54
	.DW  _0x0*2+54

	.DW  0x0B
	.DW  _0x1D+67
	.DW  _0x0*2+67

	.DW  0x0C
	.DW  _0x1D+78
	.DW  _0x0*2+78

	.DW  0x0C
	.DW  _0x1D+90
	.DW  _0x0*2+90

	.DW  0x01
	.DW  __seed_G102
	.DW  _0x2040060*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,__SRAM_START
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x260

	.CSEG
;/*****************************************************
;This program was produced by the
;CodeWizardAVR V2.05.3 Standard
;Automatic Program Generator
;© Copyright 1998-2011 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;
;Project :
;Version :
;Date    : 12/27/2015
;Author  : Saleh
;Company : GRCG
;Comments:
;
;
;Chip type               : ATmega32A
;Program type            : Application
;AVR Core Clock frequency: 12.000000 MHz
;Memory model            : Small
;External RAM size       : 0
;Data Stack size         : 512
;*****************************************************/
;
;#include <mega32a.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
;
;#include <alcd_ks0073.h>
;
;#include <delay.h>
;#include <stdio.h>
;#include <stdlib.h>
;#include <string.h>
;
;#ifndef RXB8
;	#define RXB8 1
;#endif
;
;#ifndef TXB8
;	#define TXB8 0
;#endif
;
;#ifndef UPE
;	#define UPE 2
;#endif
;
;#ifndef DOR
;	#define DOR 3
;#endif
;
;#ifndef FE
;	#define FE 4
;#endif
;
;#ifndef UDRE
;	#define UDRE 5
;#endif
;
;#ifndef RXC
;	#define RXC 7
;#endif
;
;#define FRAMING_ERROR (1<<FE)
;#define PARITY_ERROR (1<<UPE)
;#define DATA_OVERRUN (1<<DOR)
;#define DATA_REGISTER_EMPTY (1<<UDRE)
;#define RX_COMPLETE (1<<RXC)
;
;#define F_CPU 16000000
;#define BAUDRATE 9600
;#define BAUD_PRESCALLER (((F_CPU / (BAUDRATE * 16UL))) - 1)
;
;#define FIRST_ADC_INPUT 0
;#define LAST_ADC_INPUT 7
;#define ADC_VREF_TYPE 0x20
;
;unsigned char adc_data[8];
;char output[12];
;char buf;
;int state;
;int lcd_backlight;
;
;unsigned char USART_receive(void){
; 0000 0051 unsigned char USART_receive(void){

	.CSEG
_USART_receive:
; 0000 0052 	while(!(UCSRA & (1<<RXC)));
_0x3:
	SBIS 0xB,7
	RJMP _0x3
; 0000 0053 	return UDR;
	IN   R30,0xC
	RET
; 0000 0054 }
;
;/* Function to send byte/char */
;void USART_send( unsigned char data){
; 0000 0057 void USART_send( unsigned char data){
_USART_send:
; 0000 0058 	while(!(UCSRA & (1<<UDRE)));
	ST   -Y,R26
;	data -> Y+0
_0x6:
	SBIS 0xB,5
	RJMP _0x6
; 0000 0059 	UDR = data;
	LD   R30,Y
	OUT  0xC,R30
; 0000 005A }
	JMP  _0x20C0001
;
;/* Send string */
;/*
;void USART_putstring(char* StringPtr){
;	while(*StringPtr != 0x00){
;		USART_send(*StringPtr);
;	StringPtr++;}
;}
;*/
;// ADC interrupt service routine
;// with auto input scanning
;interrupt [ADC_INT] void adc_isr(void)
; 0000 0067 {
_adc_isr:
	ST   -Y,R24
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0000 0068 	static unsigned char input_index=0;
; 0000 0069 	// Read the 8 most significant bits
; 0000 006A 	// of the AD conversion result
; 0000 006B 	adc_data[input_index]=ADCH;
	LDS  R26,_input_index_S0000002000
	LDI  R27,0
	SUBI R26,LOW(-_adc_data)
	SBCI R27,HIGH(-_adc_data)
	IN   R30,0x5
	ST   X,R30
; 0000 006C 	// Select next ADC input
; 0000 006D 	if (++input_index > (LAST_ADC_INPUT-FIRST_ADC_INPUT))
	LDS  R26,_input_index_S0000002000
	SUBI R26,-LOW(1)
	STS  _input_index_S0000002000,R26
	CPI  R26,LOW(0x8)
	BRLO _0x9
; 0000 006E 	   input_index=0;
	LDI  R30,LOW(0)
	STS  _input_index_S0000002000,R30
; 0000 006F 	ADMUX=(FIRST_ADC_INPUT | (ADC_VREF_TYPE & 0xff))+input_index;
_0x9:
	LDS  R30,_input_index_S0000002000
	SUBI R30,-LOW(32)
	OUT  0x7,R30
; 0000 0070 	// Delay needed for the stabilization of the ADC input voltage
; 0000 0071 	delay_us(10);
	__DELAY_USB 40
; 0000 0072 	// Start the AD conversion
; 0000 0073 	ADCSRA|=0x40;
	SBI  0x6,6
; 0000 0074 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R24,Y+
	RETI
;
;// External Interrupt 0 service routine
;interrupt [EXT_INT0] void ext_int0_isr(void)
; 0000 0078 {
_ext_int0_isr:
	ST   -Y,R30
	ST   -Y,R31
; 0000 0079 	// Place your code here
; 0000 007A     lcd_backlight = 10;
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	MOVW R8,R30
; 0000 007B }
	LD   R31,Y+
	LD   R30,Y+
	RETI
;
;// Timer 0 overflow interrupt service routine
;void update(void)
; 0000 007F {
_update:
; 0000 0080 /*
; 0000 0081     // Place your code here
; 0000 0082 	char str[16];
; 0000 0083     // 8 sensor, 12 output (8 220V, 4 5V)
; 0000 0084     // 16 chars
; 0000 0085     switch ( state )
; 0000 0086     {
; 0000 0087         case 0:
; 0000 0088 //            sprintf(str,"SSM Smart Home %c",computer_state);
; 0000 0089             break ;
; 0000 008A         case 1:
; 0000 008B             sprintf(str,"S1:%d,S2:%d,C%c",adc_data[0],adc_data[1],buf);
; 0000 008C             break ;
; 0000 008D         case 2:
; 0000 008E             sprintf(str,"S3:%d,S4:%d,C%c",adc_data[2],adc_data[3],buf);
; 0000 008F             break ;
; 0000 0090         case 3:
; 0000 0091             sprintf(str,"S5:%d,S6:%d,C%c",adc_data[4],adc_data[5],buf);
; 0000 0092             break ;
; 0000 0093         case 4:
; 0000 0094             sprintf(str,"S7:%d,S8:%d,C%c",adc_data[6],adc_data[7],buf);
; 0000 0095             break ;
; 0000 0096         case 5:
; 0000 0097             sprintf(str,"O0:%d,O1:%d,C%c",output[0],output[1],buf);
; 0000 0098             break ;
; 0000 0099         case 6:
; 0000 009A             sprintf(str,"O2:%d,O3:%d,C%c",output[2],output[3],buf);
; 0000 009B             break ;
; 0000 009C         case 7:
; 0000 009D             sprintf(str,"O4:%d,O5:%d,C%c",output[4],output[5],buf);
; 0000 009E             break ;
; 0000 009F         case 8:
; 0000 00A0             sprintf(str,"O6:%d,O7:%d,C%c",output[6],output[7],buf);
; 0000 00A1             break ;
; 0000 00A2     }
; 0000 00A3     lcd_clear();
; 0000 00A4     lcd_puts(str);
; 0000 00A5 
; 0000 00A6     lcd_backlight --;
; 0000 00A7     if ( lcd_backlight > 0 )
; 0000 00A8     {
; 0000 00A9         PORTB.3 = 1;
; 0000 00AA     }
; 0000 00AB     else
; 0000 00AC     {
; 0000 00AD         PORTB.3 = 0;
; 0000 00AE     }
; 0000 00AF     */
; 0000 00B0     PORTC.0 = output[0];
	LDS  R30,_output
	CPI  R30,0
	BRNE _0xA
	CBI  0x15,0
	RJMP _0xB
_0xA:
	SBI  0x15,0
_0xB:
; 0000 00B1     PORTC.1 = output[1];
	__GETB1MN _output,1
	CPI  R30,0
	BRNE _0xC
	CBI  0x15,1
	RJMP _0xD
_0xC:
	SBI  0x15,1
_0xD:
; 0000 00B2     PORTC.2 = output[2];
	__GETB1MN _output,2
	CPI  R30,0
	BRNE _0xE
	CBI  0x15,2
	RJMP _0xF
_0xE:
	SBI  0x15,2
_0xF:
; 0000 00B3     PORTC.3 = output[3];
	__GETB1MN _output,3
	CPI  R30,0
	BRNE _0x10
	CBI  0x15,3
	RJMP _0x11
_0x10:
	SBI  0x15,3
_0x11:
; 0000 00B4     PORTC.4 = output[4];
	__GETB1MN _output,4
	CPI  R30,0
	BRNE _0x12
	CBI  0x15,4
	RJMP _0x13
_0x12:
	SBI  0x15,4
_0x13:
; 0000 00B5     PORTC.5 = output[5];
	__GETB1MN _output,5
	CPI  R30,0
	BRNE _0x14
	CBI  0x15,5
	RJMP _0x15
_0x14:
	SBI  0x15,5
_0x15:
; 0000 00B6     PORTC.6 = output[6];
	__GETB1MN _output,6
	CPI  R30,0
	BRNE _0x16
	CBI  0x15,6
	RJMP _0x17
_0x16:
	SBI  0x15,6
_0x17:
; 0000 00B7     PORTC.7 = output[7];
	__GETB1MN _output,7
	CPI  R30,0
	BRNE _0x18
	CBI  0x15,7
	RJMP _0x19
_0x18:
	SBI  0x15,7
_0x19:
; 0000 00B8 }
	RET
;
;// Declare your global variables here
;void main(void)
; 0000 00BC {
_main:
; 0000 00BD     int i;
; 0000 00BE 	// Declare your local variables here
; 0000 00BF     state = 0;
;	i -> R16,R17
	CLR  R6
	CLR  R7
; 0000 00C0     lcd_backlight = 10;
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	MOVW R8,R30
; 0000 00C1     for ( i = 0 ; i < 12 ; i ++ )
	__GETWRN 16,17,0
_0x1B:
	__CPWRN 16,17,12
	BRGE _0x1C
; 0000 00C2     {
; 0000 00C3         output[i] = 0 ;
	LDI  R26,LOW(_output)
	LDI  R27,HIGH(_output)
	ADD  R26,R16
	ADC  R27,R17
	LDI  R30,LOW(0)
	ST   X,R30
; 0000 00C4     }
	__ADDWRN 16,17,1
	RJMP _0x1B
_0x1C:
; 0000 00C5 
; 0000 00C6 
; 0000 00C7 	// Input/Output Ports initialization
; 0000 00C8 	// Port A initialization
; 0000 00C9 	// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 00CA 	// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T
; 0000 00CB 	PORTA=0x00;
	LDI  R30,LOW(0)
	OUT  0x1B,R30
; 0000 00CC 	DDRA=0x00;
	OUT  0x1A,R30
; 0000 00CD 
; 0000 00CE 	// Port B initialization
; 0000 00CF 	// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=Out Func1=Out Func0=Out
; 0000 00D0 	// State7=0 State6=0 State5=0 State4=0 State3=0 State2=0 State1=0 State0=0
; 0000 00D1 	PORTB=0x00;
	OUT  0x18,R30
; 0000 00D2 	DDRB=0xFF;
	LDI  R30,LOW(255)
	OUT  0x17,R30
; 0000 00D3 
; 0000 00D4 	// Port C initialization
; 0000 00D5 	// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=Out Func1=Out Func0=Out
; 0000 00D6 	// State7=0 State6=0 State5=0 State4=0 State3=0 State2=0 State1=0 State0=0
; 0000 00D7 	PORTC=0x00;
	LDI  R30,LOW(0)
	OUT  0x15,R30
; 0000 00D8 	DDRC=0xFF;
	LDI  R30,LOW(255)
	OUT  0x14,R30
; 0000 00D9 
; 0000 00DA 	// Port D initialization
; 0000 00DB 	// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=In Func1=In Func0=In
; 0000 00DC 	// State7=0 State6=0 State5=0 State4=0 State3=0 State2=P State1=T State0=T
; 0000 00DD 	PORTD=0x04;
	LDI  R30,LOW(4)
	OUT  0x12,R30
; 0000 00DE 	DDRD=0xF8;
	LDI  R30,LOW(248)
	OUT  0x11,R30
; 0000 00DF 
; 0000 00E0 	// Timer/Counter 0 initialization
; 0000 00E1 	// Clock source: System Clock
; 0000 00E2 	// Clock value: 15.625 kHz
; 0000 00E3 	// Mode: Normal top=0xFF
; 0000 00E4 	// OC0 output: Disconnected
; 0000 00E5 	TCCR0=0x00;
	LDI  R30,LOW(0)
	OUT  0x33,R30
; 0000 00E6 	TCNT0=0x00;
	OUT  0x32,R30
; 0000 00E7 	OCR0=0x00;
	OUT  0x3C,R30
; 0000 00E8 
; 0000 00E9 	// Timer/Counter 1 initialization
; 0000 00EA 	// Clock source: System Clock
; 0000 00EB 	// Clock value: Timer1 Stopped
; 0000 00EC 	// Mode: Normal top=0xFFFF
; 0000 00ED 	// OC1A output: Discon.
; 0000 00EE 	// OC1B output: Discon.
; 0000 00EF 	// Noise Canceler: Off
; 0000 00F0 	// Input Capture on Falling Edge
; 0000 00F1 	// Timer1 Overflow Interrupt: Off
; 0000 00F2 	// Input Capture Interrupt: Off
; 0000 00F3 	// Compare A Match Interrupt: Off
; 0000 00F4 	// Compare B Match Interrupt: Off
; 0000 00F5 	TCCR1A=0x00;
	OUT  0x2F,R30
; 0000 00F6 	TCCR1B=0x00;
	OUT  0x2E,R30
; 0000 00F7 	TCNT1H=0x00;
	OUT  0x2D,R30
; 0000 00F8 	TCNT1L=0x00;
	OUT  0x2C,R30
; 0000 00F9 	ICR1H=0x00;
	OUT  0x27,R30
; 0000 00FA 	ICR1L=0x00;
	OUT  0x26,R30
; 0000 00FB 	OCR1AH=0x00;
	OUT  0x2B,R30
; 0000 00FC 	OCR1AL=0x00;
	OUT  0x2A,R30
; 0000 00FD 	OCR1BH=0x00;
	OUT  0x29,R30
; 0000 00FE 	OCR1BL=0x00;
	OUT  0x28,R30
; 0000 00FF 
; 0000 0100 	// Timer/Counter 2 initialization
; 0000 0101 	// Clock source: System Clock
; 0000 0102 	// Clock value: Timer2 Stopped
; 0000 0103 	// Mode: Normal top=0xFF
; 0000 0104 	// OC2 output: Disconnected
; 0000 0105 	ASSR=0x00;
	OUT  0x22,R30
; 0000 0106 	TCCR2=0x00;
	OUT  0x25,R30
; 0000 0107 	TCNT2=0x00;
	OUT  0x24,R30
; 0000 0108 	OCR2=0x00;
	OUT  0x23,R30
; 0000 0109 
; 0000 010A 	// External Interrupt(s) initialization
; 0000 010B 	// INT0: On
; 0000 010C 	// INT0 Mode: Low level
; 0000 010D 	// INT1: Off
; 0000 010E 	// INT2: Off
; 0000 010F 	GICR|=0x40;
	IN   R30,0x3B
	ORI  R30,0x40
	OUT  0x3B,R30
; 0000 0110 	MCUCR=0x00;
	LDI  R30,LOW(0)
	OUT  0x35,R30
; 0000 0111 	MCUCSR=0x00;
	OUT  0x34,R30
; 0000 0112 	GIFR=0x40;
	LDI  R30,LOW(64)
	OUT  0x3A,R30
; 0000 0113 
; 0000 0114 	// Timer(s)/Counter(s) Interrupt(s) initialization
; 0000 0115 	TIMSK=0x00;
	LDI  R30,LOW(0)
	OUT  0x39,R30
; 0000 0116 
; 0000 0117 	// USART initialization
; 0000 0118 	// Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 0119 	// USART Receiver: On
; 0000 011A 	// USART Transmitter: On
; 0000 011B 	// USART Mode: Asynchronous
; 0000 011C 	// USART Baud Rate: 9600
; 0000 011D 	UCSRA=0x00;
	OUT  0xB,R30
; 0000 011E 	UBRRH = (BAUD_PRESCALLER>>8);
	OUT  0x20,R30
; 0000 011F 	UBRRL = (BAUD_PRESCALLER);
	LDI  R30,LOW(103)
	OUT  0x9,R30
; 0000 0120 	UCSRB = (1<<RXEN)|(1<<TXEN);
	LDI  R30,LOW(24)
	OUT  0xA,R30
; 0000 0121 	UCSRC = (1<<UCSZ0)|(1<<UCSZ1)|(1<<URSEL);
	LDI  R30,LOW(134)
	OUT  0x20,R30
; 0000 0122 
; 0000 0123 	// Analog Comparator initialization
; 0000 0124 	// Analog Comparator: Off
; 0000 0125 	// Analog Comparator Input Capture by Timer/Counter 1: Off
; 0000 0126 	ACSR=0x80;
	LDI  R30,LOW(128)
	OUT  0x8,R30
; 0000 0127 	SFIOR=0x00;
	LDI  R30,LOW(0)
	OUT  0x30,R30
; 0000 0128 
; 0000 0129 	// ADC initialization
; 0000 012A 	// ADC Clock frequency: 750.000 kHz
; 0000 012B 	// ADC Voltage Reference: AREF pin
; 0000 012C 	// Only the 8 most significant bits of
; 0000 012D 	// the AD conversion result are used
; 0000 012E 	ADMUX=FIRST_ADC_INPUT | (ADC_VREF_TYPE & 0xff);
	LDI  R30,LOW(32)
	OUT  0x7,R30
; 0000 012F 	ADCSRA=0xCC;
	LDI  R30,LOW(204)
	OUT  0x6,R30
; 0000 0130 	ADCSR |= (1 << ADSC);
	SBI  0x6,6
; 0000 0131 
; 0000 0132 	// SPI initialization
; 0000 0133 	// SPI disabled
; 0000 0134 	SPCR=0x00;
	LDI  R30,LOW(0)
	OUT  0xD,R30
; 0000 0135 
; 0000 0136 	// TWI initialization
; 0000 0137 	// TWI disabled
; 0000 0138 	TWCR=0x00;
	OUT  0x36,R30
; 0000 0139 
; 0000 013A 	// Alphanumeric LCD initialization
; 0000 013B 	// Connections are specified in the
; 0000 013C 	// Project|Configure|C Compiler|Libraries|Alphanumeric LCD menu:
; 0000 013D 	// RS - PORTB Bit 0
; 0000 013E 	// RD - PORTB Bit 1
; 0000 013F 	// EN - PORTB Bit 2
; 0000 0140 	// D4 - PORTB Bit 4
; 0000 0141 	// D5 - PORTB Bit 5
; 0000 0142 	// D6 - PORTB Bit 6
; 0000 0143 	// D7 - PORTB Bit 7
; 0000 0144 	// Characters/line: 16
; 0000 0145 
; 0000 0146 	lcd_init(16);
	LDI  R26,LOW(16)
	CALL _lcd_init
; 0000 0147 	lcd_puts("Welcome.");
	__POINTW2MN _0x1D,0
	CALL SUBOPT_0x0
; 0000 0148     delay_ms(500);
; 0000 0149 
; 0000 014A 	#asm("sei")
	sei
; 0000 014B 	PORTD.7 = 1 ;
	SBI  0x12,7
; 0000 014C     lcd_clear();
	CALL _lcd_clear
; 0000 014D 	lcd_puts("Starting System.");
	__POINTW2MN _0x1D,9
	CALL SUBOPT_0x0
; 0000 014E     delay_ms(500);
; 0000 014F 	while(1)
_0x20:
; 0000 0150 	{
; 0000 0151         lcd_clear();
	CALL _lcd_clear
; 0000 0152     	lcd_puts("Receiving");
	__POINTW2MN _0x1D,26
	CALL _lcd_puts
; 0000 0153         buf = USART_receive();
	RCALL _USART_receive
	MOV  R5,R30
; 0000 0154         PORTD.7 = 1 - PORTD.7 ;
	LDI  R30,0
	SBIC 0x12,7
	LDI  R30,1
	LDI  R26,LOW(1)
	CALL __SWAPB12
	SUB  R30,R26
	BRNE _0x23
	CBI  0x12,7
	RJMP _0x24
_0x23:
	SBI  0x12,7
_0x24:
; 0000 0155 
; 0000 0156         // get sensor data 01234567
; 0000 0157         if ( buf >= '0' && buf <= '7' )
	LDI  R30,LOW(48)
	CP   R5,R30
	BRLO _0x26
	LDI  R30,LOW(55)
	CP   R30,R5
	BRSH _0x27
_0x26:
	RJMP _0x25
_0x27:
; 0000 0158         {
; 0000 0159             lcd_clear();
	CALL _lcd_clear
; 0000 015A         	lcd_puts("Send sensors data");
	__POINTW2MN _0x1D,36
	CALL _lcd_puts
; 0000 015B             #asm ("cli");
	cli
; 0000 015C             delay_ms(20);
	CALL SUBOPT_0x1
; 0000 015D             USART_send ( adc_data [ buf - '0' ] );
	SBIW R30,48
	SUBI R30,LOW(-_adc_data)
	SBCI R31,HIGH(-_adc_data)
	LD   R26,Z
	RCALL _USART_send
; 0000 015E             #asm ("sei");
	sei
; 0000 015F         }
; 0000 0160         // clear output
; 0000 0161         // abcdefgh
; 0000 0162         else if ( buf >= 'a' && buf <= 'h' )
	RJMP _0x28
_0x25:
	LDI  R30,LOW(97)
	CP   R5,R30
	BRLO _0x2A
	LDI  R30,LOW(104)
	CP   R30,R5
	BRSH _0x2B
_0x2A:
	RJMP _0x29
_0x2B:
; 0000 0163         {
; 0000 0164             lcd_clear();
	RCALL _lcd_clear
; 0000 0165         	lcd_puts("Clear output");
	__POINTW2MN _0x1D,54
	CALL SUBOPT_0x2
; 0000 0166             output [ buf - 'a' ] = 0;
	SUBI R30,LOW(97)
	SBCI R31,HIGH(97)
	SUBI R30,LOW(-_output)
	SBCI R31,HIGH(-_output)
	LDI  R26,LOW(0)
	STD  Z+0,R26
; 0000 0167             USART_send( '1' );
	LDI  R26,LOW(49)
	RJMP _0x39
; 0000 0168         }
; 0000 0169         // set output
; 0000 016A         else if ( buf >= 'A' && buf <= 'H' )
_0x29:
	LDI  R30,LOW(65)
	CP   R5,R30
	BRLO _0x2E
	LDI  R30,LOW(72)
	CP   R30,R5
	BRSH _0x2F
_0x2E:
	RJMP _0x2D
_0x2F:
; 0000 016B         {
; 0000 016C             lcd_clear();
	RCALL _lcd_clear
; 0000 016D         	lcd_puts("Set output");
	__POINTW2MN _0x1D,67
	CALL SUBOPT_0x2
; 0000 016E             output [ buf - 'A' ] = 1;
	SUBI R30,LOW(65)
	SBCI R31,HIGH(65)
	SUBI R30,LOW(-_output)
	SBCI R31,HIGH(-_output)
	LDI  R26,LOW(1)
	STD  Z+0,R26
; 0000 016F             USART_send( '0' );
	LDI  R26,LOW(48)
	RJMP _0x39
; 0000 0170         }
; 0000 0171         // pull output
; 0000 0172         else if ( buf >= '!' && buf <= ')' )
_0x2D:
	LDI  R30,LOW(33)
	CP   R5,R30
	BRLO _0x32
	LDI  R30,LOW(41)
	CP   R30,R5
	BRSH _0x33
_0x32:
	RJMP _0x31
_0x33:
; 0000 0173         {
; 0000 0174             lcd_clear();
	RCALL _lcd_clear
; 0000 0175         	lcd_puts("Pull output");
	__POINTW2MN _0x1D,78
	RCALL _lcd_puts
; 0000 0176             #asm ("cli");
	cli
; 0000 0177             delay_ms(20);
	CALL SUBOPT_0x1
; 0000 0178             USART_send ( (output[ buf - '!' ] == 0 ? 102 : 153 ) );
	SBIW R30,33
	SUBI R30,LOW(-_output)
	SBCI R31,HIGH(-_output)
	LD   R26,Z
	CPI  R26,LOW(0x0)
	BRNE _0x34
	LDI  R30,LOW(102)
	RJMP _0x35
_0x34:
	LDI  R30,LOW(153)
_0x35:
	MOV  R26,R30
	RCALL _USART_send
; 0000 0179             #asm ("sei");
	sei
; 0000 017A         }
; 0000 017B         // ?
; 0000 017C         else
	RJMP _0x37
_0x31:
; 0000 017D         {
; 0000 017E             lcd_clear();
	RCALL _lcd_clear
; 0000 017F         	lcd_puts("Invalid req");
	__POINTW2MN _0x1D,90
	RCALL _lcd_puts
; 0000 0180             USART_send ( '?' );
	LDI  R26,LOW(63)
_0x39:
	RCALL _USART_send
; 0000 0181         }
_0x37:
_0x28:
; 0000 0182         update();
	RCALL _update
; 0000 0183 	}
	RJMP _0x20
; 0000 0184 }
_0x38:
	RJMP _0x38

	.DSEG
_0x1D:
	.BYTE 0x66
;
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
__lcd_write_nibble_G100:
	ST   -Y,R26
	IN   R30,0x18
	ANDI R30,LOW(0xF)
	MOV  R26,R30
	LD   R30,Y
	ANDI R30,LOW(0xF0)
	OR   R30,R26
	OUT  0x18,R30
	__DELAY_USB 8
	SBI  0x18,2
	__DELAY_USB 20
	CBI  0x18,2
	__DELAY_USB 20
	RJMP _0x20C0001
__lcd_write_data:
	ST   -Y,R26
	LD   R26,Y
	RCALL __lcd_write_nibble_G100
    ld    r30,y
    swap  r30
    st    y,r30
	LD   R26,Y
	RCALL __lcd_write_nibble_G100
	__DELAY_USB 200
	RJMP _0x20C0001
_lcd_gotoxy:
	ST   -Y,R26
	LD   R30,Y
	LDI  R31,0
	SUBI R30,LOW(-__base_y_G100*2)
	SBCI R31,HIGH(-__base_y_G100*2)
	LPM  R30,Z
	LDD  R26,Y+1
	ADD  R26,R30
	RCALL __lcd_write_data
	LDD  R4,Y+1
	LDD  R11,Y+0
	ADIW R28,2
	RET
_lcd_clear:
	LDI  R26,LOW(2)
	CALL SUBOPT_0x3
	LDI  R26,LOW(12)
	RCALL __lcd_write_data
	LDI  R26,LOW(1)
	CALL SUBOPT_0x3
	LDI  R30,LOW(0)
	MOV  R11,R30
	MOV  R4,R30
	RET
_lcd_putchar:
	ST   -Y,R26
	LD   R26,Y
	CPI  R26,LOW(0xA)
	BREQ _0x2000004
	CP   R4,R10
	BRLO _0x2000003
_0x2000004:
	LDI  R30,LOW(0)
	ST   -Y,R30
	INC  R11
	MOV  R26,R11
	RCALL _lcd_gotoxy
	LD   R26,Y
	CPI  R26,LOW(0xA)
	BRNE _0x2000006
	RJMP _0x20C0001
_0x2000006:
_0x2000003:
	INC  R4
	SBI  0x18,0
	LD   R26,Y
	RCALL __lcd_write_data
	CBI  0x18,0
	RJMP _0x20C0001
_lcd_puts:
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
_0x2000007:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R30,X+
	STD  Y+1,R26
	STD  Y+1+1,R27
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x2000009
	MOV  R26,R17
	RCALL _lcd_putchar
	RJMP _0x2000007
_0x2000009:
	LDD  R17,Y+0
	ADIW R28,3
	RET
_lcd_init:
	ST   -Y,R26
	IN   R30,0x17
	ORI  R30,LOW(0xF0)
	OUT  0x17,R30
	SBI  0x17,2
	SBI  0x17,0
	SBI  0x17,1
	CBI  0x18,2
	CBI  0x18,0
	CBI  0x18,1
	LDD  R10,Y+0
	LDI  R26,LOW(20)
	LDI  R27,0
	CALL _delay_ms
	CALL SUBOPT_0x4
	CALL SUBOPT_0x4
	CALL SUBOPT_0x4
	LDI  R26,LOW(32)
	RCALL __lcd_write_nibble_G100
	__DELAY_USW 300
	LDI  R26,LOW(36)
	RCALL __lcd_write_data
	LDI  R26,LOW(9)
	RCALL __lcd_write_data
	LDI  R26,LOW(32)
	RCALL __lcd_write_data
	LDI  R26,LOW(12)
	RCALL __lcd_write_data
	LDI  R26,LOW(6)
	RCALL __lcd_write_data
	RCALL _lcd_clear
_0x20C0001:
	ADIW R28,1
	RET
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG

	.CSEG

	.DSEG

	.CSEG

	.CSEG

	.CSEG

	.CSEG

	.DSEG
_adc_data:
	.BYTE 0x8
_output:
	.BYTE 0xC
_input_index_S0000002000:
	.BYTE 0x1
__seed_G102:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	CALL _lcd_puts
	LDI  R26,LOW(500)
	LDI  R27,HIGH(500)
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x1:
	LDI  R26,LOW(20)
	LDI  R27,0
	CALL _delay_ms
	MOV  R30,R5
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2:
	CALL _lcd_puts
	MOV  R30,R5
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3:
	CALL __lcd_write_data
	LDI  R26,LOW(3)
	LDI  R27,0
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x4:
	LDI  R26,LOW(48)
	CALL __lcd_write_nibble_G100
	__DELAY_USW 300
	RET


	.CSEG
_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0xBB8
	wdr
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

;END OF CODE MARKER
__END_OF_CODE:
