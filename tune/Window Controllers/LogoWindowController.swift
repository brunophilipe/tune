//
//  LogoWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
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

class LogoWindowController: UIWindowController
{
	internal weak var userInterface: UserInterface?

	private var windowStorage: UIWindow

	private var boxPanel: UIBoxPanel? = nil
	private var logoPanel: LogoPanel? = nil

	var window: UIWindow
	{
		return windowStorage
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
		self.windowStorage = UIDialog(frame: UIFrame(x: 0, y: 0, w: 40, h: 11))

		self.windowStorage.controller = self

		window.frame = windowFrame

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = windowFrame

		boxPanel?.frame = boxPanelFrame
		logoPanel?.frame = logoPanelFrame

		if let frameChars = boxPanel?.frameChars
		{
			if window.frame.height < 11
			{
				boxPanel?.frameChars = frameChars.replacing(topRight: "┓", right: "┃")
			}
			else
			{
				boxPanel?.frameChars = frameChars.replacing(topRight: " ", right: " ")
			}
		}
	}

	private func buildPanels()
	{
		if let color = userInterface?.sharedColorWhiteOnBlack
		{
			let boxPanel = UIBoxPanel(frame: boxPanelFrame, frameColor: color)
			boxPanel.clearsBackground = true
			boxPanel.frameChars = UIBoxPanel.FrameChars.thickLine.replacing(right: " ", bottom: " ")

			window.container.addSubPanel(boxPanel)

			let logoPanel = LogoPanel(frame: logoPanelFrame)

			window.container.addSubPanel(logoPanel)

			self.boxPanel = boxPanel
			self.logoPanel = logoPanel
		}
	}

	private var windowFrame: UIFrame
	{
		if let ui = userInterface, ui.width < 70
		{
			return UIFrame(x: 0, y: 0, w: ui.width, h: 2)
		}
		else
		{
			return UIFrame(x: 0, y: 0, w: 40, h: 11)
		}
	}

	private var boxPanelFrame: UIFrame
	{
		let frameSize = window.frame.size
		return UIFrame(origin: .zero, size: frameSize.x < 40 ? window.frame.size.offset(x: -1, y: -1) : window.frame.size)
	}

	private var logoPanelFrame: UIFrame
	{
		let frameSize = window.frame.size

		if frameSize.y < 11
		{
			return UIFrame(origin: window.frame.size.offset(x: -2).replacing(y: 1), size: UISize(4, 1))
		}
		else
		{
			return UIFrame(origin: UIPoint(4, 2), size: UISize(33, 8))
		}
	}
}

private class LogoPanel: UIPanel
{
	private var logoColors: UILogoColors? = nil

	override var window: UIWindow?
	{
		didSet
		{
			if let ui = window?.controller?.userInterface
			{
				logoColors = UILogoColors(
					char1: ui.registerColorPair(fore: COLOR_RED,	back: COLOR_BLACK),
					char2: ui.registerColorPair(fore: COLOR_YELLOW,	back: COLOR_BLACK),
					char3: ui.registerColorPair(fore: COLOR_GREEN,	back: COLOR_BLACK),
					char4: ui.registerColorPair(fore: COLOR_BLUE,	back: COLOR_BLACK)
				)
			}
		}
	}

	override func draw()
	{
		if needsRedraw, let window = self.window, let logoColors = self.logoColors
		{
			if frame.height > 2
			{
				let point = frame.origin

				// Draw logo
				window.drawText("888   ", at: point,				withColorPair: logoColors.char1)
				window.drawText("888   ", at: point.offset(y: 1),	withColorPair: logoColors.char1)
				window.drawText("888   ", at: point.offset(y: 2),	withColorPair: logoColors.char1)
				window.drawText("888888", at: point.offset(y: 3),	withColorPair: logoColors.char1)
				window.drawText("888   ", at: point.offset(y: 4),	withColorPair: logoColors.char1)
				window.drawText("888   ", at: point.offset(y: 5),	withColorPair: logoColors.char1)
				window.drawText("Y88b. ", at: point.offset(y: 6),	withColorPair: logoColors.char1)
				window.drawText(" \"Y888", at: point.offset(y: 7),	withColorPair: logoColors.char1)

				window.drawText("        ", at: point.offset(x: 7),			withColorPair: logoColors.char2)
				window.drawText("        ", at: point.offset(x: 7, y: 1),	withColorPair: logoColors.char2)
				window.drawText("        ", at: point.offset(x: 7, y: 2),	withColorPair: logoColors.char2)
				window.drawText("888  888", at: point.offset(x: 7, y: 3),	withColorPair: logoColors.char2)
				window.drawText("888  888", at: point.offset(x: 7, y: 4),	withColorPair: logoColors.char2)
				window.drawText("888  888", at: point.offset(x: 7, y: 5),	withColorPair: logoColors.char2)
				window.drawText("Y88b 888", at: point.offset(x: 7, y: 6),	withColorPair: logoColors.char2)
				window.drawText(" \"Y88888", at: point.offset(x: 7, y: 7),	withColorPair: logoColors.char2)

				window.drawText("        ", at: point.offset(x: 16),		withColorPair: logoColors.char3)
				window.drawText("        ", at: point.offset(x: 16, y: 1),	withColorPair: logoColors.char3)
				window.drawText("        ", at: point.offset(x: 16, y: 2),	withColorPair: logoColors.char3)
				window.drawText("88888b. ", at: point.offset(x: 16, y: 3),	withColorPair: logoColors.char3)
				window.drawText("888 \"88b", at: point.offset(x: 16, y: 4),	withColorPair: logoColors.char3)
				window.drawText("888  888", at: point.offset(x: 16, y: 5),	withColorPair: logoColors.char3)
				window.drawText("888  888", at: point.offset(x: 16, y: 6),	withColorPair: logoColors.char3)
				window.drawText("888  888", at: point.offset(x: 16, y: 7),	withColorPair: logoColors.char3)

				window.drawText("        ", at: point.offset(x: 25),		withColorPair: logoColors.char4)
				window.drawText("        ", at: point.offset(x: 25, y: 1),	withColorPair: logoColors.char4)
				window.drawText("        ", at: point.offset(x: 25, y: 2),	withColorPair: logoColors.char4)
				window.drawText(" .d88b. ", at: point.offset(x: 25, y: 3),	withColorPair: logoColors.char4)
				window.drawText("d8P  Y8b", at: point.offset(x: 25, y: 4),	withColorPair: logoColors.char4)
				window.drawText("88888888", at: point.offset(x: 25, y: 5),	withColorPair: logoColors.char4)
				window.drawText("Y8b.    ", at: point.offset(x: 25, y: 6),	withColorPair: logoColors.char4)
				window.drawText(" \"Y8888 ", at: point.offset(x: 25, y: 7),	withColorPair: logoColors.char4)
			}
			else
			{
				let point = UIPoint((window.frame.width / 2) - 2, 1)

				window.drawText("t", at: point,				 withColorPair: logoColors.char1)
				window.drawText("u", at: point.offset(x: 1), withColorPair: logoColors.char2)
				window.drawText("n", at: point.offset(x: 2), withColorPair: logoColors.char3)
				window.drawText("e", at: point.offset(x: 3), withColorPair: logoColors.char4)
			}

			needsRedraw = false
		}
	}

	private struct UILogoColors
	{
		let char1: UIColorPair
		let char2: UIColorPair
		let char3: UIColorPair
		let char4: UIColorPair
	}
}
