//
//  PlayQueueWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class PlayQueueWindowController: UIWindowController, DesiresTrackInfo, DesiresCurrentPlaylist
{
	internal weak var userInterface: UserInterface?

	private var windowStorage: UIWindow

	private var boxPanel: UIBoxPanel? = nil
	private var titlePanel: UICenteredTitlePanel? = nil
	private var listPanel: UIListPanel? = nil

	private var oldTrackId: Int? = nil
	private var oldPlaylistId: Int? = nil

	var window: UIWindow
	{
		return windowStorage
	}

	var track: iTunesTrack? = nil
	{
		didSet
		{
			if track?.id!() != oldTrackId
			{
				updateActiveItem()
				oldTrackId = track?.id!()
			}
		}
	}

	var currentPlaylist: iTunesPlaylist? = nil
	{
		didSet
		{
			if currentPlaylist?.id!() != oldPlaylistId
			{
				updateActiveItem()
				oldPlaylistId = currentPlaylist?.id!()
			}
		}
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
		self.windowStorage = UIWindow(frame: UIFrame(x: 0, y: 11, w: 40, h: userInterface.height - 12))
		self.windowStorage.controller = self

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = UIFrame(x: 0, y: 11, w: 40, h: newSize.y - 12)

		boxPanel?.frame = UIFrame(origin: .zero, size: window.frame.size)
		listPanel?.frame = listPanelFrame
	}

	private func buildPanels()
	{
		if let ui = self.userInterface
		{
			let color = ui.sharedColorWhiteOnBlack

			let boxPanel = UIBoxPanel(frame: boxPanelFrame, frameColor: color)
			boxPanel.frameChars = UIBoxPanel.FrameChars.doubleLine.replacing(
				topLeft: "╠",
				right: " "
			)

			window.container.addSubPanel(boxPanel)

			let titlePanel = UICenteredTitlePanel(frame: titlePanelFrame)
			titlePanel.title = "Current Playlist:"

			window.container.addSubPanel(titlePanel)

			let listPanel = UIListPanel(frame: listPanelFrame)
			listPanel.dataSource = self

			window.container.addSubPanel(listPanel)

			self.boxPanel = boxPanel
			self.titlePanel = titlePanel
			self.listPanel = listPanel
		}
	}

	private func updateActiveItem()
	{
		if let listPanel = self.listPanel
		{
			if let track = self.track, let row = currentPlaylist?.positionOfTrack(track)
			{
				listPanel.activeRow = row
			}
			else
			{
				listPanel.activeRow = nil
			}
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
		return UIFrame(origin: UIPoint(1, 2), size: window.frame.size.offset(x: -1, y: -3))
	}
}

extension PlayQueueWindowController: UIListPanelDataSource
{
	func numberOfRowsForListPanel(_ listPanel: UIListPanel) -> Int
	{
		return currentPlaylist?.tracks!().count ?? 0
	}

	func numberOfColumnsForListPanel(_ listPanel: UIListPanel) -> Int
	{
		return 3
	}

	func listPanel(_ listPanel: UIListPanel, widthOfColumn column: Int) -> Int
	{
		switch column
		{
		case 0: return Int("\(currentPlaylist?.tracks!().count ?? 1)".width)
		case 1: return Int(listPanel.frame.width) - 7 - Int("\(currentPlaylist?.tracks!().count ?? 1)".width)
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
