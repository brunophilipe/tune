//
//  UIMainModule.swift
//  tune
//
//  Created by Bruno Philipe on 28/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIMainModule: UserInterfaceModule
{
	private weak var userInterface: UserInterface?

	private let logoModule: UILogoModule
	private let mainFrameModule: UIBoxModule

	private let subtitleColorPair: UIColorPair

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		logoModule = UILogoModule(userInterface: userInterface)
		mainFrameModule = UIBoxModule(userInterface: userInterface)

		mainFrameModule.width = userInterface.width
		mainFrameModule.height = userInterface.height
		mainFrameModule.frameChars = .doubleLine

		subtitleColorPair = userInterface.sharedColorWhiteOnBlack
	}

	func draw()
	{
		if let ui = self.userInterface
		{
			ui.clean()

			mainFrameModule.draw(at: UIPoint.zero)
			logoModule.draw(at: UIPoint(3, 2))

			ui.drawText("Control iTunes from the Terminal", at: UIPoint(4, 9), withColorPair: subtitleColorPair)

			ui.commit()
		}
	}
}
