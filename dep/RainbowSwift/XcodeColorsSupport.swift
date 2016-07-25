//
//  XcodeColorsSupport.swift
//  Rainbow
//
//  Created by Wei Wang on 15/12/23.
//
//  Copyright (c) 2015 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

protocol XcodeColorsConvertible {
    var xcodeColorsDescription: String { get }
    init?(xcodeColorsDescription string: String)
}

// MARK: - XcodeColorsConvertible
// Supports XcodeColors format of mode string.
extension Color: XcodeColorsConvertible {
    var xcodeColorsDescription: String {
        switch self {
        case .Black: return "fg0,0,0"
        case .Red: return "fg255,0,0"
        case .Green: return "fg0,204,0"
        case .Yellow: return "fg255,255,0"
        case .Blue: return "fg0,0,255"
        case .Magenta: return "fg255,0,255"
        case .Cyan: return "fg0,255,255"
        case .White: return "fg204,204,204"
        case .Default: return ""
        case .LightBlack: return "fg128,128,128"
        case .LightRed: return "fg255,102,102"
        case .LightGreen: return "fg102,255,102"
        case .LightYellow: return "fg255,255,102"
        case .LightBlue: return "fg102,102,255"
        case .LightMagenta: return "fg255,102,255"
        case .LightCyan: return "fg102,255,255"
        case .LightWhite: return "fg255,255,255"
        }
    }
    
    init?(xcodeColorsDescription string: String) {
        switch string {
        case Color.Black.xcodeColorsDescription: self = .Black
        case Color.Red.xcodeColorsDescription: self = .Red
        case Color.Green.xcodeColorsDescription: self = .Green
        case Color.Yellow.xcodeColorsDescription: self = .Yellow
        case Color.Blue.xcodeColorsDescription: self = .Blue
        case Color.Magenta.xcodeColorsDescription: self = .Magenta
        case Color.Cyan.xcodeColorsDescription: self = .Cyan
        case Color.White.xcodeColorsDescription: self = .White
        case Color.LightBlack.xcodeColorsDescription: self = .LightBlack
        case Color.LightRed.xcodeColorsDescription: self = .LightRed
        case Color.LightGreen.xcodeColorsDescription: self = .LightGreen
        case Color.LightYellow.xcodeColorsDescription: self = .LightYellow
        case Color.LightBlue.xcodeColorsDescription: self = .LightBlue
        case Color.LightMagenta.xcodeColorsDescription: self = .LightMagenta
        case Color.LightCyan.xcodeColorsDescription: self = .LightCyan
        case Color.LightWhite.xcodeColorsDescription: self = .LightWhite
        default: return nil
        }
    }
}

extension BackgroundColor: XcodeColorsConvertible {
    var xcodeColorsDescription: String {
        switch self {
        case .Black: return "bg0,0,0"
        case .Red: return "bg255,0,0"
        case .Green: return "bg0,204,0"
        case .Yellow: return "bg255,255,0"
        case .Blue: return "bg0,0,255"
        case .Magenta: return "bg255,0,255"
        case .Cyan: return "bg0,255,255"
        case .White: return "bg204,204,204"
        case .Default: return ""
        }
    }
    
    init?(xcodeColorsDescription string: String) {
        switch string {
        case BackgroundColor.Black.xcodeColorsDescription: self = .Black
        case BackgroundColor.Red.xcodeColorsDescription: self = .Red
        case BackgroundColor.Green.xcodeColorsDescription: self = .Green
        case BackgroundColor.Yellow.xcodeColorsDescription: self = .Yellow
        case BackgroundColor.Blue.xcodeColorsDescription: self = .Blue
        case BackgroundColor.Magenta.xcodeColorsDescription: self = .Magenta
        case BackgroundColor.Cyan.xcodeColorsDescription: self = .Cyan
        case BackgroundColor.White.xcodeColorsDescription: self = .White
        default: return nil
        }
    }
}