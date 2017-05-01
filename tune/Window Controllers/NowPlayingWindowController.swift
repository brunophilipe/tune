//
//  NowPlayingWindowController.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class NowPlayingWindowController: UIWindowController, DesiresTrackInfo, DesiresPlaybackInfo
{
	internal weak var userInterface: UserInterface?

	private var windowStorage: UIWindow

	private var boxPanel: UIBoxPanel? = nil
	private var songInfoPanel: SongInfoPanel? = nil

	var window: UIWindow
	{
		return windowStorage
	}

	var track: iTunesTrack? = nil
	var playbackInfo: iTunesPlaybackInfo? = nil

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
		self.windowStorage = UIWindow(frame: UIFrame(x: 40, y: 0, w: userInterface.width - 40, h: 11))

		self.windowStorage.controller = self

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = UIFrame(x: 40, y: 0, w: newSize.x - 40, h: 11)

		boxPanel?.frame = UIFrame(origin: .zero, size: window.frame.size)
		songInfoPanel?.frame = UIFrame(origin: UIPoint(1, 1), size: window.frame.size.offset(x: -2, y: -1))
	}

	private func buildPanels()
	{
		if let ui = self.userInterface
		{
			let color = ui.sharedColorWhiteOnBlack

			let boxPanel = UIBoxPanel(frame: UIFrame(origin: .zero, size: window.frame.size), frameColor: color)
			boxPanel.frameChars = UIBoxPanel.FrameChars.doubleLine.replacing(
				topLeft: "╦",
				bottom: " "
			)

			window.container.addSubPanel(boxPanel)

			let songInfoPanel = SongInfoPanel(frame: UIFrame(origin: UIPoint(1, 1), size: window.frame.size.offset(x: -2, y: -1)),
			                                  textColor: color)

			window.container.addSubPanel(songInfoPanel)

			self.boxPanel = boxPanel
			self.songInfoPanel = songInfoPanel
		}
	}
}

private class SongInfoPanel: UIPanel
{
	private var lastTrackId: Int? = nil

	var textColor: UIColorPair

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
			let maxLength = Int(frame.width - 11)

			// Clean if the track changed
			if track?.id!() != lastTrackId
			{
				window.cleanRegion(frame: frame)

				lastTrackId = track?.id!()
			}

			if maxLength > 11, let track = track
			{
				let info = processTrackInformation(track)
				let availableTitleWidth = frame.width - 1

				// Title background
				window.usingTextAttributes(.standout)
				{
					window.drawText(" " * frame.width, at: frame.origin, withColorPair: textColor)
				}

				// Title
				let title = "\("Current Track Information".truncated(to: Int(availableTitleWidth))):"
				window.usingTextAttributes([.bold, .standout])
				{
					let pX = max((availableTitleWidth / 2) - (title.width / 2), 1)
					window.drawText(title, at: frame.origin.replacing(x: pX), withColorPair: textColor)
				}

				// Track information titles
				window.usingTextAttributes(.underline)
				{
					window.drawText("title:",	at: frame.origin.offset(x: 3, y: 2),	withColorPair: textColor)
					window.drawText("artist:",	at: frame.origin.offset(x: 2, y: 3),	withColorPair: textColor)
					window.drawText("album:",	at: frame.origin.offset(x: 3, y: 4),	withColorPair: textColor)
				}

				// Track information
				window.drawText(info.title.truncated(to: maxLength),	at: frame.origin.offset(x: 10, y: 2), withColorPair: textColor)
				window.drawText(info.artist.truncated(to: maxLength),	at: frame.origin.offset(x: 10, y: 3), withColorPair: textColor)
				window.drawText(info.album.truncated(to: maxLength),	at: frame.origin.offset(x: 10, y: 4), withColorPair: textColor)

				// Separator
				window.drawText("─" * (frame.width - 2), at: UIPoint(frame.origin.x + 1, frame.height - 3), withColorPair: textColor)

				// Track progress + duration bar
				let pY = frame.height - 1
				let availableWidth = frame.width - 4
				let lengthStr = info.duration
				let progressStr = (playbackInfo?.progress ?? 0.0).durationString

				window.drawText(progressStr,
				            at: UIPoint(frame.origin.x + 2, pY),
				            withColorPair: textColor)
				window.drawText(lengthStr,
				            at: UIPoint(frame.origin.x + 2 + availableWidth - lengthStr.width, pY),
				            withColorPair: textColor)

				let barLength = availableWidth - lengthStr.width - progressStr.width - 4
				var playedBarLength: Int32 = 0

				if let duration = track.duration, let progress = playbackInfo?.progress, progress > 0
				{
					playedBarLength = Int32(ceil(Double(barLength) * (progress / duration)))
				}

				if playedBarLength > 0
				{
					window.drawText("▓" * playedBarLength, at: UIPoint(frame.origin.x + progressStr.width + 4, pY), withColorPair: textColor)
				}

				window.drawText("░" * (barLength - playedBarLength),
				            at: UIPoint(frame.origin.x + progressStr.width + playedBarLength + 4, pY),
				            withColorPair: textColor)
				
			}
		}
	}

	private func processTrackInformation(_ track: iTunesTrack) -> ProcessedTrackInfo
	{
		var artist = track.artist
		var title = track.name
		var album = track.album

		if artist == nil || artist?.characters.count == 0
		{
			artist = kUnknownArtist
		}

		if title == nil || title?.characters.count == 0
		{
			title = kUnknownTrack
		}

		let year: String?

		if let y = track.year, y > 0
		{
			year = "\(y)"
		}
		else
		{
			year = nil
		}

		if album == nil || album?.characters.count == 0
		{
			album = kUnknownAlbum
		}
		else if album != nil, let year = year
		{
			album! += " (\(year))"
		}

		let durString = (track.duration ?? 0.0).durationString

		return ProcessedTrackInfo(title: title!, artist: artist!, album: album!, duration: durString)
	}

	private struct ProcessedTrackInfo
	{
		let title, artist, album, duration: String
	}
}
