//
//  UIControlBarModule.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIControlBarModule: UserInterfaceSizableModule, UserInterfacePositionableModule
{
	private var textColor: UIColorPair

	weak var userInterface: UserInterface? = nil

	var width: Int32
	{
		didSet
		{
			self.needsRedraw = true
		}
	}

	var height: Int32
	{
		return 1
	}

	var currentState: UIState? = nil
	{
		didSet
		{
			self.needsRedraw = true
		}
	}

	var needsRedraw: Bool = true

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		textColor = userInterface.registerColorPair(fore: COLOR_BLACK, back: COLOR_WHITE)

		width = userInterface.width
	}

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		if let ui = self.userInterface, let state = self.currentState
		{
			// First draw the whole BG
			ui.drawText(" " * width, at: point, withColorPair: textColor)

			var totalUsedLength: Int32 = 0

			for (keyCode, subState) in state.allSubStates
			{
				let usedLength = drawControlInfo(forState: subState,
				                                 keyCode: keyCode,
				                                 onUI: ui,
				                                 startingAt: UIPoint(totalUsedLength + 2, point.y))

				if usedLength == 0
				{
					// Did not fit!
					break
				}

				totalUsedLength += usedLength
			}
		}
	}

	private func drawControlInfo(forState state: UIState, keyCode: UIKeyCode, onUI ui: UserInterface, startingAt point: UIPoint) -> Int32
	{
		let availableSpace = width - 1
		let text = " \(keyCode.display) \(state.label) "

		if point.x + text.width >= availableSpace
		{
			// Won't fit!
			return 0
		}

		ui.usingTextAttributes(.standout)
		{
			ui.drawText(text, at: point, withColorPair: textColor)
		}

		return Int32(text.characters.count + 2)
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
