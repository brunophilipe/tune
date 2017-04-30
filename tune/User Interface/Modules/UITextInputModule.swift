//
//  UITextInputModule.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UITextInputModule: UserInterfacePositionableModule, UserInterfaceSizableModule
{
	weak var userInterface: UserInterface?

	var textColor: UIColorPair

	var prompt: String? = nil
	{
		didSet
		{
			self.needsRedraw = true
		}
	}

	var height: Int32 = 1
	{
		didSet
		{
			self.needsRedraw = true
		}
	}

	var width: Int32 = 4
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
	}

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		if shouldDraw(), let ui = self.userInterface
		{
			var promptText: String? = nil

			if let prompt = self.prompt
			{
				promptText = " \(prompt)"
			}

			let remainingWidth = width - (promptText?.width ?? 0)

			// Draw prompt + background
			ui.drawText("\(promptText ?? "")\(" " * remainingWidth)", at: point, withColorPair: textColor)
		}
	}
}
