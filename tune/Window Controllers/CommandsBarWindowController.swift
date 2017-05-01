//
//  CommandsBarWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
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

import Cocoa

class CommandsBarWindowController: UIWindowController, DesiresCurrentState
{
	internal weak var userInterface: UserInterface?

	private var windowStorage: UIWindow
	private var barPanel: UIControlBarPanel? = nil

	var currentState: UIState? = nil
	{
		didSet
		{
			if currentState != oldValue
			{
				updateBarPanel()
			}
		}
	}

	var window: UIWindow
	{
		return windowStorage
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
		self.windowStorage = UIWindow(frame: UIFrame(x: 0, y: userInterface.height - 1, w: userInterface.width, h: 1))

		self.windowStorage.controller = self

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = UIFrame(x: 0, y: newSize.y - 1, w: newSize.x, h: 1)

		barPanel?.frame = UIFrame(origin: UIPoint.zero, size: window.frame.size)
	}

	private func buildPanels()
	{
		if let color = userInterface?.registerColorPair(fore: COLOR_BLACK, back: COLOR_WHITE)
		{
			let barPanel = UIControlBarPanel(frame: UIFrame(origin: UIPoint.zero, size: window.frame.size))
			barPanel.textColor = color
			window.container.addSubPanel(barPanel)

			self.barPanel = barPanel
		}
	}

	private func updateBarPanel()
	{
		if let state = self.currentState, let barPanel = self.barPanel
		{
			var barItems = [String]()

			for (keyCode, state) in state.allSubStates
			{
				barItems.append("\(keyCode.display) \(state.label)")
			}

			barPanel.barItems = barItems
		}
		else
		{
			barPanel?.barItems = nil
		}
	}
}

private extension UIKeyCode
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
