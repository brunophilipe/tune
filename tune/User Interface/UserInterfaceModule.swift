//
//  UserInterfaceModule.swift
//  tune
//
//  Created by Bruno Philipe on 28/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation
import Darwin.ncurses

protocol UserInterfaceModule
{
	weak var userInterface: UserInterface? { get }

	init(userInterface: UserInterface)

	func draw()

	var needsRedraw: Bool { get set }
}

protocol UserInterfacePositionableModule: UserInterfaceModule
{
	func draw(at: UIPoint)
}

protocol UserInterfaceSizableModule: UserInterfaceModule
{
	var width: Int32 { get }
	var height: Int32 { get }
}

extension UserInterfaceModule
{
	func shouldDraw() -> Bool
	{
		return needsRedraw || (userInterface?.isCleanDraw ?? false)
	}
}
