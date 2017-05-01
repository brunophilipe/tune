//
//  UIState.swift
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

class UIState
{
	/// The parent state of this state. It is set automatically when `subStates` is set.
	var parentState: UIState? = nil

	/// An array which maps individual `UIKeyCode` events to different substates. When the user triggers an event with the key code
	/// `UIKeyCode`, the application state will move to the associated state in the array. If no state is associated with the key
	/// code, then nothing happens.
	private var subStates = [(UIKeyCode, UIState)]()

	/// A label string to be displayed in control interfaces to identify this state.
	/// Should't be too long (20 chars max, not enforced).
	var label: String

	/// A state can have a delegate that can be used to customize the state flow machine.
	var delegate: UIStateDelegate? = nil

	/// An optional identifier. This is only a stored property.
	var identifier: Int? = nil

	var allSubStates: [(UIKeyCode, UIState)]
	{
		return self.subStates
	}

	init(label: String)
	{
		self.label = label
	}

	/// Sets the substate associated with the specified key code. Passing `nil` to the `state` parameter will clear the substate associated
	/// with the parameter `keyCode`, if any was set.
	func setSubState(_ state: UIState?, forKeyCode keyCode: UIKeyCode)
	{
		if let newState = state
		{
			subStates.append((keyCode, newState))
			state?.parentState = self
		}
		else
		{
			if let index = subStates.index(where: { $0.0 == keyCode })
			{
				subStates.remove(at: index)
			}
		}
	}

	/// Returns the substate for the specified key code, or `nil` if no state is associated with said key code.
	func substate(forKeyCode keyCode: UIKeyCode) -> UIState?
	{
		if let index = subStates.index(where: { $0.0 == keyCode })
		{
			return subStates[index].1
		}
		else
		{
			return nil
		}
	}

	/// Use this proxy state in the subStates array to represent which key should
	/// return the application to the parent state of the current state.
	static var parentState = UIState(label: "back")

	/// Use this proxy state in the subStates array to represent which key should
	/// cause the application to stop the event loop and quit.
	static var quitState = UIState(label: "quit")
}

class UIControlState: UIState
{
	private let block: () -> Void

	init(label: String, _ block: @escaping () -> Void)
	{
		self.block = block

		super.init(label: label)
	}

	func runBlock()
	{
		block()
	}
}

extension UIState: Equatable
{
	/// This extension allows UIState to be used as the argument of a `switch-case` statement.
	static func ==(lhs: UIState, rhs: UIState) -> Bool
	{
		return lhs === rhs
	}
}

extension UIKeyCode
{
	private static let navigationKeyCodes = [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_ENTER]

	var isNavigationKeyCode: Bool
	{
		return UIKeyCode.navigationKeyCodes.contains(self)
	}
}

protocol UIStateDelegate
{
	func state(_ state: UIState, shouldMoveToSubstate substate: UIState) -> Bool
}

protocol UINavigatableStateDelegate
{
	func state(_ state: UIState, receivedNavigationKeyCode keyCode: UIKeyCode)
}
