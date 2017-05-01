//
//  UIControlBarPanel.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
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
