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
	private let logoColors: UILogoColors

	weak var userInterface: UserInterface?
	var needsRedraw: Bool = true

	var width: Int32
	{
		return 34
	}

	var height: Int32
	{
		return 8
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		logoColors = UILogoColors(
			char1:	userInterface.registerColorPair(fore: COLOR_RED,	back: COLOR_BLACK),
			char2:	userInterface.registerColorPair(fore: COLOR_YELLOW,	back: COLOR_BLACK),
			char3:	userInterface.registerColorPair(fore: COLOR_GREEN,	back: COLOR_BLACK),
			char4:	userInterface.registerColorPair(fore: COLOR_BLUE,	back: COLOR_BLACK)
		)
	}

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		if shouldDraw(), let ui = self.userInterface
		{
			// Draw logo
			ui.drawText("888   ", at: point,				withColorPair: logoColors.char1)
			ui.drawText("888   ", at: point.offset(y: 1),	withColorPair: logoColors.char1)
			ui.drawText("888   ", at: point.offset(y: 2),	withColorPair: logoColors.char1)
			ui.drawText("888888", at: point.offset(y: 3),	withColorPair: logoColors.char1)
			ui.drawText("888   ", at: point.offset(y: 4),	withColorPair: logoColors.char1)
			ui.drawText("888   ", at: point.offset(y: 5),	withColorPair: logoColors.char1)
			ui.drawText("Y88b. ", at: point.offset(y: 6),	withColorPair: logoColors.char1)
			ui.drawText(" \"Y888", at: point.offset(y: 7),	withColorPair: logoColors.char1)

			ui.drawText("        ", at: point.offset(x: 7),			withColorPair: logoColors.char2)
			ui.drawText("        ", at: point.offset(x: 7, y: 1),	withColorPair: logoColors.char2)
			ui.drawText("        ", at: point.offset(x: 7, y: 2),	withColorPair: logoColors.char2)
			ui.drawText("888  888", at: point.offset(x: 7, y: 3),	withColorPair: logoColors.char2)
			ui.drawText("888  888", at: point.offset(x: 7, y: 4),	withColorPair: logoColors.char2)
			ui.drawText("888  888", at: point.offset(x: 7, y: 5),	withColorPair: logoColors.char2)
			ui.drawText("Y88b 888", at: point.offset(x: 7, y: 6),	withColorPair: logoColors.char2)
			ui.drawText(" \"Y88888", at: point.offset(x: 7, y: 7),	withColorPair: logoColors.char2)

			ui.drawText("        ", at: point.offset(x: 16),		withColorPair: logoColors.char3)
			ui.drawText("        ", at: point.offset(x: 16, y: 1),	withColorPair: logoColors.char3)
			ui.drawText("        ", at: point.offset(x: 16, y: 2),	withColorPair: logoColors.char3)
			ui.drawText("88888b. ", at: point.offset(x: 16, y: 3),	withColorPair: logoColors.char3)
			ui.drawText("888 \"88b", at: point.offset(x: 16, y: 4),	withColorPair: logoColors.char3)
			ui.drawText("888  888", at: point.offset(x: 16, y: 5),	withColorPair: logoColors.char3)
			ui.drawText("888  888", at: point.offset(x: 16, y: 6),	withColorPair: logoColors.char3)
			ui.drawText("888  888", at: point.offset(x: 16, y: 7),	withColorPair: logoColors.char3)

			ui.drawText("        ", at: point.offset(x: 25),		withColorPair: logoColors.char4)
			ui.drawText("        ", at: point.offset(x: 25, y: 1),	withColorPair: logoColors.char4)
			ui.drawText("        ", at: point.offset(x: 25, y: 2),	withColorPair: logoColors.char4)
			ui.drawText(" .d88b. ", at: point.offset(x: 25, y: 3),	withColorPair: logoColors.char4)
			ui.drawText("d8P  Y8b", at: point.offset(x: 25, y: 4),	withColorPair: logoColors.char4)
			ui.drawText("88888888", at: point.offset(x: 25, y: 5),	withColorPair: logoColors.char4)
			ui.drawText("Y8b.    ", at: point.offset(x: 25, y: 6),	withColorPair: logoColors.char4)
			ui.drawText(" \"Y8888 ", at: point.offset(x: 25, y: 7),	withColorPair: logoColors.char4)

			needsRedraw = false
		}
	}
}

extension UILogoModule
{
	fileprivate struct UILogoColors
	{
		let char1: UIColorPair
		let char2: UIColorPair
		let char3: UIColorPair
		let char4: UIColorPair
	}
}
