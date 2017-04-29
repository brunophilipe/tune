//
//  UIPlayQueueModule.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIPlayQueueModule: UserInterfacePositionableModule, UserInterfaceSizableModule
{
	private let textColor: UIColorPair

	weak var userInterface: UserInterface? = nil
	var needsRedraw: Bool = true

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		self.textColor = userInterface.sharedColorWhiteOnBlack

		self.width = 0
		self.height = 0
	}

	var width: Int32
	var height: Int32

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		if shouldDraw(), let ui = self.userInterface
		{
			// Title background
			ui.usingTextAttributes(.standout)
			{
				ui.drawText(" " * width, at: point, withColorPair: textColor)
			}

			// Title
			let title = "\("Up Next".truncated(to: Int(width) - 2)):"
			ui.usingTextAttributes([.bold, .standout])
			{

				let pX = (width / 2) - (title.width / 2)
				ui.drawText(title, at: point.offset(x: pX), withColorPair: textColor)
			}

			if height > 0
			{
				for row in 1..<height
				{
					ui.drawText("=" * width, at: point.offset(y: row), withColorPair: textColor)
				}
			}

			needsRedraw = false
		}
	}
}
