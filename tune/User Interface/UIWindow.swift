//
//  UIWindow.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation
import Darwin.ncurses

private var temp = UInt32(0)

class UIWindow
{
	internal let windowRef: OpaquePointer

	var controller: UIWindowController? = nil

	var frame: UIFrame
	{
		didSet
		{
			mvwin(windowRef, frame.y, frame.x)
			wresize(windowRef, frame.height, frame.width)

			wclear(windowRef)

			container.frame = UIFrame(size: frame.size)
		}
	}

	let container: UIPanel

	init(frame: UIFrame)
	{
		self.frame = frame

		windowRef = newwin(frame.height, frame.width, frame.y, frame.x)

		container = UIPanel(frame: UIFrame(size: frame.size))
		container.window = self
	}

	deinit
	{
		delwin(windowRef)
		controller = nil
	}

	func draw()
	{
		container.draw()
		wrefresh(windowRef)
	}
}

extension UIWindow
{
	private func enableColorPair(_ pair: UIColorPair)
	{
		wattron(windowRef, COLOR_PAIR(Int32(pair)))
	}

	private func disableColorPair(_ pair: UIColorPair)
	{
		wattroff(windowRef, COLOR_PAIR(Int32(pair)))
	}

	private func enableTextAttributes(_ attributes: UITextAttributes)
	{
		wattron(windowRef, attributes.rawValue)
	}

	private func disableTextAttributes(_ attributes: UITextAttributes)
	{
		wattroff(windowRef, attributes.rawValue)
	}

	func cleanRegion(frame: UIFrame, usingColorPair color: UIColorPair = 0)
	{
		cleanRegion(origin: frame.origin, size: frame.size)
	}

	func cleanRegion(origin: UIPoint, size: UISize, usingColorPair color: UIColorPair = 0)
	{
		let fillColor: UIColorPair

		if color > 0
		{
			fillColor = color
		}
		else
		{
			guard let color = controller?.userInterface?.sharedColorWhiteOnBlack else
			{
				return
			}

			fillColor = color
		}

		for row in 0 ..< size.y
		{
			drawText(" " * size.x, at: origin.offset(y: row), withColorPair: fillColor)
		}
	}

	/// Will apply the parameter attributes to all text drawn inside the parameter block. The block runs immediatelly and is non-escaping.
	///
	/// **WARNING:** This function does not (yet) support nesting. Don't call `usingTextAttributes` inside of the parameter block.
	func usingTextAttributes(_ attributes: UITextAttributes, _ block: () -> Void)
	{
		enableTextAttributes(attributes)
		block()
		disableTextAttributes(attributes)
	}

	func drawText(_ text: String, at point: UIPoint, withColorPair colorPair: UIColorPair)
	{
		enableColorPair(colorPair)
		wmove(windowRef, point.y, point.x)
		waddstr(windowRef, text)
		disableColorPair(colorPair)
	}
}
