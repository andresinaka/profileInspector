//
//  HTMLPreviewBuilder.h
//  ProfileInspector
//
//  Created by Andres on 11/3/13.
//  Copyright (c) 2013 Coconut Factory. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLPreviewBuilder : NSObject

-(NSString *)createHTMLPreviewFromDictionary: (NSDictionary *) provisioningProfile;

@end
