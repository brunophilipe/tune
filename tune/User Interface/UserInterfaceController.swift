//
//  UserInterfaceController.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Darwin

typealias UIKeyCode = Int32

/// This class controls the application through key events, based on the UIState object chain.
class UserInterfaceController
{
	private let screen: OpaquePointer
	private let rootState: UIState

	private var textInputBuffer: String? = nil

	private var invalidTextInputCharacters: CharacterSet = CharacterSet.controlCharacters.union(.illegalCharacters).union(.newlines)
	private var invalidKeyCodes = KEY_MIN ..< KEY_MAX

	fileprivate var currentState: UIState? = nil
	{
		didSet
		{
			if let state = currentState
			{
				delegate?.userInterfaceController(self, didChangeToState: state)
			}
		}
	}

	var delegate: UserInterfaceControllerDelegate? = nil

	init(screen: OpaquePointer, rootState: UIState)
	{
		self.screen = screen
		self.rootState = rootState
		self.currentState = rootState
	}

	func runEventLoop()
	{
		var stop = false

		repeat
		{
			let keyCode = getch()

			if keyCode < 0
			{
				// We are using delay mode, but let's add this check just in case.
				continue
			}
			else if keyCode == KEY_RESIZE, let delegate = self.delegate
			{
				delegate.userInterfaceControllerReceivedResizeEvent(self)
			}
			else if let currentState = self.currentState
			{
				// If the current state has a "navigatable" delegate, and we receive a navigation `keyCode`, we pass that to the delegate.
				if let navigatableStateDelegate = currentState.delegate as? UINavigatableStateDelegate, keyCode.isNavigationKeyCode
				{
					navigatableStateDelegate.state(currentState, receivedNavigationKeyCode: keyCode)
				}
				else if let newState = currentState.substate(forKeyCode: keyCode)
				{
					switch newState
					{
					case let controlState as UIControlState:
						controlState.runBlock()

					case UIState.parentState:
						self.currentState = currentState.parentState

					case UIState.quitState:
						stop = true
						
					default:
						self.currentState = newState
					}
				}
				else if let textInputState = currentState as? UITextInputState
				{
					var textBuffer = self.textInputBuffer ?? ""

					if [KEY_DELETE, KEY_BACKSPACE].contains(keyCode)
					{
						if textBuffer.width > 0
						{
							textBuffer = textBuffer.substring(to: textBuffer.index(before: textBuffer.endIndex))
						}
					}
					else if keyCode == KEY_CLEAR_LINE
					{
						textBuffer = ""
					}
					else if keyCode == KEY_CLEAR_WORD
					{
						if let range = textBuffer.rangeOfCharacter(from: .whitespaces, options: .backwards, range: textBuffer.fullRange)
						{
							textBuffer = textBuffer.substring(to: range.lowerBound)
						}
						else
						{
							textBuffer = ""
						}
					}
					else if let char = UnicodeScalar(Int(keyCode)),
						!invalidTextInputCharacters.contains(char),
						!invalidKeyCodes.contains(keyCode)
					{
						textBuffer.append(String(char))
					}

					textInputState.runBlock(withInputText: textBuffer)

					self.textInputBuffer = textBuffer
				}
				else
				{
					#if DEBUG
						move(0, 0)
						addstr("   ")
						move(0, 0)
						addstr("\(keyCode)")
					#endif

					// If we reached here, it means this `keyCode` is not meaningful.
					// This line is here just to make the code flow more obvious in the future. 
					continue
				}
			}
			else
			{
				// Inconsistency!!
				stop = true
			}
		}
		while !stop
	}
}

extension UserInterfaceController
{
	var state: UIState?
	{
		return self.currentState
	}
}

protocol UserInterfaceControllerDelegate
{
	func userInterfaceControllerReceivedResizeEvent(_ controller: UserInterfaceController)
	func userInterfaceController(_ controller: UserInterfaceController, didChangeToState state: UIState)
}

// These are just some control characters that are supported

