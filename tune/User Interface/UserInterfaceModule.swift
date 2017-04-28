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
