//
//  UIState.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIState
{
	/// The parent state of this state. It is set automatically when `subStates` is set.
	var parentState: UIState? = nil

	/// An array which maps individual `UIKeyCode` events to different substates. When the user triggers an event with the key code
	/// `UIKeyCode`, the application state will move to the associated state in the array. If no state is associated with the key
	/// code, then nothing happens.
	private var subStates = [UIKeyCode: UIState]()

	/// A label string to be displayed in control interfaces to identify this state.
	/// Should't be too long (20 chars max, not enforced).
	var label: String

	/// A state can have a delegate that can be used to customize the state flow machine.
	var delegate: UIStateDelegate? = nil

	init(label: String)
	{
		self.label = label
	}

	private convenience init()
	{
		self.init(label: "")
	}

	/// Sets the substate associated with the specified key code. Passing `nil` to the `state` parameter will clear the substate associated
	/// with the parameter `keyCode`, if any was set.
	func setSubState(_ state: UIState?, forKeyCode keyCode: UIKeyCode)
	{
		subStates[keyCode] = state

		state?.parentState = self
	}

	/// Returns the substate for the specified key code, or `nil` if no state is associated with said key code.
	func substate(forKeyCode keyCode: UIKeyCode) -> UIState?
	{
		return subStates[keyCode]
	}

	/// Use this proxy state in the subStates array to represent which key should
	/// return the application to the parent state of the current state.
	static var parentState = UIState()

	/// Use this proxy state in the subStates array to represent which key should
	/// cause the application to stop the event loop and quit.
	static var quitState = UIState()
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
