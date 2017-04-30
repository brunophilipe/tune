//
//  UIPlayQueueModule.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIPlayQueueModule: UserInterfacePositionableModule, UserInterfaceSizableModule
{
	private let textColor: UIColorPair
	private let listModule: UIListModule

	weak var userInterface: UserInterface? = nil
	var needsRedraw: Bool = true

	var currentPlaylist: iTunesPlaylist? = nil
	{
		didSet { needsRedraw = true }
	}
	
	var currentTrack: iTunesTrack? = nil
	{
		didSet
		{
			if let currentTrack = currentTrack, let row = currentPlaylist?.positionOfTrack(currentTrack)
			{
				listModule.selectedRow = row
			}
			else
			{
				listModule.selectedRow = nil
			}
			needsRedraw = true
		}
	}
	
	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		self.textColor = userInterface.sharedColorWhiteOnBlack
		self.listModule = UIListModule(userInterface: userInterface)
		
		self.width = 0
		self.height = 0
		
		self.listModule.dataSource = self
		self.listModule.selectedRow = 0
	}

	var width: Int32
	{
		didSet
		{
			listModule.width = width
			needsRedraw = true
		}
	}
	
	var height: Int32
	{
		didSet
		{
			listModule.height = height - 1
			needsRedraw = true
		}
	}

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		if shouldDraw(), let ui = self.userInterface
		{
			// Title background
			ui.usingTextAttributes(.standout)
			{
				ui.drawText(" " * width, at: point, withColorPair: textColor)
			}

			// Title
			let title = "\("Current Playlist".truncated(to: Int(width) - 2)):"
			ui.usingTextAttributes([.bold, .standout])
			{

				let pX = (width / 2) - (title.width / 2)
				ui.drawText(title, at: point.offset(x: pX), withColorPair: textColor)
			}

			if height > 1
			{
				listModule.draw(at: point.offset(y: 1))
			}

			needsRedraw = false
		}
	}
}

extension UIPlayQueueModule: UIListModuleDataSource
{
	func numberOfRowsForListModule(_ listModule: UIListModule) -> Int
	{
		return currentPlaylist?.tracks!().count ?? 0
	}
	
	func numberOfColumnsForListModule(_ listModule: UIListModule) -> Int
	{
		return 3
	}
	
	func listModule(_ listModule: UIListModule, widthOfColumn column: Int) -> Int
	{
		switch column
		{
		case 0: return Int("\(currentPlaylist?.tracks!().count ?? 1)".width)
		case 1: return Int(width) - 7 - Int("\(currentPlaylist?.tracks!().count ?? 1)".width)
		case 2: return 5
			
		default:
			return 1
		}
	}
	
	func listModule(_ listModule: UIListModule, titleForColumn column: Int) -> String
	{
		return ""
	}
	
	func listModule(_ listModule: UIListModule, textAlignmentForColumn column: Int) -> UIListModule.TextAlignment
	{
		switch column
		{
		case 0: return .right
		default: return .left
		}
	}
	
	func listModule(_ listModule: UIListModule, textForColumn column: Int, ofRow row: Int) -> String
	{
		if let playlist = self.currentPlaylist, let track = playlist.tracks!()[row] as? iTunesTrack
		{
			switch column
			{
			case 0: return "\(row+1)"
			case 1: return "\(track.name ?? kUnknownTrack)"
			case 2: return track.duration?.durationString ?? "--"
				
			default:
				return ""
			}
		}
		else
		{
			return ""
		}
	}
}
