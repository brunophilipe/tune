//
//  Double+Additions.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
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

extension Double
{
	var durationString: String
	{
		let durMin = Int(self/60)
		let durSec = Int(self.truncatingRemainder(dividingBy: 60))
		return "\(durMin < 10 ? "0\(durMin)" : "\(durMin)"):" + "\(durSec < 10 ? "0\(durSec)" : "\(durSec)")"
	}

	var longDurationString: String
	{
		let durMin = Int(self/60)
		let durSec = Int(self.truncatingRemainder(dividingBy: 60))
		return "\(durMin)m \(durSec)s"
	}
}
