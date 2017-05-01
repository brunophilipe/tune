//
//  UIListPanel.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class UIListPanel: UIPanel
{
	weak var dataSource: UIListPanelDataSource? = nil

	var activeRow: Int? = nil

	var activeRowTextColor: UIColorPair? = nil

	override var window: UIWindow?
	{
		didSet
		{
			activeRowTextColor = window?.controller?.userInterface?.registerColorPair(fore: COLOR_CYAN, back: COLOR_BLACK)
		}
	}

	override func draw()
	{
		if let window = self.window,
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

			for row in 0 ..< min(rowCount, Int(frame.height))
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
						                at: point.offset(y: Int32(row)),
						                withColorPair: activeColor)
					}
				}
				else
				{
					window.drawText(rowText.joined(separator: "·"),
					                at: point.offset(y: Int32(row)),
					                withColorPair: normalColor)
				}
			}
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
