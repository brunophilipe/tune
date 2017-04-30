//
//  UIBoxModule.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIBoxModule: UserInterfacePositionableModule, UserInterfaceSizableModule
{
	private let frameColor: UIColorPair

	weak var userInterface: UserInterface?

	var width: Int32
	{
		didSet { needsRedraw = true }
	}

	var height: Int32
	{
		didSet { needsRedraw = true }
	}

	var clearsBackground: Bool = false
	{
		didSet { needsRedraw = true }
	}

	var frameChars: FrameChars = .singleLine
	{
		didSet { needsRedraw = true }
	}

	var title: String? = nil
	{
		didSet { needsRedraw = true }
	}

	var needsRedraw: Bool = true

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		width = 2
		height = 2

		frameColor = userInterface.sharedColorWhiteOnBlack
	}

	init(userInterface: UserInterface, size: UISize, frameColor color: UIColorPair)
	{
		self.userInterface = userInterface

		width = max(size.x, 2)
		height = max(size.y, 2)
		frameColor = color
	}

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		if shouldDraw(), let ui = self.userInterface
		{
			if clearsBackground
			{
				ui.cleanRegion(origin: point, size: UISize(width, height))
			}

			let maxWidth = ui.width - point.x
			let maxHeight = ui.height - point.y

			let startX: Int32
			let startY: Int32
			let lengthX: Int32
			let lengthY: Int32

			var didDraw = (left: false, right: false, top: false, bottom: false)

			if point.x >= 0
			{
				startX = point.x
				lengthX = min(maxWidth, width)
			}
			else
			{
				startX = 0
				lengthX = min(maxWidth, width) + point.x
			}

			if point.y >= 0
			{
				startY = point.y
				lengthY = min(maxHeight, height)
			}
			else
			{
				startY = 0
				lengthY = min(maxHeight, height) + point.y
			}

			if lengthX < 2 || lengthY < 2
			{
				// Not a meaningful draw
				return
			}

			// Draw left bar
			if point.x >= 0, let char = frameChars.vertical
			{
				for i in startY ..< startY + lengthY
				{
					ui.drawText(String(char),
					            at: UIPoint(point.x, i),
					            withColorPair: frameColor)
				}

				didDraw.left = true
			}

			// Draw top bar
			if point.y >= 0, let char = frameChars.horizontal
			{
				for i in startX ..< startX + lengthX
				{
					ui.drawText(String(char),
					            at: UIPoint(i, point.y),
					            withColorPair: frameColor)
				}

				if let title = self.title
				{
					let pX = (lengthX / 2) - ((title.width + 2) / 2)

					ui.drawText(" \(title) ", at: UIPoint(startX + pX, point.y), withColorPair: frameColor)
				}

				didDraw.top = true
			}

			// Draw right bar
			if point.x + lengthX <= ui.width, let char = frameChars.vertical
			{
				for i in startY ..< startY + lengthY
				{
					ui.drawText(String(char),
					            at: UIPoint(point.x + width - 1, i),
					            withColorPair: frameColor)
				}

				didDraw.right = true
			}

			// Draw bottom bar
			if point.y + lengthY <= ui.height, let char = frameChars.horizontal
			{
				for i in startX ..< startX + lengthX
				{
					ui.drawText(String(char),
					            at: UIPoint(i, point.y + height - 1),
					            withColorPair: frameColor)
				}

				didDraw.bottom = true
			}

			// Draw top-left corner
			if didDraw.top && didDraw.left, let char = frameChars.topLeft
			{
				ui.drawText(String(char),
				            at: UIPoint(startX, startY),
				            withColorPair: frameColor)
			}

			// Draw top-right corner
			if didDraw.top && didDraw.right, let char = frameChars.topRight
			{
				ui.drawText(String(char),
				            at: UIPoint(startX + lengthX - 1, startY),
				            withColorPair: frameColor)
			}

			// Draw bottom-left corner
			if didDraw.bottom && didDraw.left, let char = frameChars.bottomLeft
			{
				ui.drawText(String(char),
				            at: UIPoint(startX, startY + lengthY - 1),
				            withColorPair: frameColor)
			}

			// Draw bottom-right corner
			if didDraw.bottom && didDraw.right, let char = frameChars.bottomRight
			{
				ui.drawText(String(char),
				            at: UIPoint(startX + lengthX - 1, startY + lengthY - 1),
				            withColorPair: frameColor)
			}

			needsRedraw = false
		}
	}

	struct FrameChars
	{
		let topLeft, topRight, bottomLeft, bottomRight, horizontal, vertical: Character?

		static var singleLine = FrameChars(
			topLeft:		"┌",
			topRight:		"┐",
			bottomLeft:	"└",
			bottomRight:	"┘",
			horizontal:			"─",
			vertical:			"│"
		)

		static var doubleLine = FrameChars(
			topLeft:		"╔",
			topRight:		"╗",
			bottomLeft:	"╚",
			bottomRight:	"╝",
			horizontal:			"═",
			vertical:			"║"
		)
	}
}
