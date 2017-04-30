//
//  UIPanel.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIPanel
{
	internal weak var window: UIWindow?

	var frame: UIFrame
	var needsRedraw: Bool

	internal var subpanels = [UIPanel]()

	init(frame: UIFrame)
	{
		self.frame = frame
		self.needsRedraw = true
	}

	func draw()
	{
		for subpanel in subpanels
		{
			subpanel.draw()
		}
	}

	func addSubPanel(_ panel: UIPanel)
	{
		subpanels.append(panel)

		panel.window = window
	}
}
