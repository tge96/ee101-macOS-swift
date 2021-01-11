
// must have swift version 5 installed on your mac
// $ sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
// $ git clone https://github.com/tge96/ee101-macOS-swift.git
// $ cd ee101-macOS-swift
// $ swift build
// $ ./.build/debug/test_ee101_1wire /dev/cu.usbserialXYZ
//             ...<replace XYZ with the rest of your USB serial adapter name here>

import Foundation
import SwiftSerial

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    print("Need serial port name, e.g. /dev/cu.usbserialXYZ as the first argument.")
    exit(1)
}

let portName = arguments[1]
let serialPort: SerialPort = SerialPort(path: portName)

func EE101Text(_ channel: UInt8, text: String) {
    let EE101_SYNC: UInt8 = 0x50
    let EE101_TEXT_TYPE: UInt8 = 0x00
    let cht : [UInt8] = [(channel & 0x07) | EE101_SYNC | EE101_TEXT_TYPE]
    let eop : [UInt8] = [0x00]

    do {
        let myHeaderToSend: Data = Data(_: cht)
        var _ = try serialPort.writeData(myHeaderToSend)
        var _ = try serialPort.writeString(text)
        let myEOPToSend: Data = Data(_: eop)
        let _ = try serialPort.writeData(myEOPToSend)
    } catch {
        print("Error: \(error)")
    }
}

func EE101Value(_ channel: UInt8, value: Int32) {
    let EE101_SYNC: UInt8 = 0x50
    let EE101_VALUE_TYPE: UInt8 = 0x80
    let chv : [UInt8] = [(channel & 0x07) | EE101_SYNC | EE101_VALUE_TYPE]
    let val : [UInt8] = [UInt8(value >> 24), UInt8(value >> 16), UInt8(value >> 8), UInt8(value & 0xFF)]

    do {
        let myHeaderToSend1: Data = Data(_: chv)
        var _ = try serialPort.writeData(myHeaderToSend1)
        let myValToSend: Data = Data(_: val)
        let _ = try serialPort.writeData(myValToSend)
    } catch {
        print("Error: \(error)")
    }

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

    var i: Int32 = 10
    var bo: Bool = true
    
    repeat {

        EE101Text(0, text: "Hello")
        EE101Text(1, text: "Tim")
        EE101Text(2, text: "this")
        EE101Text(3, text: "is")
        EE101Text(4, text: "your")
        EE101Text(5, text: "ee101")
        EE101Text(6, text: "ported to")
        EE101Text(7, text: "Swift v5 on macOS")

        EE101Value(0, value: i)
        EE101Value(1, value: i)
        EE101Value(2, value: i)
        EE101Value(3, value: i)
        EE101Value(4, value: i)
        EE101Value(5, value: i)
        EE101Value(6, value: i)
        EE101Value(7, value: i)

        i -= 1
        if(i < 1) {
            bo = false
        }

    } while bo

} catch PortError.failedToOpen {
    print("Serial port \(portName) failed to open.")
} catch {
    print("Error: \(error)")
}
