//
//  UICenteredTitlePanel.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class UICenteredTitlePanel: UIPanel
{
	var title: String? = nil

	var textColor: UIColorPair? = nil

	override func draw()
	{
		if let window = self.window, let textColor = self.textColor ?? window.controller?.userInterface?.sharedColorWhiteOnBlack
		{
			let availableTitleWidth = Int(frame.width - 1)

			// Title background
			window.usingTextAttributes(.reverse)
			{
				window.drawText(" " * frame.width, at: frame.origin, withColorPair: textColor)
			}

			if let title = self.title
			{
				// Title
				window.usingTextAttributes([.bold, .reverse])
				{
					let truncatedTitle = title.truncated(to: availableTitleWidth)
					let pX = max(Int32(availableTitleWidth / 2) - (truncatedTitle.width / 2), 1)
					window.drawText(truncatedTitle, at: frame.origin.replacing(x: pX), withColorPair: textColor)
				}
			}
		}
	}
}
