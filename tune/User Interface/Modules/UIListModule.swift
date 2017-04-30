//
//  UIListModule.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class UIListModule: UserInterfaceSizableModule, UserInterfacePositionableModule
{
	weak var userInterface: UserInterface? = nil
	
	weak var dataSource: UIListModuleDataSource? = nil
	{
		didSet { needsRedraw = true }
	}
	
	required init(userInterface: UserInterface)
	{
		self.userInterface = userInterface
	}
	
	var width: Int32 = 0
	{
		didSet { needsRedraw = true }
	}
	
	var height: Int32 = 0
	{
		didSet { needsRedraw = true }
	}
	
	var needsRedraw: Bool = true
	
	var selectedRow: Int? = nil
	{
		didSet { needsRedraw = true }
	}
	
	func draw()
	{
		draw(at: UIPoint.zero)
	}
	
	func draw(at point: UIPoint)
	{
		if shouldDraw(), let dataSource = self.dataSource, let ui = self.userInterface
		{
			let columnCount = dataSource.numberOfColumnsForListModule(self)
			let rowCount = dataSource.numberOfRowsForListModule(self)
			
			if rowCount == 0 || columnCount == 0
			{
				needsRedraw = false
				return
			}
			
			let columnWidths: [Int] = (0 ..< columnCount).map({dataSource.listModule(self, widthOfColumn: $0)})
			
//			if columnWidths.reduce(0, { $0 + $1 }) > width
//			{
//				//Inconsistency! Too wide columns
//			}
			
			for row in 0 ..< min(rowCount, Int(height))
			{
				let rowText: [String] = (0 ..< columnCount).map
				{
					(colIndex) -> String in
					let alignLeft = dataSource.listModule(self, textAlignmentForColumn: colIndex) == .left
					return dataSource.listModule(self,
					                             textForColumn: colIndex,
					                             ofRow: row).padded(to: columnWidths[colIndex], alignLeft: alignLeft)
				}
				
				if row == selectedRow
				{
					ui.usingTextAttributes(.standout)
					{
						ui.drawText(rowText.joined(separator: "·"),
						            at: point.offset(y: Int32(row)),
						            withColorPair: ui.sharedColorWhiteOnBlack)
					}
				}
				else
				{
					ui.drawText(rowText.joined(separator: "·"),
					            at: point.offset(y: Int32(row)),
					            withColorPair: ui.sharedColorWhiteOnBlack)
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

protocol UIListModuleDataSource: class
{
	func numberOfRowsForListModule(_ listModule: UIListModule) -> Int
	func numberOfColumnsForListModule(_ listModule: UIListModule) -> Int
	func listModule(_ listModule: UIListModule, widthOfColumn column: Int) -> Int
	func listModule(_ listModule: UIListModule, textAlignmentForColumn column: Int) -> UIListModule.TextAlignment
	func listModule(_ listModule: UIListModule, titleForColumn column: Int) -> String
	func listModule(_ listModule: UIListModule, textForColumn column: Int, ofRow row: Int) -> String
}
