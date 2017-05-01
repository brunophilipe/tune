//
//  MediaBrowserWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class MediaBrowserWindowController: UIWindowController
{
	internal weak var userInterface: UserInterface?

	private var windowStorage: UIWindow

	private var boxPanel: UIBoxPanel? = nil

	var window: UIWindow
	{
		return windowStorage
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
		self.windowStorage = UIWindow(frame: UIFrame(x: 40, y: 11, w: userInterface.width - 40, h: userInterface.height - 12))
		self.windowStorage.controller = self

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = UIFrame(x: 40, y: 11, w: newSize.x - 40, h: newSize.y - 12)

		boxPanel?.frame = boxPanelFrame
	}

	private func buildPanels()
	{
		if let ui = self.userInterface
		{
			let color = ui.sharedColorWhiteOnBlack

			let boxPanel = UIBoxPanel(frame: boxPanelFrame, frameColor: color)
			boxPanel.frameChars = UIBoxPanel.FrameChars.doubleLine.replacing(
				topLeft: "╬",
				topRight: "╣",
				bottomLeft:  "╩"
			)

			window.container.addSubPanel(boxPanel)

			self.boxPanel = boxPanel
		}
	}

	private var boxPanelFrame: UIFrame
	{
		return UIFrame(origin: .zero, size: window.frame.size)
	}
}
