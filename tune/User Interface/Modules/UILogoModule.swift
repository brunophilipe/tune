//
//  UILogoModule.swift
//  tune
//
//  Created by Bruno Philipe on 28/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UILogoModule: UserInterfacePositionableModule, UserInterfaceSizableModule
{
	private weak var userInterface: UserInterface?

	private let logoColors: UILogoColors

	var width: Int32
	{
		return 33
	}

	var height: Int32
	{
		return 6
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		logoColors = UILogoColors(
			line1:	userInterface.registerColorPair(fore: COLOR_RED,		back: COLOR_BLACK),
			line2:	userInterface.registerColorPair(fore: COLOR_MAGENTA,	back: COLOR_BLACK),
			line3:	userInterface.registerColorPair(fore: COLOR_YELLOW,		back: COLOR_BLACK),
			line4:	userInterface.registerColorPair(fore: COLOR_GREEN,		back: COLOR_BLACK),
			line5:	userInterface.registerColorPair(fore: COLOR_CYAN,		back: COLOR_BLACK),
			line6:	userInterface.registerColorPair(fore: COLOR_BLUE,		back: COLOR_BLACK)
		)
	}

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		if let ui = self.userInterface
		{
			// Draw logo
			ui.drawText("  dP                             ", at: point,				 withColorPair: logoColors.line1)
			ui.drawText("  88                             ", at: point.offset(y: 1), withColorPair: logoColors.line2)
			ui.drawText("d8888P dP    dP 88d888b. .d8888b.", at: point.offset(y: 2), withColorPair: logoColors.line3)
			ui.drawText("  88   88    88 88'  `88 88ooood8", at: point.offset(y: 3), withColorPair: logoColors.line4)
			ui.drawText("  88   88.  .88 88    88 88.  ...", at: point.offset(y: 4), withColorPair: logoColors.line5)
			ui.drawText("  dP   `88888P' dP    dP `88888P'", at: point.offset(y: 5), withColorPair: logoColors.line6)
		}
	}
}

extension UILogoModule
{
	fileprivate struct UILogoColors
	{
		let line1: UIColorPair
		let line2: UIColorPair
		let line3: UIColorPair
		let line4: UIColorPair
		let line5: UIColorPair
		let line6: UIColorPair
	}
}
