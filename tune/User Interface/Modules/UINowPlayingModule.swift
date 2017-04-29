//
//  UINowPlayingModule.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

let kUnknownArtist = "Unknown Artist"
let kUnknownTrack = "Unknown Track"
let kUnknownAlbum = "Unknown Album"

class UINowPlayingModule: UserInterfacePositionableModule, UserInterfaceSizableModule
{
	private weak var userInterface: UserInterface?
	private let labelTextAttributes: UserInterface.TextAttributes = [.underline]

	var textColor: UIColorPair

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
		self.width = 1
		self.textColor = userInterface.sharedColorWhiteOnBlack
	}

	var width: Int32
	var height: Int32
	{
		return 12
	}

	func draw()
	{
		draw(at: UIPoint.zero)
	}

	func draw(at point: UIPoint)
	{
		draw(at: point, forTrack: nil, playbackInfo: nil)
	}

	func draw(at point: UIPoint, forTrack track: iTunesTrack?, playbackInfo: iTunesPlaybackInfo?)
	{
		if let ui = self.userInterface
		{
			if !drawNormalTrackInfo(ui, at: point.offset(x: 1, y: 1), track: track, playbackInfo: playbackInfo)
			{
				_ = drawCompactTrackInfo(ui, at: point.offset(x: 1, y: 1), forTrack: track)
			}
		}
	}

	private func drawNormalTrackInfo(_ ui: UserInterface, at point: UIPoint, track: iTunesTrack?, playbackInfo: iTunesPlaybackInfo?) -> Bool
	{
		let truncationLength = Int(width - 16)

		if truncationLength > 16, let track = track
		{
			let info = processTrackInformation(track)

			// Title background
			ui.usingTextAttributes(.standout)
			{
				ui.drawText(" " * width, at: point, withColorPair: textColor)
			}

			// Title
			let title = "\("Current Track Information".truncated(to: Int(width) - 2)):"
			ui.usingTextAttributes([.bold, .standout])
			{

				let pX = (width / 2) - (title.width / 2)
				ui.drawText(title, at: point.offset(x: pX), withColorPair: textColor)
			}

			// Track information titles
			ui.usingTextAttributes(labelTextAttributes)
			{
				ui.drawText("title:",		at: point.offset(x: 3, y: 2),	withColorPair: textColor)
				ui.drawText("artist:",		at: point.offset(x: 2, y: 3),	withColorPair: textColor)
				ui.drawText("album:",		at: point.offset(x: 3, y: 4),	withColorPair: textColor)
			}

			// Track information
			ui.drawText(info.title.truncated(to: truncationLength),		at: point.offset(x: 10, y: 2), withColorPair: textColor)
			ui.drawText(info.artist.truncated(to: truncationLength),	at: point.offset(x: 10, y: 3), withColorPair: textColor)
			ui.drawText(info.album.truncated(to: truncationLength),		at: point.offset(x: 10, y: 4), withColorPair: textColor)

			// Separator
			ui.drawText("─" * (width - 2), at: UIPoint(point.x + 1, height - 5), withColorPair: textColor)

			// Track progress + duration bar
			let pY = height - 3
			let availableWidth = width - 4
			let lengthStr = info.duration
			let progressStr = (playbackInfo?.progress ?? 0.0).durationString

			ui.drawText(progressStr,
			            at: UIPoint(point.x + 2, pY),
			            withColorPair: textColor)
			ui.drawText(lengthStr,
			            at: UIPoint(point.x + 2 + availableWidth - lengthStr.width, pY),
			            withColorPair: textColor)

			let barLength = availableWidth - lengthStr.width - progressStr.width - 4
			var playedBarLength: Int32 = 0

			if let duration = track.duration, let progress = playbackInfo?.progress, progress > 0
			{
				playedBarLength = Int32(ceil(Double(barLength) * (progress / duration)))
			}

			if playedBarLength > 0
			{
				ui.drawText("▓" * playedBarLength, at: UIPoint(point.x + progressStr.width + 4, pY), withColorPair: textColor)
			}

			ui.drawText("░" * (barLength - playedBarLength),
			            at: UIPoint(point.x + progressStr.width + playedBarLength + 4, pY),
			            withColorPair: textColor)

			return true
		}

		return false
	}

	private func drawCompactTrackInfo(_ ui: UserInterface, at point: UIPoint, forTrack track: iTunesTrack?) -> Bool
	{
		let truncationLength = Int(width - 9)

		if truncationLength > 0, let track = track
		{
			let info = processTrackInformation(track)

			ui.drawText("t: \(info.title.truncated(to: truncationLength))",		at: point.offset(y: 2), withColorPair: textColor)
			ui.drawText("a: \(info.artist.truncated(to: truncationLength))",	at: point.offset(y: 3), withColorPair: textColor)
			ui.drawText("b: \(info.album.truncated(to: truncationLength))",		at: point.offset(y: 4), withColorPair: textColor)
			ui.drawText("b: \(info.duration.truncated(to: truncationLength))",  at: point.offset(y: 5), withColorPair: textColor)

			return true
		}

		return false
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

private extension String
{
	var width: Int32
	{
		return Int32(characters.count)
	}
}

private extension Double
{
	var durationString: String
	{
		let durMin = Int(self/60)
		let durSec = Int(self.truncatingRemainder(dividingBy: 60))
		return "\(durMin < 10 ? "0\(durMin)" : "\(durMin)"):" + "\(durSec < 10 ? "0\(durSec)" : "\(durSec)")"
	}
}
