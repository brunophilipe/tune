//
//  iTunesTools.h
//  tune
//
//  Created by Bruno Philipe on 7/26/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

@interface iTunesTools : NSObject

+ (SBObject*)instantiateObjectFromApplication:(SBApplication*)app typeName:(NSString*)name andProperties:(NSDictionary*)properties;

@end
