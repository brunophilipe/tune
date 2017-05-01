//
//  LogoWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

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
		self.windowStorage = UIWindow(frame: UIFrame(x: 0, y: 0, w: 40, h: 11))

		self.windowStorage.controller = self

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		// Nothing to do
	}

	private func buildPanels()
	{
		if let color = userInterface?.sharedColorWhiteOnBlack
		{
			let boxPanel = UIBoxPanel(frame: UIFrame(origin: .zero, size: window.frame.size), frameColor: color)
			boxPanel.clearsBackground = true
			boxPanel.frameChars = UIBoxPanel.FrameChars.thickLine.replacing(right: " ", bottom: " ")

			window.container.addSubPanel(boxPanel)

			self.boxPanel = boxPanel
		}

		logoPanel = LogoPanel(frame: UIFrame(origin: UIPoint(4, 2), size: UISize(33, 8)))
		window.container.addSubPanel(logoPanel!)
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
		if let window = self.window, let logoColors = self.logoColors
		{
			let point = self.frame.origin

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
	}

	private struct UILogoColors
	{
		let char1: UIColorPair
		let char2: UIColorPair
		let char3: UIColorPair
		let char4: UIColorPair
	}
}
