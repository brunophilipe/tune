//
//  UISearchModule.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UISearchModule: UserInterfacePositionableModule, UserInterfaceSizableModule
{
	private let boxModule: UIBoxModule
	private let textInputModule: UITextInputModule

	weak var userInterface: UserInterface? = nil

	var width: Int32
	{
		didSet
		{
			boxModule.width = width
			textInputModule.width = width - 2
			needsRedraw = true
		}
	}

	var height: Int32
	{
		didSet
		{
			boxModule.height = height
			needsRedraw = true
		}
	}

	var needsRedraw: Bool = true

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		width = 2
		height = 2

		boxModule = UIBoxModule(userInterface: userInterface,
		                        size: UISize(width, height),
		                        frameColor: userInterface.sharedColorWhiteOnBlack)

		boxModule.clearsBackground = true
		boxModule.title = "Search"

		textInputModule = UITextInputModule(userInterface: userInterface)
		textInputModule.prompt = "⌕"
	}

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		if shouldDraw()
		{
			boxModule.draw(at: point)

			// Search text field
			textInputModule.draw(at: point.offset(x: 1, y: 1))

			needsRedraw = false
		}
	}
}
