import Foundation

/// Virtual key codes from <Carbon/HIToolbox/Events.h>
public enum VirtualKeyCode: UInt16, Sendable, Codable {
    case a = 0x00
    case s = 0x01
    case d = 0x02
    case f = 0x03
    case h = 0x04
    case g = 0x05
    case z = 0x06
    case x = 0x07
    case c = 0x08
    case v = 0x09
    case b = 0x0B
    case q = 0x0C
    case w = 0x0D
    case e = 0x0E
    case r = 0x0F
    case y = 0x10
    case t = 0x11
    
    // Numbers
    case one = 0x12
    case two = 0x13
    case three = 0x14
    case four = 0x15
    case six = 0x16
    case five = 0x17
    case nine = 0x19
    case seven = 0x1A
    case eight = 0x1C
    case zero = 0x1D
    case minus = 0x1B
    case equals = 0x18
    
    case o = 0x1F
    case u = 0x20
    case i = 0x22
    case p = 0x23
    case l = 0x25
    case j = 0x26
    case k = 0x28
    case m = 0x2E
    
    // Punctuation
    case comma = 0x2B
    case dot = 0x2F
    case slash = 0x2C
    case semicolon = 0x29
    case quote = 0x27
    case bracketLeft = 0x21
    case bracketRight = 0x1E
    case backslash = 0x2A
    
    // Control
    case space = 0x31
    case escape = 0x35
    case delete = 0x33
    case tab = 0x30
    case `return` = 0x24
    case leftArrow = 0x7B
    case rightArrow = 0x7C
    case downArrow = 0x7D
    case upArrow = 0x7E
}
