//
//  UIControlBarPanel.swift
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

import Cocoa

class UIControlBarPanel: UIPanel
{
	var barItems: [String]? = nil

	var textColor: UIColorPair? = nil

	override func draw()
	{
		if let window = self.window, let barItems = self.barItems, let textColor = self.textColor ?? window.controller?.userInterface?.sharedColorWhiteOnBlack
		{
			let point = UIPoint.zero

			// First draw the whole BG
			window.drawText(" " * frame.width, at: point, withColorPair: textColor)

			var usedLength: Int32 = 2
			let availableWidth = frame.width - 1

			for item in barItems
			{
				let itemText = " \(item) "

				if usedLength + itemText.width < availableWidth
				{
					window.usingTextAttributes(.reverse)
					{
						window.drawText(itemText, at: point.offset(x: usedLength), withColorPair: textColor)
					}

					usedLength += itemText.width + 2
				}
				else
				{
					// Did not fit!
					break
				}
			}
		}
	}
}
