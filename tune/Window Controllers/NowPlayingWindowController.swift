//
//  NowPlayingWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
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

class NowPlayingWindowController: UIWindowController, DesiresTrackInfo, DesiresPlaybackInfo
{
	internal weak var userInterface: UserInterface?

	private var windowStorage: UIWindow

	private var boxPanel: UIBoxPanel? = nil
	private var titlePanel: UICenteredTitlePanel? = nil
	private var songInfoPanel: SongInfoPanel? = nil

	var window: UIWindow
	{
		return windowStorage
	}

	var track: MediaPlayerItem? = nil
	var playbackInfo: MediaPlayerPlaybackInfo? = nil

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
		self.windowStorage = UIDialog(frame: UIFrame(x: 40, y: 0, w: userInterface.width - 40, h: 11))

		self.windowStorage.controller = self

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = UIFrame(x: 40, y: 0, w: newSize.x - 40, h: 11)

		boxPanel?.frame = boxPanelFrame
		titlePanel?.frame = titlePanelFrame
		songInfoPanel?.frame = songInfoPanelFrame
	}

	private func buildPanels()
	{
		if let ui = self.userInterface
		{
			let color = ui.sharedColorWhiteOnBlack

			let boxPanel = UIBoxPanel(frame: boxPanelFrame, frameColor: color)
			boxPanel.frameChars = UIBoxPanel.FrameChars.thickLine.replacing(topLeft: "┳", bottom: " ")

			window.container.addSubPanel(boxPanel)

			let titlePanel = UICenteredTitlePanel(frame: titlePanelFrame)
			titlePanel.title = "Now Playing:"

			window.container.addSubPanel(titlePanel)

			let songInfoPanel = SongInfoPanel(frame: songInfoPanelFrame, textColor: color)

			window.container.addSubPanel(songInfoPanel)

			self.boxPanel = boxPanel
			self.titlePanel = titlePanel
			self.songInfoPanel = songInfoPanel
		}
	}

	private var boxPanelFrame: UIFrame
	{
		return UIFrame(origin: .zero, size: window.frame.size)
	}

	private var titlePanelFrame: UIFrame
	{
		return UIFrame(origin: UIPoint(1, 1), size: window.frame.size.offset(x: -2).replacing(y: 1))
	}

	private var songInfoPanelFrame: UIFrame
	{
		return UIFrame(origin: UIPoint(1, 2), size: window.frame.size.offset(x: -2, y: -2))
	}
}

private class SongInfoPanel: UIPanel
{
	private var oldTrack: MediaPlayerItem? = nil

	private var songNamePanel: UICenteredTitlePanel? = nil
	private var artistNamePanel: UICenteredTitlePanel? = nil
	private var albumNamePanel: UICenteredTitlePanel? = nil

	var textColor: UIColorPair

	override var frame: UIFrame
	{
		didSet
		{
			resizeSongInfoPanels()
		}
	}

	override var window: UIWindow?
	{
		didSet
		{
			if songNamePanel == nil
			{
				initializeSongInfoPanels()
			}
		}
	}

	init(frame: UIFrame, textColor: UIColorPair)
	{
		self.textColor = textColor

		super.init(frame: frame)
	}

	override func draw()
	{
		if let window = self.window, let controller = (window.controller as? NowPlayingWindowController)
		{
			let track = controller.track
			let playbackInfo = controller.playbackInfo
			let maxLength = Int(frame.width - 3)

			// Clean if the track changed
			if track != oldTrack
			{
				window.cleanRegion(frame: frame)

				oldTrack = track
			}

			if maxLength > 7, let track = track
			{
				let info = processTrackInformation(track)

				songNamePanel?.title = info.title.truncated(to: maxLength)
				artistNamePanel?.title = info.artist.truncated(to: maxLength)
				albumNamePanel?.title = info.album.truncated(to: maxLength)

				// Separator
				window.drawText("─" * (frame.width - 2), at: UIPoint(frame.origin.x + 1, frame.height - 2), withColorPair: textColor)

				// Track progress + duration bar
				let pY = frame.height
				let availableWidth = frame.width - 4
				let lengthStr = info.duration
				let progressStr = (playbackInfo?.progress ?? 0.0).durationString

				window.drawText(progressStr, at: UIPoint(frame.origin.x + 2, pY), withColorPair: textColor)
				window.drawText(lengthStr, at: UIPoint(frame.origin.x + 2 + availableWidth - lengthStr.width, pY), withColorPair: textColor)

				let barLength = availableWidth - lengthStr.width - progressStr.width - 4
				var playedBarLength: Int32 = 0

				if let duration = track.time, let progress = playbackInfo?.progress, progress > 0
				{
					playedBarLength = Int32(ceil(Double(barLength) * (progress / duration)))
				}

				if playedBarLength > 0
				{
					window.drawText("▓" * playedBarLength,
					                at: UIPoint(frame.origin.x + progressStr.width + 4, pY),
					                withColorPair: textColor)
				}

				window.drawText("░" * (barLength - playedBarLength),
				                at: UIPoint(frame.origin.x + progressStr.width + playedBarLength + 4, pY),
				                withColorPair: textColor)
				
			}
			else
			{
				songNamePanel?.title = "Nothing..."
				artistNamePanel?.title = nil
				albumNamePanel?.title = "press s to search for music"
			}
		}

		super.draw()
	}

	private func initializeSongInfoPanels()
	{
		if let textColor = window?.controller?.userInterface?.registerColorPair(fore: COLOR_BLACK, back: COLOR_WHITE)
		{
			let attributes: UITextAttributes = [.reverse]

			songNamePanel	= UICenteredTitlePanel(frame: songNamePanelFrame)
			songNamePanel?.attributes = attributes
			songNamePanel?.textColor = textColor
			addSubPanel(songNamePanel!)

			artistNamePanel = UICenteredTitlePanel(frame: artistNamePanelFrame)
			artistNamePanel?.attributes = attributes
			artistNamePanel?.textColor = textColor
			addSubPanel(artistNamePanel!)

			albumNamePanel	= UICenteredTitlePanel(frame: albumNamePanelFrame)
			albumNamePanel?.attributes = attributes
			albumNamePanel?.textColor = textColor
			addSubPanel(albumNamePanel!)
		}
	}

	private var songNamePanelFrame: UIFrame
	{
		return UIFrame(origin: UIPoint(1, 3), size: UISize(frame.width, 1))
	}

	private var artistNamePanelFrame: UIFrame
	{
		return UIFrame(origin: UIPoint(1, 4), size: UISize(frame.width, 1))
	}

	private var albumNamePanelFrame: UIFrame
	{
		return UIFrame(origin: UIPoint(1, 5), size: UISize(frame.width, 1))
	}

	private func resizeSongInfoPanels()
	{
		songNamePanel?.frame	= songNamePanelFrame
		artistNamePanel?.frame	= artistNamePanelFrame
		albumNamePanel?.frame	= albumNamePanelFrame
	}

	private func processTrackInformation(_ track: MediaPlayerItem) -> ProcessedTrackInfo
	{
		var album = track.album

		if let year = track.year
		{
			album += " (\(year))"
		}

		return ProcessedTrackInfo(title: track.name, artist: track.artist, album: album, duration: track.time?.durationString ?? "--:--")
	}

	private struct ProcessedTrackInfo
	{
		let title, artist, album, duration: String
	}
}
