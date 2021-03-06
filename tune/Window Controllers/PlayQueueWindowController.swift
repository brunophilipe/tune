//
//  PlayQueueWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

class PlayQueueWindowController: UIWindowController, DesiresTrackInfo, DesiresCurrentPlaylist
{
	internal weak var userInterface: UserInterface?

	private var windowStorage: UIWindow

	private var boxPanel: UIBoxPanel? = nil
	private var titlePanel: UICenteredTitlePanel? = nil
	private var listPanel: UIListPanel? = nil
	private var footerPanel: UICenteredTitlePanel? = nil

	private var oldTrack: MediaPlayerItem? = nil
	private var oldPlaylist: MediaPlayerPlaylist? = nil

	var window: UIWindow
	{
		return windowStorage
	}

	var track: MediaPlayerItem? = nil
	{
		didSet
		{
			if track != oldTrack
			{
				updateActiveItem()
				oldTrack = track
			}
		}
	}

	var currentPlaylist: MediaPlayerPlaylist? = nil
	{
		didSet
		{
			if currentPlaylist != oldPlaylist
			{
				updateActiveItem()
				updateFooterText()
				oldPlaylist = currentPlaylist
			}
		}
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
		self.windowStorage = UIDialog(frame: UIFrame(x: 0, y: 11, w: 40, h: userInterface.height - 12))
		self.windowStorage.controller = self

		window.frame = windowFrame

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = windowFrame

		boxPanel?.frame = boxPanelFrame
		titlePanel?.frame = titlePanelFrame
		listPanel?.frame = listPanelFrame
		footerPanel?.frame = footerPanelFrame
	}

	private func buildPanels()
	{
		if let ui = self.userInterface
		{
			let color = ui.sharedColorWhiteOnBlack

			let boxPanel = UIBoxPanel(frame: boxPanelFrame, frameColor: color)
			boxPanel.frameChars = UIBoxPanel.FrameChars.thickLine.replacing(topLeft: "┣", right: " ")

			window.container.addSubPanel(boxPanel)

			let titlePanel = UICenteredTitlePanel(frame: titlePanelFrame)
			titlePanel.title = "Current Playlist:"

			window.container.addSubPanel(titlePanel)

			let listPanel = UIListPanel(frame: listPanelFrame)
			listPanel.dataSource = self

			window.container.addSubPanel(listPanel)

			let footerPanel = UICenteredTitlePanel(frame: footerPanelFrame)
			footerPanel.title = ""
			footerPanel.bgAttributes = []
			footerPanel.attributes = []

			window.container.addSubPanel(footerPanel)

			self.boxPanel = boxPanel
			self.titlePanel = titlePanel
			self.listPanel = listPanel
			self.footerPanel = footerPanel
		}
	}

	private func updateActiveItem()
	{
		if let listPanel = self.listPanel
		{
			if let trackIndex = self.track?.index
			{
				// ScriptingBridge indexes start at 1
				listPanel.activeRow = trackIndex - 1
			}
			else
			{
				listPanel.activeRow = nil
			}
		}
	}

	private func updateFooterText()
	{
		if let playlist = self.currentPlaylist
		{
			let footerText: String
			let count = playlist.count

			if let duration = playlist.time
			{
				footerText = "\(count) tracks – \(Double(duration).longDurationString)"
			}
			else
			{
				footerText = "\(count) tracks"
			}

			footerPanel?.title = footerText
		}
		else
		{
			footerPanel?.title = ""
		}
	}

	private var windowFrame: UIFrame
	{
		if let ui = self.userInterface
		{
			if ui.width < 70
			{
				return UIFrame(x: 0, y: 13, w: 40, h: ui.height - 14)
			}
			else
			{
				return UIFrame(x: 0, y: 11, w: 40, h: ui.height - 12)
			}
		}
		else
		{
			return UIFrame(x: 0, y: 11, w: 40, h: 10)
		}
	}

	private var boxPanelFrame: UIFrame
	{
		return UIFrame(origin: .zero, size: window.frame.size)
	}

	private var titlePanelFrame: UIFrame
	{
		return UIFrame(origin: UIPoint(1, 1), size: window.frame.size.offset(x: -1).replacing(y: 1))
	}

	private var listPanelFrame: UIFrame
	{
		return UIFrame(origin: UIPoint(1, 2), size: window.frame.size.offset(x: -1, y: -4))
	}

	private var footerPanelFrame: UIFrame
	{
		return UIFrame(origin: window.frame.size.offset(y: -2).replacing(x: 1), size: window.frame.size.offset(x: -1).replacing(y: 1))
	}
}

extension PlayQueueWindowController: UIListPanelDataSource
{
	func numberOfRowsForListPanel(_ listPanel: UIListPanel) -> Int
	{
		return currentPlaylist?.count ?? 0
	}

	func numberOfColumnsForListPanel(_ listPanel: UIListPanel) -> Int
	{
		return 3
	}

	func listPanel(_ listPanel: UIListPanel, widthOfColumn column: Int) -> Int
	{
		switch column
		{
		case 0: return Int("\(currentPlaylist?.count ?? 1)".width)
		case 1: return Int(listPanel.frame.width) - 7 - Int("\(currentPlaylist?.count ?? 1)".width)
		case 2: return 5

		default:
			return 1
		}
	}

	func listPanel(_ listPanel: UIListPanel, textAlignmentForColumn column: Int) -> UIListPanel.TextAlignment
	{
		switch column
		{
		case 0: return .right
		default: return .left
		}
	}

	func listPanel(_ listPanel: UIListPanel, titleForColumn column: Int) -> String
	{
		return ""
	}

	func listPanel(_ listPanel: UIListPanel, textForColumn column: Int, ofRow row: Int) -> String
	{
		if let playlist = self.currentPlaylist, let track = playlist.item(at: row)
		{
			switch column
			{
			case 0: return "\(row+1)"
			case 1: return track.name
			case 2: return track.time?.durationString ?? "--:--"

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
