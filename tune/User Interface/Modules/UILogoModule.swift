//
//  UILogoModule.swift
//  tune
//
//  Created by Bruno Philipe on 28/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UILogoModule: UserInterfaceModule
{
	private weak var userInterface: UserInterface?

	private let logoColors: UILogoColors

	private let logoWidth: Int32 = 33

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		logoColors = UILogoColors(
			line1: userInterface.registerColorPair(fore: COLOR_RED, back: COLOR_BLACK),
			line2: userInterface.registerColorPair(fore: COLOR_MAGENTA, back: COLOR_BLACK),
			line3: userInterface.registerColorPair(fore: COLOR_YELLOW, back: COLOR_BLACK),
			line4: userInterface.registerColorPair(fore: COLOR_GREEN, back: COLOR_BLACK),
			line5: userInterface.registerColorPair(fore: COLOR_CYAN, back: COLOR_BLACK),
			line6: userInterface.registerColorPair(fore: COLOR_BLUE, back: COLOR_BLACK)
		)
	}

	func draw()
	{
		if let ui = self.userInterface
		{
			let posX: Int32 = (ui.width / 2) - (logoWidth / 2)

			ui.clean()

			ui.drawText("  dP                             ", at: UIPoint(posX, 3), withColorPair: logoColors.line1)
			ui.drawText("  88                             ", at: UIPoint(posX, 4), withColorPair: logoColors.line2)
			ui.drawText("d8888P dP    dP 88d888b. .d8888b.", at: UIPoint(posX, 5), withColorPair: logoColors.line3)
			ui.drawText("  88   88    88 88'  `88 88ooood8", at: UIPoint(posX, 6), withColorPair: logoColors.line4)
			ui.drawText("  88   88.  .88 88    88 88.  ...", at: UIPoint(posX, 7), withColorPair: logoColors.line5)
			ui.drawText("  dP   `88888P' dP    dP `88888P'", at: UIPoint(posX, 8), withColorPair: logoColors.line6)

			ui.commit()
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
