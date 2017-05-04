//
//  UICenteredTitlePanel.swift
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

/// This bar draws a text line, aligned to the center.
class UICenteredTitlePanel: UIPanel
{
	var title: String? = nil
	{
		didSet { needsRedraw = true }
	}

	var textColor: UIColorPair? = nil
	{
		didSet { needsRedraw = true }
	}

	var bgAttributes: UITextAttributes = .reverse
	{
		didSet { needsRedraw = true }
	}

	var attributes: UITextAttributes = [.bold, .reverse]
	{
		didSet { needsRedraw = true }
	}

	override func draw()
	{
		if needsRedraw,
			let window = self.window,
			let textColor = self.textColor ?? window.controller?.userInterface?.sharedColorWhiteOnBlack
		{
			let availableTitleWidth = Int(frame.width - 1)

			// Title background
			window.usingTextAttributes(bgAttributes)
			{
				window.drawText(" " * frame.width, at: frame.origin, withColorPair: textColor)
			}

			if let title = self.title
			{
				// Title
				window.usingTextAttributes(attributes)
				{
					let truncatedTitle = title.truncated(to: availableTitleWidth)
					let pX = max(Int32(availableTitleWidth / 2) - (truncatedTitle.width / 2), 1)
					window.drawText(truncatedTitle, at: frame.origin.replacing(x: pX), withColorPair: textColor)
				}
			}

			needsRedraw = false
		}
	}
}
