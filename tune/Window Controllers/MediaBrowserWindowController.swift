//
//  MediaBrowserWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
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
		self.windowStorage = UIDialog(frame: UIFrame(x: 40, y: 11, w: userInterface.width - 40, h: userInterface.height - 12))
		self.windowStorage.controller = self

		window.frame = windowFrame

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = windowFrame

		boxPanel?.frame = boxPanelFrame

		if let frameChars = boxPanel?.frameChars
		{
			if (userInterface?.width ?? 70) < 70
			{
				boxPanel?.frameChars = frameChars.replacing(topLeft: "┳")
			}
			else
			{
				boxPanel?.frameChars = frameChars.replacing(topLeft: "╋")
			}
		}
	}

	private func buildPanels()
	{
		if let ui = self.userInterface
		{
			let color = ui.sharedColorWhiteOnBlack

			let boxPanel = UIBoxPanel(frame: boxPanelFrame, frameColor: color)
			boxPanel.frameChars = UIBoxPanel.FrameChars.thickLine.replacing(
				topLeft: "╋",
				topRight: "┫",
				bottomLeft:  "┻"
			)

			window.container.addSubPanel(boxPanel)

			self.boxPanel = boxPanel
		}
	}

	private var windowFrame: UIFrame
	{
		if let ui = self.userInterface
		{
			if ui.width < 70
			{
				return UIFrame(x: 40, y: 13, w: ui.width - 40, h: ui.height - 14)
			}
			else
			{
				return UIFrame(x: 40, y: 11, w: ui.width - 40, h: ui.height - 12)
			}
		}
		else
		{
			return UIFrame(x: 40, y: 11, w: 20, h: 10)
		}
	}

	private var boxPanelFrame: UIFrame
	{
		return UIFrame(origin: .zero, size: window.frame.size)
	}
}
