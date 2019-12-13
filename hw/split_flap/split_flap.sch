EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 6
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L power:+5V #PWR0115
U 1 1 5E1B006B
P 1700 6100
F 0 "#PWR0115" H 1700 5950 50  0001 C CNN
F 1 "+5V" H 1715 6273 50  0000 C CNN
F 2 "" H 1700 6100 50  0001 C CNN
F 3 "" H 1700 6100 50  0001 C CNN
	1    1700 6100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR04
U 1 1 5E1FC9E2
P 3750 5700
F 0 "#PWR04" H 3750 5450 50  0001 C CNN
F 1 "GND" H 3755 5527 50  0000 C CNN
F 2 "" H 3750 5700 50  0001 C CNN
F 3 "" H 3750 5700 50  0001 C CNN
	1    3750 5700
	1    0    0    -1  
$EndComp
Wire Wire Line
	3500 5650 3750 5650
Wire Wire Line
	3750 5650 3750 5700
$Comp
L power:+3.3V #PWR03
U 1 1 5E207E3D
P 1500 5150
F 0 "#PWR03" H 1500 5000 50  0001 C CNN
F 1 "+3.3V" H 1515 5323 50  0000 C CNN
F 2 "" H 1500 5150 50  0001 C CNN
F 3 "" H 1500 5150 50  0001 C CNN
	1    1500 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 5350 1500 5350
Wire Wire Line
	1500 5350 1500 5150
NoConn ~ 3500 5450
NoConn ~ 3500 5550
$Comp
L power:+3.3V #PWR010
U 1 1 5E247783
P 3750 6200
F 0 "#PWR010" H 3750 6050 50  0001 C CNN
F 1 "+3.3V" H 3765 6373 50  0000 C CNN
F 2 "" H 3750 6200 50  0001 C CNN
F 3 "" H 3750 6200 50  0001 C CNN
	1    3750 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3500 5750 3500 6200
Wire Wire Line
	3500 6200 3750 6200
$Comp
L power:GND #PWR09
U 1 1 5E250C3D
P 1650 5100
F 0 "#PWR09" H 1650 4850 50  0001 C CNN
F 1 "GND" H 1655 4927 50  0000 C CNN
F 2 "" H 1650 5100 50  0001 C CNN
F 3 "" H 1650 5100 50  0001 C CNN
	1    1650 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 5250 1750 5250
Wire Wire Line
	1750 5250 1750 5100
Wire Wire Line
	1750 5100 1650 5100
NoConn ~ 1900 4350
NoConn ~ 1900 4450
NoConn ~ 1900 4550
NoConn ~ 1900 4650
NoConn ~ 1900 4750
NoConn ~ 1900 4850
NoConn ~ 1900 4950
NoConn ~ 1900 5050
NoConn ~ 1900 5150
NoConn ~ 1900 5450
$Comp
L ESP:NodeMCU_1.0_(ESP-12E) U2
U 1 1 5DE620B2
P 2700 5050
F 0 "U2" H 2700 6137 60  0000 C CNN
F 1 "NodeMCU_1.0_(ESP-12E)" H 2700 6031 60  0000 C CNN
F 2 "ESP:ESP12F-Devkit-V3" H 2100 4200 60  0001 C CNN
F 3 "" H 2100 4200 60  0000 C CNN
	1    2700 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 5750 1900 6100
Wire Wire Line
	1900 6100 1700 6100
$Comp
L power:GND #PWR021
U 1 1 5E31CD13
P 4200 4950
F 0 "#PWR021" H 4200 4700 50  0001 C CNN
F 1 "GND" H 4205 4777 50  0000 C CNN
F 2 "" H 4200 4950 50  0001 C CNN
F 3 "" H 4200 4950 50  0001 C CNN
	1    4200 4950
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR020
U 1 1 5E31D0B0
P 4200 4850
F 0 "#PWR020" H 4200 4700 50  0001 C CNN
F 1 "+3.3V" H 4215 5023 50  0000 C CNN
F 2 "" H 4200 4850 50  0001 C CNN
F 3 "" H 4200 4850 50  0001 C CNN
	1    4200 4850
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_01x02 J19
U 1 1 5E33CF31
P 10300 5600
F 0 "J19" H 10380 5592 50  0000 L CNN
F 1 "POWER" H 10380 5501 50  0000 L CNN
F 2 "Connector_JST:JST_XH_B2B-XH-A_1x02_P2.50mm_Vertical" H 10300 5600 50  0001 C CNN
F 3 "~" H 10300 5600 50  0001 C CNN
	1    10300 5600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR023