let KEY_ESCAPE = UIKeyCode(27)
let KEY_DELETE = UIKeyCode(127)
let KEY_CLEAR_LINE = UIKeyCode(21)
let KEY_CLEAR_WORD = UIKeyCode(23)

// These definitions are here because converting a character to its ASCII code is expensive, so we only do it once.

let KEY_SPACE = " ".codeUnit!
let KEY_TAB = "\t".codeUnit!
let KEY_PERIOD = ".".codeUnit!

let KEY_0 = "0".codeUnit!
let KEY_1 = "1".codeUnit!
let KEY_2 = "2".codeUnit!
let KEY_3 = "3".codeUnit!
let KEY_4 = "4".codeUnit!
let KEY_5 = "5".codeUnit!
let KEY_6 = "6".codeUnit!
let KEY_7 = "7".codeUnit!
let KEY_8 = "8".codeUnit!
let KEY_9 = "9".codeUnit!

let KEY_A_LOWER = "a".codeUnit!
let KEY_B_LOWER = "b".codeUnit!
let KEY_C_LOWER = "c".codeUnit!
let KEY_D_LOWER = "d".codeUnit!
let KEY_E_LOWER = "e".codeUnit!
let KEY_F_LOWER = "f".codeUnit!
let KEY_G_LOWER = "g".codeUnit!
let KEY_H_LOWER = "h".codeUnit!
let KEY_I_LOWER = "i".codeUnit!
let KEY_J_LOWER = "j".codeUnit!
let KEY_K_LOWER = "k".codeUnit!
let KEY_L_LOWER = "l".codeUnit!
let KEY_M_LOWER = "m".codeUnit!
let KEY_N_LOWER = "n".codeUnit!
let KEY_O_LOWER = "o".codeUnit!
let KEY_P_LOWER = "p".codeUnit!
let KEY_Q_LOWER = "q".codeUnit!
let KEY_R_LOWER = "r".codeUnit!
let KEY_S_LOWER = "s".codeUnit!
let KEY_T_LOWER = "t".codeUnit!
let KEY_U_LOWER = "u".codeUnit!
let KEY_V_LOWER = "v".codeUnit!
let KEY_W_LOWER = "w".codeUnit!
let KEY_X_LOWER = "x".codeUnit!
let KEY_Y_LOWER = "y".codeUnit!
let KEY_Z_LOWER = "z".codeUnit!

let KEY_A_UPPER = "A".codeUnit!
let KEY_B_UPPER = "B".codeUnit!
let KEY_C_UPPER = "C".codeUnit!
let KEY_D_UPPER = "D".codeUnit!
let KEY_E_UPPER = "E".codeUnit!
let KEY_F_UPPER = "F".codeUnit!
let KEY_G_UPPER = "G".codeUnit!
let KEY_H_UPPER = "H".codeUnit!
let KEY_I_UPPER = "I".codeUnit!
let KEY_J_UPPER = "J".codeUnit!
let KEY_K_UPPER = "K".codeUnit!
let KEY_L_UPPER = "L".codeUnit!
let KEY_M_UPPER = "M".codeUnit!
let KEY_N_UPPER = "N".codeUnit!
let KEY_O_UPPER = "O".codeUnit!
let KEY_P_UPPER = "P".codeUnit!
let KEY_Q_UPPER = "Q".codeUnit!
let KEY_R_UPPER = "R".codeUnit!
let KEY_S_UPPER = "S".codeUnit!
let KEY_T_UPPER = "T".codeUnit!
let KEY_U_UPPER = "U".codeUnit!
let KEY_V_UPPER = "V".codeUnit!
let KEY_W_UPPER = "W".codeUnit!
let KEY_X_UPPER = "X".codeUnit!
let KEY_Y_UPPER = "Y".codeUnit!
let KEY_Z_UPPER = "Z".codeUnit!

extension String
{
	/// Returns the UTF-8 code unit of the first character in the string.
	var codeUnit: UIKeyCode?
	{
		if let codeUnit = self.utf8.first
		{
			return UIKeyCode(codeUnit)
		}
		else
		{
			return nil
		}
	}
}
