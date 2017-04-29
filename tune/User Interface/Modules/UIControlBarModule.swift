//
//  UIControlBarModule.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIControlBarModule: UserInterfaceModule
{
	private weak var userInterface: UserInterface? = nil

	private var textColor: UIColorPair

	var currentState: UIState? = nil

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		textColor = userInterface.registerColorPair(fore: COLOR_BLACK, back: COLOR_WHITE)
	}

	func draw()
	{
		if let ui = self.userInterface, let state = self.currentState
		{
			let pY = ui.height - 1

			// First draw the whole BG
			ui.drawText(" " * ui.width, at: UIPoint(0, pY), withColorPair: textColor)
			ui.drawText("Controls:",at: UIPoint(1, pY), withColorPair: textColor)

			var usedLength: Int32 = 9

			for (keyCode, subState) in state.allSubStates
			{
				usedLength += drawControlInfo(forState: subState, keyCode: keyCode, onUI: ui, startingAt: UIPoint(usedLength + 2, pY))
				usedLength += 2
			}
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