U 1 1 5E33E103
P 9750 5750
F 0 "#PWR023" H 9750 5500 50  0001 C CNN
F 1 "GND" H 9755 5577 50  0000 C CNN
F 2 "" H 9750 5750 50  0001 C CNN
F 3 "" H 9750 5750 50  0001 C CNN
	1    9750 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	10100 5600 9750 5600
Wire Wire Line
	9750 5600 9750 5550
Wire Wire Line
	9750 5750 9750 5700
Wire Wire Line
	9750 5700 10100 5700
$Comp
L power:GND #PWR0144
U 1 1 5DE73E08
P 8750 1950
F 0 "#PWR0144" H 8750 1700 50  0001 C CNN
F 1 "GND" H 8755 1777 50  0000 C CNN
F 2 "" H 8750 1950 50  0001 C CNN
F 3 "" H 8750 1950 50  0001 C CNN
	1    8750 1950
	1    0    0    -1  
$EndComp
Text Label 9850 2350 0    50   ~ 0
SCL
Text Label 9850 2450 0    50   ~ 0
SDA
Wire Wire Line
	9150 2650 8950 2650
$Sheet
S 4800 1600 550  750 
U 5DED9C19
F0 "sheet5DED9C19" 50
F1 "motor2x.sch" 50
F2 "DO" I R 5350 1800 50 
F3 "LATCH" I L 4800 2100 50 
F4 "DI" I L 4800 1800 50 
F5 "CLK" I L 4800 1950 50 
$EndSheet
NoConn ~ 1900 5550
$Comp
L power:+5V #PWR022
U 1 1 5E33DBA2
P 9750 5550
F 0 "#PWR022" H 9750 5400 50  0001 C CNN
F 1 "+5V" H 9765 5723 50  0000 C CNN
F 2 "" H 9750 5550 50  0001 C CNN
F 3 "" H 9750 5550 50  0001 C CNN
	1    9750 5550
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0120
U 1 1 5DFF89C6
P 8550 2350
F 0 "#PWR0120" H 8550 2200 50  0001 C CNN
F 1 "+5V" H 8565 2523 50  0000 C CNN
F 2 "" H 8550 2350 50  0001 C CNN
F 3 "" H 8550 2350 50  0001 C CNN
	1    8550 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	9150 2250 9150 1950
Wire Wire Line
	9150 1950 8750 1950
Wire Wire Line
	3500 4850 4200 4850
$Comp
L Connector_Generic:Conn_02x05_Odd_Even J17
U 1 1 5DE902A4
P 9350 2450
F 0 "J17" H 9400 2867 50  0000 C CNN
F 1 "EXPANDER_PORT" H 9400 2776 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x05_P2.54mm_Vertical" H 9350 2450 50  0001 C CNN
F 3 "~" H 9350 2450 50  0001 C CNN
	1    9350 2450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0162
U 1 1 5DF07B91
P 1500 5700
F 0 "#PWR0162" H 1500 5450 50  0001 C CNN
F 1 "GND" H 1505 5527 50  0000 C CNN
F 2 "" H 1500 5700 50  0001 C CNN
F 3 "" H 1500 5700 50  0001 C CNN
	1    1500 5700
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 5650 1500 5650
Wire Wire Line
	1500 5650 1500 5700
NoConn ~ 3500 5150
NoConn ~ 3500 4350
Wire Wire Line
	3500 4950 4200 4950
Text Label 3650 5050 0    50   ~ 0
SPI_3.3_CLK
Text Label 3650 5350 0    50   ~ 0
SPI_3.3_DO
Text Label 3650 5250 0    50   ~ 0
SPI_3.3_CS
Wire Wire Line
	3500 5050 3650 5050
