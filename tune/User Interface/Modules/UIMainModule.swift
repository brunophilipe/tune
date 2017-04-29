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
	private weak var userInterface: UserInterface?

	private let boxModuleMain: UIBoxModule
	private let boxModuleNowPlaying: UIBoxModule

	private let logoModule: UILogoModule
	private let nowPlayingModule: UINowPlayingModule

	private let subtitleColorPair: UIColorPair

	private let minLogoModuleWidth: Int32
	private let minNowPlayingWidth: Int32 = 40

	var currentTrack: iTunesTrack? = nil

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		logoModule = UILogoModule(userInterface: userInterface)
		boxModuleMain = UIBoxModule(userInterface: userInterface)
		boxModuleNowPlaying = UIBoxModule(userInterface: userInterface)
		nowPlayingModule = UINowPlayingModule(userInterface: userInterface)

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

		subtitleColorPair = userInterface.sharedColorWhiteOnBlack
	}

	private func reframeBoxModules(_ ui: UserInterface)
	{
		boxModuleMain.width = ui.width
		boxModuleMain.height = ui.height

		boxModuleNowPlaying.width = ui.width - minLogoModuleWidth
	}

	func draw()
	{
		if let ui = self.userInterface
		{
			reframeBoxModules(ui)

			ui.clean()

			boxModuleMain.draw(at: UIPoint.zero)
			logoModule.draw(at: UIPoint(3, 2))

			let nowPlayingModuleOrigin = UIPoint(minLogoModuleWidth, 0)

			boxModuleNowPlaying.draw(at: nowPlayingModuleOrigin)
			nowPlayingModule.width = ui.width - minLogoModuleWidth
			nowPlayingModule.draw(at: nowPlayingModuleOrigin, forTrack: currentTrack)

			ui.commit()
		}
	}
}
