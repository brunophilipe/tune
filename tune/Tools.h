//
//  Tools.h
//  tune
//
//  Created by Bruno Philipe on 7/26/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

@interface Tools : NSObject

+ (SBObject*)instantiateObjectFromApplication:(SBApplication*)app typeName:(NSString*)name andProperties:(NSDictionary*)properties;

@end
