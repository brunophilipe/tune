//
//  UITextPromptPanel.swift
//  tune
//
//  Created by Bruno Philipe on 2/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

/// This panel draws a line of text with a prompt (instruction to the user). The text is drawn aligned to the left.
class UITextPromptPanel: UIPanel
{
	var prompt: String? = nil
	{
		didSet { needsRedraw = true }
	}

	var text: String? = nil
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

	var promptAttributes: UITextAttributes = [.bold, .reverse]
	{
		didSet { needsRedraw = true }
	}

	var textAttributes: UITextAttributes = [.reverse]
	{
		didSet { needsRedraw = true }
	}

	override func draw()
	{
		if needsRedraw,
			let window = self.window,
			let textColor = self.textColor ?? window.controller?.userInterface?.sharedColorWhiteOnBlack
		{
			let availableTitleWidth = Int(frame.width - 2)

			// Title background
			window.usingTextAttributes(bgAttributes)
			{
				window.drawText(" " * frame.width, at: frame.origin, withColorPair: textColor)
			}

			if let prompt = self.prompt
			{
				// Prompt
				window.usingTextAttributes(promptAttributes)
				{
					window.drawText(prompt, at: frame.origin.offset(x: 1), withColorPair: textColor)
				}
			}

			if let title = self.text
			{
				// Title
				window.usingTextAttributes(textAttributes)
				{
					let offsetWidth: Int32

					if let promptWidth = self.prompt?.width
					{
						offsetWidth = promptWidth + 1
					}
					else
					{
						offsetWidth = 0
					}

					let truncatedTitle = title.truncated(to: (availableTitleWidth - Int(offsetWidth)))
					window.drawText(truncatedTitle, at: frame.origin.offset(x: offsetWidth + 1), withColorPair: textColor)
				}
			}

			needsRedraw = false
		}
	}
}