Wire Wire Line
	3500 5250 3650 5250
Wire Wire Line
	3650 5350 3500 5350
NoConn ~ 3500 4750
Text Label 3750 4650 0    50   ~ 0
INT
Text Label 3750 4550 0    50   ~ 0
SDA
Text Label 3750 4450 0    50   ~ 0
SCL
Wire Wire Line
	3500 4450 3750 4450
Wire Wire Line
	3750 4550 3500 4550
Wire Wire Line
	3500 4650 3750 4650
Text Label 6350 4800 2    50   ~ 0
SPI_CLK
Wire Wire Line
	1550 1800 1200 1800
Text Label 7300 5200 0    50   ~ 0
SPI_DO
Wire Wire Line
	1200 1950 1550 1950
Text Label 6350 5200 2    50   ~ 0
SPI_CS
Wire Wire Line
	1200 2100 1550 2100
$Sheet
S 9550 3900 550  550 
U 5E065378
F0 "input_expander_1" 50
F1 "input_expander.sch" 50
F2 "SCL" I L 9550 4050 50 
F3 "SDA" I L 9550 4200 50 
F4 "INT" I L 9550 4350 50 
F5 "A0" I R 10100 4050 50 
F6 "A1" I R 10100 4200 50 
F7 "A2" I R 10100 4350 50 
$EndSheet
Text Label 2850 1950 2    50   ~ 0
SPI_CLK
Wire Wire Line
	2850 1950 3200 1950
Text Label 2850 2100 2    50   ~ 0
SPI_CS
Wire Wire Line
	2850 2100 3200 2100
$Sheet
S 6400 1600 550  750 
U 5E0964A4
F0 "sheet5E0964A4" 50
F1 "motor2x.sch" 50
F2 "DO" I R 6950 1800 50 
F3 "LATCH" I L 6400 2100 50 
F4 "DI" I L 6400 1800 50 
F5 "CLK" I L 6400 1950 50 
$EndSheet
Text Label 4450 1950 2    50   ~ 0
SPI_CLK
Wire Wire Line
	4450 1950 4800 1950
Text Label 4450 2100 2    50   ~ 0
SPI_CS
Wire Wire Line
	4450 2100 4800 2100
Text Label 6050 1950 2    50   ~ 0
SPI_CLK
Wire Wire Line
	6050 1950 6400 1950
Text Label 6050 2100 2    50   ~ 0
SPI_CS
Wire Wire Line
	6050 2100 6400 2100
Text Label 9400 4350 2    50   ~ 0
INT
Text Label 9400 4200 2    50   ~ 0
SDA
Text Label 9400 4050 2    50   ~ 0
SCL
Wire Wire Line
	9550 4200 9400 4200
Wire Wire Line
	9400 4050 9550 4050
Wire Wire Line
	9400 4350 9550 4350
Text Label 9650 2250 0    50   ~ 0
INT
Text Label 7250 1800 0    50   ~ 0
DI_EXP
Text Label 8950 2650 2    50   ~ 0
DI_EXP
Text Label 9850 2650 0    50   ~ 0
SPI_CLK
Text Label 9850 2550 0    50   ~ 0
SPI_CS
Wire Wire Line
	9650 2350 9850 2350
Wire Wire Line
	9650 2450 9850 2450
Wire Wire Line
	9650 2550 9850 2550
$Comp
L 74HCT125:74HCT125 U1
U 1 1 5E118492
P 6850 4900
F 0 "U1" H 6825 5581 50  0000 C CNN
F 1 "74HCT125" H 6825 5490 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 6850 4900 50  0001 C CNN
F 3 "" H 6850 4900 50  0001 C CNN
	1    6850 4900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR05
U 1 1 5E139BAA
P 6850 5550
F 0 "#PWR05" H 6850 5300 50  0001 C CNN
F 1 "GND" H 6855 5377 50  0000 C CNN
F 2 "" H 6850 5550 50  0001 C CNN
F 3 "" H 6850 5550 50  0001 C CNN
	1    6850 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 4700 7800 4700
Wire Wire Line
	7800 4700 7800 5000
Wire Wire Line
	7300 5000 7800 5000
