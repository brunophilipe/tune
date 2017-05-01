//
//  SearchWindowController.swift
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

class SearchWindowController: UIWindowController, DesiresCurrentState
{
	internal weak var userInterface: UserInterface?

	private var dialog: UIDialog

	private var boxPanel: UIBoxPanel? = nil

	var window: UIWindow
	{
		return dialog
	}

	var currentState: UIState?
	{
		didSet
		{
			if currentState != oldValue
			{
				if currentState?.identifier == UIState.TuneStates.search
				{
					dialog.hidden = false
					dialog.pullToTop()
				}
				else
				{
					dialog.hidden = true
				}
			}
		}
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		self.dialog = UIDialog(frame: UIFrame(x: 0, y: 0, w: 10, h: 10))
		self.dialog.controller = self

		dialog.frame = windowFrame

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = windowFrame

		boxPanel?.frame = boxPanelFrame
	}

	private func buildPanels()
	{
		if let color = userInterface?.sharedColorWhiteOnBlack
		{
			let boxPanel = UIBoxPanel(frame: boxPanelFrame, frameColor: color)
			boxPanel.frameChars = UIBoxPanel.FrameChars.doubleLine
			boxPanel.clearsBackground = true
			boxPanel.title = "Search"

			window.container.addSubPanel(boxPanel)

			self.boxPanel = boxPanel
		}
	}

	private var windowFrame: UIFrame
	{
		if let ui = self.userInterface
		{
			var size = UISize(0, 0)

			if ui.width <= 80
			{
				size.x = max(ui.width - 4, 2)
			}
			else if ui.width >= 160
			{
				size.x = 120
			}
			else
			{
				size.x = Int32(Double(ui.width) * 0.75)
			}

			if ui.height <= 20
			{
				size.y = max(ui.height - 4, 2)
			}
			else if ui.height >= 60
			{
				size.y = 45
			}
			else
			{
				size.y = Int32(Double(ui.height) * 0.75)
			}

			let origin = UIPoint((ui.width / 2) - (size.x / 2), (ui.height / 2) - (size.y / 2))

			return UIFrame(origin: origin, size: size)
		}
		else
		{
			return UIFrame(x: 0, y: 0, w: 10, h: 10)
		}
	}

	private var boxPanelFrame: UIFrame
	{
		return UIFrame(origin: .zero, size: window.frame.size)
	}
}
