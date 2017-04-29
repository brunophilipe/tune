//
//  UINowPlayingModule.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UINowPlayingModule: UserInterfacePositionableModule, UserInterfaceSizableModule
{
	private weak var userInterface: UserInterface?
	private let titleTextAttributes: UserInterface.TextAttributes = [.bold]
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
		draw(at: point, forTrack: nil)
	}

	func draw(at point: UIPoint, forTrack track: iTunesTrack?)
	{
		if let ui = self.userInterface
		{
			if !drawNormalTrackInfo(ui, at: point.offset(x: 3, y: 2), forTrack: track)
			{
				_ = drawCompactTrackInfo(ui, at: point.offset(x: 3, y: 2), forTrack: track)
			}
		}
	}

	private func drawNormalTrackInfo(_ ui: UserInterface, at point: UIPoint, forTrack track: iTunesTrack?) -> Bool
	{
		let truncationLength = Int(width - 16)

		if truncationLength > 16, let track = track
		{
			let info = processTrackInformation(track)

			let title = "\("Current Track Information".truncated(to: Int(width) - 7)):"
			ui.usingTextAttributes(titleTextAttributes)
			{
				ui.drawText(title, at: point, withColorPair: textColor)
			}

			ui.usingTextAttributes(labelTextAttributes)
			{
				ui.drawText("title:",  at: point.offset(x: 3, y: 2), withColorPair: textColor)
				ui.drawText("artist:", at: point.offset(x: 2, y: 3), withColorPair: textColor)
				ui.drawText("album:",  at: point.offset(x: 3, y: 4), withColorPair: textColor)
				ui.drawText("duration:",  at: point.offset(y: 5),	 withColorPair: textColor)
			}

			ui.drawText(info.title.truncated(to: truncationLength),		at: point.offset(x: 10, y: 2), withColorPair: textColor)
			ui.drawText(info.artist.truncated(to: truncationLength),	at: point.offset(x: 10, y: 3), withColorPair: textColor)
			ui.drawText(info.album.truncated(to: truncationLength),		at: point.offset(x: 10, y: 4), withColorPair: textColor)
			ui.drawText(info.duration.truncated(to: truncationLength),  at: point.offset(x: 10, y: 5), withColorPair: textColor)

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

		let duration = track.duration ?? 0.0
		let durMin = Int(duration/60)
		let durSec = Int(duration.truncatingRemainder(dividingBy: 60))
		let durString = "\(durMin < 10 ? "0\(durMin)" : "\(durMin)"):" + "\(durSec < 10 ? "0\(durSec)" : "\(durSec)")"

		return ProcessedTrackInfo(title: title!, artist: artist!, album: album!, duration: durString)
	}

	private struct ProcessedTrackInfo
	{
		let title, artist, album, duration: String
	}
}
