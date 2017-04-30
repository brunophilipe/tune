//
//  Double+Additions.swift
//  tune
//
//  Created by Bruno Philipe on 30/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
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
}
