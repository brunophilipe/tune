//
//  UserInterface.swift
//  tune
//
//  Created by Bruno Philipe on 4/27/17.
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
import Darwin.ncurses

typealias UIColorPair = Int16

class UserInterface
{
	private var redrawQueue: DispatchQueue = DispatchQueue(label: "Redraw Queue", qos: DispatchQoS.background)

	private var controller: UserInterfaceController? = nil

	private var screen: OpaquePointer? = nil
	private var registeredColorsCount: Int16 = 0

	fileprivate var windows = [UIWindow]()

	/// This hook is invoked before every `draw()` call.
	var preDrawHook: (() -> Void)? = nil

	var isCleanDraw: Bool = true

	var currentState: UIState?
	{
		return controller?.state
	}

	private var _sharedColorWhiteOnBlack: UIColorPair = 0

	var sharedColorWhiteOnBlack: UIColorPair
	{
		return _sharedColorWhiteOnBlack
	}

	func setup(rootState: UIState) -> Bool
	{
		if let screen = initscr()
		{
			start_color()
			noecho()
			curs_set(0)
			keypad(screen, true)
			nodelay(screen, false)
			set_escdelay(150)

			_sharedColorWhiteOnBlack = registerColorPair(fore: COLOR_WHITE, back: COLOR_BLACK)

			let controller = UserInterfaceController(screen: screen, rootState: rootState)
			
			clear()

			controller.delegate = self

			self.controller = controller

			startDrawLoop()

			return true
		}
		else
		{
			return false
		}
	}

	func startEventLoop()
	{
		controller?.runEventLoop()
	}

	func registerColorPair(fore: Int32, back: Int32) -> UIColorPair
	{
		registeredColorsCount += 1

		init_pair(registeredColorsCount, Int16(fore), Int16(back))

		return registeredColorsCount
	}

	func registerWindow(_ window: UIWindow)
	{
		windows.append(window)
	}

	func commit()
	{
		refresh()
	}

	func clean()
	{
		clear()
		isCleanDraw = true
	}

	private func startDrawLoop()
	{
		draw()
	}

	private func stopDrawLoop()
	{
		redrawQueue.suspend()
		redrawQueue = DispatchQueue(label: "Redraw Queue", qos: DispatchQoS.background)
	}

	private func draw()
	{
		preDrawHook?()

		for window in windows
		{
			window.draw()
		}

		update_panels()
		doupdate()

		redrawQueue.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: self.draw)
	}

	func finalize()
	{
		curs_set(1)
		clear()
		endwin()
	}

	var width: Int32
	{
		return getmaxx(stdscr)
	}

	var height: Int32
	{
		return getmaxy(stdscr)
	}
}

struct UITextAttributes: OptionSet
{
	let rawValue: Int32

	static let bold			= UITextAttributes(rawValue: A_BOLD)
	static let underline	= UITextAttributes(rawValue: A_UNDERLINE)
	static let blink		= UITextAttributes(rawValue: A_BLINK)
	static let standout		= UITextAttributes(rawValue: A_STANDOUT)
	static let reverse		= UITextAttributes(rawValue: A_REVERSE)
}

extension UserInterface: UserInterfaceControllerDelegate
{
	func userInterfaceControllerReceivedResizeEvent(_ controller: UserInterfaceController)
	{
		let newSize = UISize(width, height)

		for window in windows
		{
			window.controller?.availableSizeChanged(newSize: newSize)
		}
	}

	func userInterfaceController(_ controller: UserInterfaceController, didChangeToState state: UIState)
	{
//		if let mainModule = self.mainUIModule
//		{
//			clean()
//			dispatchDraw(toModule: mainModule)
//		}
	}
}

extension UIKeyCode
{
	var display: String
	{
		switch self
		{
		case KEY_LEFT:		return "←"
		case KEY_RIGHT:		return "→"
		case KEY_UP:		return "↑"
		case KEY_DOWN:		return "↓"
		case KEY_TAB:		return "⇥"
		case KEY_ENTER:		return "↩︎"
		case KEY_SPACE:		return "⎵"
		case KEY_ESCAPE:	return "⎋"
		default:
			return String(UnicodeScalar.init(Int(self))!)
		}
	}
}

struct UIPoint
{
	var x: Int32
	var y: Int32

	init(_ x: Int32, _ y: Int32)
	{
		self.x = x
		self.y = y
	}

	func offset(x offsetX: Int32 = 0, y offsetY: Int32 = 0) -> UIPoint
	{
		return UIPoint(x + offsetX, y + offsetY)
	}

	func replacing(x: Int32? = nil, y: Int32? = nil) -> UIPoint
	{
		return UIPoint(x ?? self.x, y ?? self.y)
	}

	static var zero = UIPoint(0, 0)
}

extension UIPoint: Equatable
{
	static func ==(lhp: UIPoint, rhp: UIPoint) -> Bool
	{
		return lhp.x == rhp.x && lhp.y == rhp.y
	}
}

typealias UISize = UIPoint

struct UIFrame
{
	let origin: UIPoint
	let size: UISize

	init(origin: UIPoint = .zero, size: UISize)
	{
		self.origin = origin
		self.size = size
	}

	init(x: Int32, y: Int32, w: Int32, h: Int32)
	{
		self.origin = UIPoint(x, y)
		self.size = UISize(w, h)
	}

	var x: Int32
	{
		return origin.x
	}

	var y: Int32
	{
		return origin.y
	}

	var height: Int32
	{
		return size.y
	}

	var width: Int32
	{
		return size.x
	}

	var maxX: Int32
	{
		return x + width
	}

	var maxY: Int32
	{
		return y + height
	}
}
