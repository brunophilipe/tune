//
//  UIListPanel.swift
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

class UIListPanel: UIPanel
{
	weak var dataSource: UIListPanelDataSource? = nil
	{
		didSet { needsRedraw = true }
	}

	var activeRow: Int? = nil
	{
		didSet { needsRedraw = true }
	}

	var activeRowTextColor: UIColorPair? = nil
	{
		didSet { needsRedraw = true }
	}

	private var lastMinRow: Int = 0

	override var window: UIWindow?
	{
		didSet
		{
			activeRowTextColor = window?.controller?.userInterface?.registerColorPair(fore: COLOR_CYAN, back: COLOR_BLACK)
			needsRedraw = true
		}
	}

	override func draw()
	{
		if needsRedraw,
			let window = self.window,
			let dataSource = self.dataSource,
			let activeColor = self.activeRowTextColor,
			let normalColor = window.controller?.userInterface?.sharedColorWhiteOnBlack
		{
			window.cleanRegion(frame: frame)

			let columnCount = dataSource.numberOfColumnsForListPanel(self)
			let rowCount = dataSource.numberOfRowsForListPanel(self)

			if rowCount == 0 || columnCount == 0
			{
				needsRedraw = false
				return
			}

			let point = frame.origin

			let columnWidths: [Int] = (0 ..< columnCount).map({dataSource.listPanel(self, widthOfColumn: $0)})

			let maxRow = min(rowCount, Int(frame.height))

			if let activeRow = self.activeRow
			{
				if frame.height < 3
				{
					lastMinRow = activeRow
				}
				else if frame.height < 5
				{
					lastMinRow = activeRow - 1
				}
				else if activeRow > (lastMinRow + maxRow) - 3
				{
					lastMinRow = min((activeRow - maxRow) + 3, rowCount)
				}
				else if activeRow < lastMinRow + 2
				{
					lastMinRow = max(activeRow - 2, 0)
				}
			}

			let minRow = lastMinRow

			for row in minRow ..< (minRow + maxRow)
			{
				let rowText: [String] = (0 ..< columnCount).map
				{
					(colIndex) -> String in

					let alignLeft = dataSource.listPanel(self, textAlignmentForColumn: colIndex) == .left
					return dataSource.listPanel(self,
					                             textForColumn: colIndex,
					                             ofRow: row).padded(to: columnWidths[colIndex], alignLeft: alignLeft)
				}

				if row == activeRow
				{
					window.usingTextAttributes(.bold)
					{
						window.drawText(rowText.joined(separator: "·"),
						                at: point.offset(y: Int32(row - minRow)),
						                withColorPair: activeColor)
					}
				}
				else
				{
					window.drawText(rowText.joined(separator: "·"),
					                at: point.offset(y: Int32(row - minRow)),
					                withColorPair: normalColor)
				}
			}

			needsRedraw = false
		}
	}

	enum TextAlignment
	{
		case left, right
	}
}

protocol UIListPanelDataSource: class
{
	func numberOfRowsForListPanel(_ listPanel: UIListPanel) -> Int
	func numberOfColumnsForListPanel(_ listPanel: UIListPanel) -> Int
	func listPanel(_ listPanel: UIListPanel, widthOfColumn column: Int) -> Int
	func listPanel(_ listPanel: UIListPanel, textAlignmentForColumn column: Int) -> UIListPanel.TextAlignment
	func listPanel(_ listPanel: UIListPanel, titleForColumn column: Int) -> String
	func listPanel(_ listPanel: UIListPanel, textForColumn column: Int, ofRow row: Int) -> String
}
