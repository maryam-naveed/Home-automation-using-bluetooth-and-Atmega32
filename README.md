# Home Automation Using Bluetooth and ATmega32

## Overview

This project involves creating a home automation system using an ATmega32 microcontroller and Bluetooth communication. The system is designed to control a fan and an LED light based on temperature readings and Bluetooth commands. The project includes interfacing with an LCD display, reading temperature from an ADC, and using PWM to control the fan speed.

## Features

- **LCD Display**: Provides real-time temperature readings and status messages.
- **Temperature Sensor**: Reads temperature using the ADC of ATmega32.
- **Fan Control**: Adjusts fan speed based on temperature.
- **LED Control**: Turns the LED on or off based on temperature thresholds or Bluetooth commands.
- **Bluetooth Communication**: Allows remote control of the fan and LED using Bluetooth.

## Hardware Requirements

- ATmega32 Microcontroller
- LCD Display
- Temperature Sensor (e.g., LM35)
- Bluetooth Module (e.g., HC-05)
- Fan (DC Motor)
- LED
- Resistors, Capacitors, and other passive components
- Breadboard and Jumper Wires

## Software Requirements

- AVR Studio or any other AVR development environment
- AVR Toolchain for assembly programming
- USBasp or any other AVR programmer

## Connections

### LCD Display
- Data Pins: Connect PORTC to the data pins of the LCD.
- Control Pins: Connect PORTD pins to RS, RW, and EN of the LCD.

### Temperature Sensor
- Connect the sensor output to an ADC pin (e.g., ADC0).

### Fan
- Connect the fan to a PWM output pin (e.g., PB3).

### LED
- Connect the LED to a GPIO pin (e.g., PB0).

### Bluetooth Module
- Connect RX and TX pins of the Bluetooth module to TX and RX pins of the ATmega32, respectively.

## Functionality

1. **Initialization**:
   - Set up the stack, configure the LCD, and initialize ports and peripherals.
   - Configure the ADC for temperature sensing.
   - Configure Timer0 for PWM to control the fan speed.
   - Set up UART for Bluetooth communication.

2. **Temperature Reading and Display**:
   - Continuously read the temperature from the ADC.
   - Convert the ADC value to a temperature reading and display it on the LCD.

3. **Fan Control**:
   - Adjust the fan speed based on the temperature reading.
   - Turn the fan on or off based on predefined temperature thresholds.

4. **LED Control**:
   - Turn the LED on or off based on temperature readings.
   - Control the LED using Bluetooth commands.

5. **Bluetooth Communication**:
   - Receive commands via Bluetooth to control the fan and LED.
   - Update the system status based on received commands.

## Usage

1. **Power Up**:
   - Connect the power supply to the system.
   - Ensure the Bluetooth module is paired with the controlling device (e.g., smartphone or computer).

2. **Monitor and Control**:
   - Monitor the temperature and system status on the LCD.
   - Use the controlling device to send commands via Bluetooth to control the fan and LED.

## Notes

- Ensure that the Bluetooth module baud rate matches the configured baud rate in the code (9600 in this case).
- Adjust the temperature thresholds and PWM settings as necessary for your specific application.
- Properly debounce any mechanical switches if used for manual control.

## Troubleshooting

- **No Display on LCD**: Check connections and initialization code for the LCD.
- **Incorrect Temperature Reading**: Verify the ADC configuration and the connections of the temperature sensor.
- **Fan or LED Not Responding**: Ensure correct port configurations and verify the PWM output for the fan.
- **Bluetooth Communication Issues**: Check the UART configuration and ensure the Bluetooth module is properly paired.

