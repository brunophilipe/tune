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

	private let logoModule: UILogoModule
	private let nowPlayingModule: UINowPlayingModule

	private let subtitleColorPair: UIColorPair

	private let minLogoModuleWidth: Int32
	private let minNowPlayingWidth: Int32 = 40

	weak var userInterface: UserInterface?

	var currentTrack: iTunesTrack? = nil
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
	}

	func draw()
	{
		if let ui = self.userInterface, !isDrawing
		{
			isDrawing = true

			reframeBoxModules(ui)

			boxModuleMain.draw(at: UIPoint.zero)
			logoModule.draw(at: UIPoint(4, 2))

			let nowPlayingModuleOrigin = UIPoint(minLogoModuleWidth, 0)

			boxModuleNowPlaying.draw(at: nowPlayingModuleOrigin)
			nowPlayingModule.width = ui.width - (boxModulePlaylist.width + 1)
			nowPlayingModule.draw(at: nowPlayingModuleOrigin, forTrack: currentTrack, playbackInfo: currentPlaybackInfo)

			let playlistModuleOrigin = UIPoint(0, (logoModule.height + 3))

			boxModulePlaylist.draw(at: playlistModuleOrigin)

			controlBarModule.currentState = currentState
			controlBarModule.draw(at: UIPoint(0, ui.height - 1))

			playQueueModule.width = logoModule.width + 5
			playQueueModule.height = ui.height - boxModuleNowPlaying.height - 2
			playQueueModule.draw(at: playlistModuleOrigin.offset(x: 1, y: 1))

			ui.commit()

			isDrawing = false
		}
	}
}
