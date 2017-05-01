//
//  SearchWindowController.swift
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

class SearchWindowController: UIWindowController, DesiresCurrentState
{
	internal weak var userInterface: UserInterface?

	private var dialog: UIDialog
	private var boxPanel: UIBoxPanel? = nil
	private var titlePanel: UITextPromptPanel? = nil
	private var listPanel: UIListPanel? = nil

	fileprivate var lastSearchResult: SearchResult? = nil
	{
		didSet
		{
			updateTitlePanel()
		}
	}

	private let searchStates: [Int] = [
		UIState.TuneStates.search, UIState.TuneStates.searchTracks, UIState.TuneStates.searchAlbums, UIState.TuneStates.searchPlaylists
	]

	var window: UIWindow
	{
		return dialog
	}

	var currentState: UIState?
	{
		didSet
		{
			if currentState != oldValue
			{
				if let id = currentState?.identifier, searchStates.contains(id)
				{
					dialog.hidden = false
					dialog.pullToTop()

					updateTitlePanel()
				}
				else
				{
					dialog.hidden = true
					lastSearchResult = nil
				}
			}
		}
	}

	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface

		self.dialog = UIDialog(frame: UIFrame(x: 0, y: 0, w: 10, h: 10))
		self.dialog.controller = self

		dialog.frame = windowFrame

		buildPanels()
	}

	func availableSizeChanged(newSize: UISize)
	{
		window.frame = windowFrame

		boxPanel?.frame = boxPanelFrame
		listPanel?.frame = listPanelFrame
	}

	private func buildPanels()
	{
		if let color = userInterface?.sharedColorWhiteOnBlack
		{
			let boxPanel = UIBoxPanel(frame: boxPanelFrame, frameColor: color)
			boxPanel.frameChars = UIBoxPanel.FrameChars.doubleLine
			boxPanel.clearsBackground = true
			boxPanel.title = "Search"

			window.container.addSubPanel(boxPanel)

			let titlePanel = UITextPromptPanel(frame: titlePanelFrame)
			titlePanel.prompt = "Select search mode (see below)"

			window.container.addSubPanel(titlePanel)

			let listPanel = UIListPanel(frame: listPanelFrame)
			listPanel.dataSource = self

			window.container.addSubPanel(listPanel)

			self.boxPanel = boxPanel
			self.titlePanel = titlePanel
			self.listPanel = listPanel
		}
	}

	private func updateTitlePanel()
	{
		var prompt: String
		var text: String? = nil

		switch self.currentState?.identifier
		{
		case .some(UIState.TuneStates.searchTracks):
			prompt = "searching (tracks):"
			text = lastSearchResult?.query

		case .some(UIState.TuneStates.searchAlbums):
			prompt = "searching (albums):"
			text = lastSearchResult?.query

		case .some(UIState.TuneStates.searchPlaylists):
			prompt = "searching (playlists):"
			text = lastSearchResult?.query

		default:
			if lastSearchResult != nil
			{
				prompt = "Search results:"
				text = lastSearchResult?.query
			}
			else
			{
				prompt = "Select search mode (see below)"
			}
		}

		titlePanel?.prompt = prompt
		titlePanel?.text = text
	}

	private var windowFrame: UIFrame
	{
		if let ui = self.userInterface
		{
			var size = UISize(0, 0)

			if ui.width <= 80
			{
				size.x = max(ui.width - 4, 2)
			}
			else if ui.width >= 160
			{
				size.x = 120
			}
			else
			{
				size.x = Int32(Double(ui.width) * 0.75)
			}

			if ui.height <= 20
			{
				size.y = max(ui.height - 4, 2)
			}
			else if ui.height >= 60
			{
				size.y = 45
			}
			else
			{
				size.y = Int32(Double(ui.height) * 0.75)
			}

			let origin = UIPoint((ui.width / 2) - (size.x / 2), (ui.height / 2) - (size.y / 2))

			return UIFrame(origin: origin, size: size)
		}
		else
		{
			return UIFrame(x: 0, y: 0, w: 10, h: 10)
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

	private var listPanelFrame: UIFrame
	{
		return UIFrame(origin: UIPoint(1, 2), size: window.frame.size.offset(x: -2, y: -3))
	}
}

extension SearchWindowController: SearchEngineDelegate
{
	func searchEngine(_ searchEngine: SearchEngine, gotSearchResult result: SearchResult)
	{
		lastSearchResult = result
	}

	func searchEngine(_ searchEngine: SearchEngine, getErrorForSearchWithQuery text: String)
	{

	}
}

extension SearchWindowController: UIListPanelDataSource
{
	func numberOfRowsForListPanel(_ listPanel: UIListPanel) -> Int
	{
		return lastSearchResult?.resultItems.count ?? 0
	}

	func numberOfColumnsForListPanel(_ listPanel: UIListPanel) -> Int
	{
		return 4
	}

	func listPanel(_ listPanel: UIListPanel, widthOfColumn column: Int) -> Int
	{
		let resultCount = lastSearchResult?.resultItems.count ?? 0
		let majorColWidth = Double(Int(listPanel.frame.width) - 8 - Int("\(resultCount)".width)) / 2.0

		switch column
		{
		case 0: return Int("\(resultCount)".width)
		case 1: return Int(ceil(majorColWidth))
		case 2: return Int(floor(majorColWidth))
		case 3: return 5

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
		if let item = lastSearchResult?.resultItems[row]
		{
			switch column
			{
			case 0: return String(row + 1)
			case 1: return item.name
			case 2: return item.artist
			case 3: return item.time

			default: return ""
			}
		}

		return ""
	}
}
