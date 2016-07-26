//
//  Tools.m
//  tune
//
//  Created by Bruno Philipe on 7/26/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

#import "Tools.h"

@implementation Tools

+ (SBObject*)instantiateObjectFromApplication:(SBApplication*)app typeName:(NSString*)name andProperties:(NSDictionary*)properties
{
	Class className = [app classForScriptingClass:name];
	return [[className alloc] initWithProperties:properties];
}

@end
