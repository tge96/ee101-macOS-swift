
// must have swift version 5 installed on your mac
// $ sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
// $ git clone https://github.com/tge96/ee101-macOS-swift.git
// $ cd ee101-macOS-swift
// $ swift build
// $ ./.build/debug/test_ee101_1wire /dev/cu.usbserialXYZ<replace XYZ with the rest of your USB serial adapter name here>

import Foundation
import SwiftSerial

let testBinaryArray : [UInt8] = [0x55, 0xFF, 0x55, 0xFF, 0x55]

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    print("Need serial port name, e.g. /dev/cu.usbserialXYZ as the first argument.")
    exit(1)
}

let portName = arguments[1]
let serialPort: SerialPort = SerialPort(path: portName)

func EE101Text(channel, text) {
    let EE101_SYNC = 0x50
    let EE101_TEXT_TYPE = 0x00
    try serialPort.writeData(bytes([(int(channel) & 0x07) | EE101_SYNC | EE101_TEXT_TYPE]))
    try serialPort.writeData(text.encode())
    try serialPort.writeData(bytes([0]))
}

func EE101Value(channel, value) {
    let EE101_SYNC = 0x50
    let EE101_VALUE_TYPE = 0x80
    try serialPort.writeData(bytes([(int(channel) & 0x07) | EE101_SYNC | EE101_VALUE_TYPE]))
    try serialPort.writeData(bytes([(int(value >> 24))]))
    try serialPort.writeData(bytes([(int(value >> 16))]))
    try serialPort.writeData(bytes([(int(value >> 8))]))
    try serialPort.writeData(bytes([(int(value) & 0xFF)]))
}

do {

    try serialPort.openPort()
    print("Serial port \(portName) opened successfully.")
    defer {
        serialPort.closePort()
        print("Port Closed")
    }

    serialPort.setSettings(receiveRate: .baud9600,
                           transmitRate: .baud9600,
                           minimumBytesToRead: 1)

    print("Press CTL+C to exit program")
    
    print("Sending: ", terminator:"")
    print(testBinaryArray.map { String($0, radix: 16, uppercase: false) })

    let dataToSend: Data = Data(_: testBinaryArray)

    let bytesWritten = try serialPort.writeData(dataToSend)

    print("Successfully wrote \(bytesWritten) bytes")

    let i = 0

    do {
        EE101Text(0,"Hello")
        EE101Text(1,"Tim")
        EE101Text(2,"this")
        EE101Text(3,"is")
        EE101Text(4,"your")
        EE101Text(5,"ee101")
        EE101Text(6,"ported to")
        EE101Text(7,"Swift v5 on macOS")

        i += 1

        EE101Value(0, i)
        EE101Value(1, i)
        EE101Value(2, i)
        EE101Value(3, i)
        EE101Value(4, i)
        EE101Value(5, i)
        EE101Value(6, i)
        EE101Value(7, i)

    } while(i < 100)

    print("End of example");

} catch PortError.failedToOpen {
    print("Serial port \(portName) failed to open. You might need root permissions.")
} catch {
    print("Error: \(error)")
}
