//
//  UIDialog.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class UIDialog: UIWindow
{
	internal var panel: UnsafeMutablePointer<PANEL>? = nil

	override init(frame: UIFrame)
	{
		super.init(frame: frame)

		panel = new_panel(windowRef)
	}

	deinit
	{
		if let panel = self.panel
		{
			del_panel(panel)
			self.panel = nil
		}
	}

	override var frame: UIFrame
	{
		didSet
		{
			if let panel = self.panel
			{
				move_panel(panel, frame.y, frame.x)
				wresize(windowRef, frame.height, frame.width)
				replace_panel(panel, windowRef)
			}
			else
			{
				mvwin(windowRef, frame.y, frame.x)
				wresize(windowRef, frame.height, frame.width)
			}

			wclear(windowRef)

			container.frame = UIFrame(size: frame.size)
		}
	}

	var hidden: Bool
	{
		get
		{
			if let panel = self.panel
			{
				return panel_hidden(panel) != 0
			}
			else
			{
				return false
			}
		}

		set
		{
			if let panel = self.panel
			{
				if newValue
				{
					hide_panel(panel)
				}
				else
				{
					show_panel(panel)
				}
			}
		}
	}

	func pullToTop()
	{
		if let panel = self.panel
		{
			top_panel(panel)
		}
	}

	func pushToBottom()
	{
		if let panel = self.panel
		{
			bottom_panel(panel)
		}
	}

	override func draw()
	{
		if panel != nil
		{
			// We should not call wrefresh on windows that are also panels
			container.draw()
		}
		else
		{
			super.draw()
		}
	}
}
