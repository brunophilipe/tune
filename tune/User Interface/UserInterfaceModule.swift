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
	init(userInterface: UserInterface)

	func draw()
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
