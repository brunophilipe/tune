//
//  UIMainModule.swift
//  tune
//
//  Created by Bruno Philipe on 28/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIMainModule: UserInterfaceModule
{
	private let boxModuleMain: UIBoxModule
	private let boxModuleNowPlaying: UIBoxModule
	private let boxModulePlaylist: UIBoxModule
	private let controlBarModule: UIControlBarModule
	private let playQueueModule: UIPlayQueueModule
	private let searchModule: UISearchModule

	private let logoModule: UILogoModule
	private let nowPlayingModule: UINowPlayingModule

	private let subtitleColorPair: UIColorPair

	private let minLogoModuleWidth: Int32
	private let minNowPlayingWidth: Int32 = 40

	weak var userInterface: UserInterface?

	var currentTrack: iTunesTrack? = nil
	var currentPlaylist: iTunesPlaylist? = nil
	var currentPlaybackInfo: iTunesPlaybackInfo? = nil
	var currentState: UIState? = nil

	var needsRedraw: Bool = true

	private var isDrawing = false

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		boxModuleMain		= UIBoxModule(userInterface: userInterface)
		boxModuleNowPlaying	= UIBoxModule(userInterface: userInterface)
		boxModulePlaylist	= UIBoxModule(userInterface: userInterface)

		logoModule			= UILogoModule(userInterface: userInterface)
		nowPlayingModule	= UINowPlayingModule(userInterface: userInterface)
		controlBarModule	= UIControlBarModule(userInterface: userInterface)
		playQueueModule		= UIPlayQueueModule(userInterface: userInterface)
		searchModule		= UISearchModule(userInterface: userInterface)

		minLogoModuleWidth = logoModule.width + 6

		boxModuleMain.frameChars = .doubleLine

		boxModuleNowPlaying.frameChars = UIBoxModule.FrameChars(
			cornerTopLeft:		"╦",
			cornerTopRight:		"╗",
			cornerBottomLeft:	"╬",
			cornerBottomRight:	"╣",
			horizontal:			"═",
			vertical:			"║"
		)
		boxModuleNowPlaying.height = logoModule.height + 4

		boxModulePlaylist.frameChars = UIBoxModule.FrameChars(
			cornerTopLeft:		"╠",
			cornerTopRight:		"╬",
			cornerBottomLeft:	"╚",
			cornerBottomRight:	"╩",
			horizontal:			"═",
			vertical:			"║"
		)
		boxModulePlaylist.width = minLogoModuleWidth + 1

		subtitleColorPair = userInterface.sharedColorWhiteOnBlack
	}

	private func reframeBoxModules(_ ui: UserInterface)
	{
		boxModuleMain.width = ui.width
		boxModuleMain.height = ui.height - 1

		boxModuleNowPlaying.width = ui.width - minLogoModuleWidth
		boxModulePlaylist.height = ui.height - (logoModule.height + 3) - 1

		if ui.width <= 80
		{
			searchModule.width = max(ui.width - 2, 2)
		}
		else if ui.width >= 160
		{
			searchModule.width = 120
		}
		else
		{
			searchModule.width = Int32(Double(ui.width) * 0.75)
		}

		if ui.height <= 20
		{
			searchModule.height = max(ui.height - 2, 2)
		}
		else if ui.height >= 60
		{
			searchModule.height = 45
		}
		else
		{
			searchModule.height = Int32(Double(ui.height) * 0.75)
		}
	}

	func draw()
	{
		// shouldDraw() and needsRedraw are never used in this class. Maybe that's not ideal,
		// but we need to transfer the event to the submodules every loop.
		if let ui = self.userInterface, !isDrawing
		{
			isDrawing = true

			reframeBoxModules(ui)

			boxModuleMain.draw(at: UIPoint.zero)

			if ui.isCleanDraw
			{
				// never set it manually to false to avoid inconsistencies
				logoModule.needsRedraw = true
			}

			logoModule.draw(at: UIPoint(4, 2))

			let nowPlayingModuleOrigin = UIPoint(minLogoModuleWidth, 0)

			boxModuleNowPlaying.draw(at: nowPlayingModuleOrigin)
			nowPlayingModule.width = ui.width - (boxModulePlaylist.width + 1)
			nowPlayingModule.draw(at: nowPlayingModuleOrigin, forTrack: currentTrack, playbackInfo: currentPlaybackInfo)

			let playlistModuleOrigin = UIPoint(0, (logoModule.height + 3))

			boxModulePlaylist.draw(at: playlistModuleOrigin)

			controlBarModule.width = ui.width
			controlBarModule.currentState = currentState
			controlBarModule.draw(at: UIPoint(0, ui.height - 1))

			playQueueModule.width = logoModule.width + 5
			playQueueModule.height = ui.height - boxModuleNowPlaying.height - 2
			playQueueModule.currentPlaylist = currentPlaylist
			playQueueModule.currentTrack = currentTrack
			playQueueModule.draw(at: playlistModuleOrigin.offset(x: 1, y: 1))

			switch currentState?.identifier
			{
			case .some(UIState.TuneStates.search):
				let searchModuleOrigin = UIPoint(
					(ui.width / 2) - (searchModule.width / 2),
					(ui.height / 2) - (searchModule.height / 2)
				)
				searchModule.draw(at: searchModuleOrigin)

			default:
				break
			}

			ui.commit()

			isDrawing = false
		}
	}
}
