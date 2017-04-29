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

struct UIPoint
{
	let x: Int32
	let y: Int32

	init(_ x: Int32, _ y: Int32)
	{
		self.x = x
		self.y = y
	}

	func offset(x offsetX: Int32 = 0, y offsetY: Int32 = 0) -> UIPoint
	{
		return UIPoint(x + offsetX, y + offsetY)
	}

	static var zero = UIPoint(0, 0)
}

typealias UISize = UIPoint

class UserInterface
{
	private var redrawQueue: DispatchQueue = DispatchQueue(label: "Redraw Queue", qos: DispatchQoS.background)

	private var controller: UserInterfaceController? = nil

	private var screen: OpaquePointer? = nil
	private var registeredColorsCount: Int16 = 0

	var preDrawHook: (() -> Void)? = nil

	var mainUIModule: UserInterfaceModule? = nil
	{
		didSet
		{
			if mainUIModule != nil
			{
				startDrawLoop()
			}
			else
			{
				stopDrawLoop()
			}
		}
	}

	var currentState: UIState?
	{
		return controller?.state
	}

	lazy var sharedColorWhiteOnBlack: UIColorPair =
	{
		return self.registerColorPair(fore: COLOR_WHITE, back: COLOR_BLACK)
	}()

	func setup(rootState: UIState) -> Bool
	{
		if let screen = initscr()
		{
			start_color()
			noecho()
			curs_set(0)

			nodelay(screen, false)

			let controller = UserInterfaceController(screen: screen, rootState: rootState)
			
			clear()

			controller.resizeEventObserver = self

			self.controller = controller

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

	func drawText(_ text: String, at point: UIPoint, withColorPair colorPair: UIColorPair)
	{
		enableColorPair(colorPair)
		move(point.y, point.x)
		addstr(text)
		disableColorPair(colorPair)
	}

	func commit()
	{
		refresh()
	}

	func clean()
	{
		clear()
	}

	/// Will apply the parameter attributes to all text drawn inside the parameter block. The block runs immediatelly and is non-escaping.
	///
	/// **WARNING:** This function does not (yet) support nesting. Don't call `usingTextAttributes` inside of the parameter block.
	func usingTextAttributes(_ attributes: TextAttributes, _ block: @convention(block) () -> Void)
	{
		enableTextAttributes(attributes)
		block()
		disableTextAttributes(attributes)
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
		if let mainModule = self.mainUIModule
		{
			dispatchDraw(toModule: mainModule)
			redrawQueue.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: self.draw)
		}
		else
		{
			stopDrawLoop()
		}
	}

	private func enableColorPair(_ pair: UIColorPair)
	{
		attron(COLOR_PAIR(Int32(pair)))
	}

	private func disableColorPair(_ pair: UIColorPair)
	{
		attroff(COLOR_PAIR(Int32(pair)))
	}

	private func enableTextAttributes(_ attributes: TextAttributes)
	{
		attron(attributes.rawValue)
	}

	private func disableTextAttributes(_ attributes: TextAttributes)
	{
		attroff(attributes.rawValue)
	}

	fileprivate func dispatchDraw(toModule mainModule: UserInterfaceModule)
	{
		preDrawHook?()
		mainModule.draw()
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

	struct TextAttributes: OptionSet
	{
		let rawValue: Int32

		static let bold			= TextAttributes(rawValue: A_BOLD)
		static let underline	= TextAttributes(rawValue: A_UNDERLINE)
		static let blink		= TextAttributes(rawValue: A_BLINK)
		static let standout		= TextAttributes(rawValue: A_STANDOUT)
	}
}

extension UserInterface: UIResizeEventObserver
{
	func userInterfaceControllerReceivedResizeEvent(_ controller: UserInterfaceController)
	{
		if let mainModule = self.mainUIModule
		{
			dispatchDraw(toModule: mainModule)
		}
	}
}
