//
//  UIWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

protocol UIWindowController: class
{
	var window: UIWindow { get }
	var userInterface: UserInterface? { get }

	init(userInterface: UserInterface)

	func availableSizeChanged(newSize: UISize)
}
