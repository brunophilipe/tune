//
//  UIBoxPanel.swift
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

/// This panel draws a box around its perimeter, using configurable characters.
class UIBoxPanel: UIPanel
{
	var clearsBackground = false
	{
		didSet { needsRedraw = true }
	}

	var title: String? = nil
	{
		didSet { needsRedraw = true }
	}

	let frameColor: UIColorPair

	var frameChars: FrameChars = .singleLine
	{
		didSet { needsRedraw = true }
	}

	init(frame: UIFrame, frameColor: UIColorPair)
	{
		self.frameColor = frameColor

		super.init(frame: frame)
	}

	override func draw()
	{
		if needsRedraw, let window = self.window
		{
			if clearsBackground
			{
				window.cleanRegion(frame: UIFrame(size: frame.size))
			}

			let maxWidth = window.frame.width - frame.x
			let maxHeight = window.frame.height - frame.y

			let startX: Int32
			let startY: Int32
			let lengthX: Int32
			let lengthY: Int32

			var didDraw = (left: false, right: false, top: false, bottom: false)

			if frame.x >= 0
			{
				startX = frame.x
				lengthX = min(maxWidth, frame.width)
			}
			else
			{
				startX = 0
				lengthX = min(maxWidth, frame.width) + frame.x
			}

			if frame.y >= 0
			{
				startY = frame.y
				lengthY = min(maxHeight, frame.height)
			}
			else
			{
				startY = 0
				lengthY = min(maxHeight, frame.height) + frame.y
			}

			if lengthX < 2 || lengthY < 2
			{
				// Not a meaningful draw
				return
			}

			// Draw left bar
			if frame.x >= 0, let char = frameChars.left, char != " "
			{
				for i in startY ..< startY + lengthY
				{
					window.drawText(String(char),
					            at: UIPoint(frame.x, i),
					            withColorPair: frameColor)
				}

				didDraw.left = true
			}

			// Draw top bar
			if frame.y >= 0, let char = frameChars.top, char != " "
			{
				for i in startX ..< startX + lengthX
				{
					window.drawText(String(char),
					            at: UIPoint(i, frame.y),
					            withColorPair: frameColor)
				}

				if let title = self.title
				{
					let pX = (lengthX / 2) - ((title.width + 2) / 2)

					window.drawText(" \(title) ", at: UIPoint(startX + pX, frame.y), withColorPair: frameColor)
				}

				didDraw.top = true
			}

			// Draw right bar
			if frame.x + lengthX <= window.frame.width, let char = frameChars.right, char != " "
			{
				for i in startY ..< startY + lengthY
				{
					window.drawText(String(char),
					            at: UIPoint(frame.maxX - 1, i),
					            withColorPair: frameColor)
				}

				didDraw.right = true
			}

			// Draw bottom bar
			if frame.y + lengthY <= window.frame.height, let char = frameChars.bottom, char != " "
			{
				for i in startX ..< startX + lengthX
				{
					window.drawText(String(char),
					            at: UIPoint(i, frame.maxY - 1),
					            withColorPair: frameColor)
				}

				didDraw.bottom = true
			}

			// Draw top-left corner
			if didDraw.top && didDraw.left, let char = frameChars.topLeft
			{
				window.drawText(String(char),
				            at: UIPoint(startX, startY),
				            withColorPair: frameColor)
			}

			// Draw top-right corner
			if didDraw.top && didDraw.right, let char = frameChars.topRight
			{
				window.drawText(String(char),
				            at: UIPoint(startX + lengthX - 1, startY),
				            withColorPair: frameColor)
			}

			// Draw bottom-left corner
			if didDraw.bottom && didDraw.left, let char = frameChars.bottomLeft
			{
				window.drawText(String(char),
				            at: UIPoint(startX, startY + lengthY - 1),
				            withColorPair: frameColor)
			}

			// Draw bottom-right corner
			if didDraw.bottom && didDraw.right, let char = frameChars.bottomRight
			{
				window.drawText(String(char),
				            at: UIPoint(startX + lengthX - 1, startY + lengthY - 1),
				            withColorPair: frameColor)
			}

			needsRedraw = false
		}
	}

	struct FrameChars
	{
		let topLeft, topRight, bottomLeft, bottomRight, left, right, top, bottom: Character?

		func replacing(topLeft: Character? = nil,
		               topRight: Character? = nil,
		               bottomLeft: Character? = nil,
		               bottomRight: Character? = nil,
		               left: Character? = nil,
		               right: Character? = nil,
		               top: Character? = nil,
		               bottom: Character? = nil) -> FrameChars
		{
			return FrameChars(
				topLeft:		topLeft ?? self.topLeft,
				topRight:		topRight ?? self.topRight,
				bottomLeft:		bottomLeft ?? self.bottomLeft,
				bottomRight:	bottomRight ?? self.bottomRight,
				left:			left ?? self.left,
				right:			right ?? self.right,
				top:			top ?? self.top,
				bottom:			bottom ?? self.bottom
			)
		}

		static var singleLine = FrameChars(
			topLeft:		"┌",
			topRight:		"┐",
			bottomLeft:		"└",
			bottomRight:	"┘",
			left:			"│",
			right:			"│",
			top:			"─",
			bottom:			"─"
		)

		static var doubleLine = FrameChars(
			topLeft:		"╔",
			topRight:		"╗",
			bottomLeft:		"╚",
			bottomRight:	"╝",
			left:			"║",
			right:			"║",
			top:			"═",
			bottom:			"═"
		)

		static var thickLine = FrameChars(
			topLeft:		"┏",
			topRight:		"┓",
			bottomLeft:		"┗",
			bottomRight:	"┛",
			left:			"┃",
			right:			"┃",
			top:			"━",
			bottom:			"━"
		)
	}
}
