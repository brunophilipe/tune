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

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		logoModule = UILogoModule(userInterface: userInterface)
	}

	func draw()
	{
		logoModule.draw()
	}
}