Text Label 7300 5100 0    50   ~ 0
SPI_3.3_DO
Text Label 6350 4700 2    50   ~ 0
SPI_3.3_CLK
Text Label 6350 5100 2    50   ~ 0
SPI_3.3_CS
$Sheet
S 1550 1600 550  750 
U 5E092C79
F0 "sheet5E092C79" 50
F1 "motor2x.sch" 50
F2 "DO" I R 2100 1800 50 
F3 "LATCH" I L 1550 2100 50 
F4 "DI" I L 1550 1800 50 
F5 "CLK" I L 1550 1950 50 
$EndSheet
$Sheet
S 3200 1600 550  750 
U 5E0B21A0
F0 "sheet5E0B21A0" 50
F1 "motor2x.sch" 50
F2 "DO" I R 3750 1800 50 
F3 "LATCH" I L 3200 2100 50 
F4 "DI" I L 3200 1800 50 
F5 "CLK" I L 3200 1950 50 
$EndSheet
Wire Wire Line
	7250 1800 6950 1800
Wire Wire Line
	5350 1800 6400 1800
Wire Wire Line
	2100 1800 3200 1800
Wire Wire Line
	3750 1800 4800 1800
Wire Wire Line
	6850 5400 6850 5550
Wire Wire Line
	7800 5000 8000 5000
Connection ~ 7800 5000
Wire Wire Line
	5750 4600 5750 5000
Wire Wire Line
	5750 5000 6350 5000
Wire Wire Line
	5750 4600 6350 4600
Wire Wire Line
	5750 5000 5600 5000
Connection ~ 5750 5000
$Comp
L power:GND #PWR01
U 1 1 5E177E47
P 5600 5000
F 0 "#PWR01" H 5600 4750 50  0001 C CNN
F 1 "GND" H 5605 4827 50  0000 C CNN
F 2 "" H 5600 5000 50  0001 C CNN
F 3 "" H 5600 5000 50  0001 C CNN
	1    5600 5000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR06
U 1 1 5E17812F
P 8000 5000
F 0 "#PWR06" H 8000 4750 50  0001 C CNN
F 1 "GND" H 8005 4827 50  0000 C CNN
F 2 "" H 8000 5000 50  0001 C CNN
F 3 "" H 8000 5000 50  0001 C CNN
	1    8000 5000
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR02
U 1 1 5E1793E3
P 6850 4100
F 0 "#PWR02" H 6850 3950 50  0001 C CNN
F 1 "+5V" H 6865 4273 50  0000 C CNN
F 2 "" H 6850 4100 50  0001 C CNN
F 3 "" H 6850 4100 50  0001 C CNN
	1    6850 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	6850 4100 6850 4400
Wire Wire Line
	7300 4600 7800 4600
Wire Wire Line
	7800 4600 7800 4700
Connection ~ 7800 4700
NoConn ~ 7300 4800
Text Label 1200 1950 2    50   ~ 0
SPI_CLK
Text Label 1200 2100 2    50   ~ 0
SPI_CS
Text Label 1200 1800 2    50   ~ 0
SPI_DO
$Comp
L power:GND #PWR014
U 1 1 5DF4FEB1
P 10400 4350
F 0 "#PWR014" H 10400 4100 50  0001 C CNN
F 1 "GND" H 10405 4177 50  0000 C CNN
F 2 "" H 10400 4350 50  0001 C CNN
F 3 "" H 10400 4350 50  0001 C CNN
	1    10400 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	10100 4050 10400 4050
Wire Wire Line
	10400 4050 10400 4200
Wire Wire Line
	10100 4200 10400 4200
Connection ~ 10400 4200
Wire Wire Line
	10400 4200 10400 4350
Wire Wire Line
	10100 4350 10400 4350
Connection ~ 10400 4350
Wire Wire Line
	9650 2650 9850 2650
Wire Wire Line
	9150 2550 8550 2550
Wire Wire Line
	8550 2550 8550 2350
Wire Wire Line
	9150 2450 9150 2350
Wire Wire Line
	9150 2350 9150 2250
Connection ~ 9150 2350
Connection ~ 9150 2250
$EndSCHEMATC
