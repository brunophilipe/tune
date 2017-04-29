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
	private var lastDrawnPoint: UIPoint? = nil

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
		if (shouldDraw() || lastDrawnPoint != point), let ui = self.userInterface, let state = self.currentState
		{
			// First draw the whole BG
			ui.drawText(" " * width, at: point, withColorPair: textColor)
			ui.drawText("Controls:",at: point.offset(x: 1), withColorPair: textColor)

			var usedLength: Int32 = 9

			for (keyCode, subState) in state.allSubStates
			{
				usedLength += drawControlInfo(forState: subState, keyCode: keyCode, onUI: ui, startingAt: UIPoint(usedLength + 2, point.y))
				usedLength += 2
			}

			lastDrawnPoint = point
			needsRedraw = false
		}
	}

	private func drawControlInfo(forState state: UIState, keyCode: UIKeyCode, onUI ui: UserInterface, startingAt point: UIPoint) -> Int32
	{
		let text = " \(keyCode.display): \(state.label) "

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
		case KEY_LEFT,	KEY_ARROW_LEFT:		return "←"
		case KEY_RIGHT,	KEY_ARROW_RIGHT:	return "→"
		case KEY_UP,	KEY_ARROW_UP:		return "↑"
		case KEY_DOWN,	KEY_ARROW_DOWN:		return "↓"
		default:
			return String(UnicodeScalar.init(Int(self))!)
		}
	}
}
