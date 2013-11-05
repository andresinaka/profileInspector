//
//  HTMLPreviewBuilder.m
//  ProfileInspector
//
//  Created by Andres on 11/3/13.
//  Copyright (c) 2013 Coconut Factory. All rights reserved.
//

#import "HTMLPreviewBuilder.h"

@implementation HTMLPreviewBuilder


-(NSString *)createHTMLPreviewFromDictionary: (NSDictionary *) provisioningProfile{
    NSArray *provisionedDevices = provisioningProfile[@"ProvisionedDevices"];
    NSString *appName = provisioningProfile[@"Name"];
    NSString *teamName = provisioningProfile[@"TeamName"];
    NSString *apsEnvironmnet = provisioningProfile[@"Entitlements"][@"aps-environment"];
    NSString *creationDate = provisioningProfile[@"CreationDate"];
    NSString *expirationDate = provisioningProfile[@"ExpirationDate"];
    NSString *UUID = provisioningProfile[@"UUID"];
    
    
    
    NSMutableString *htmlText = [[NSMutableString alloc] init];
    [htmlText appendFormat: @"<html><head><link rel='stylesheet' type='text/css' href='cid:inspectorStyle.css'><title></title></head>"];
    [htmlText appendFormat: @"<body>\n"];

    [htmlText appendFormat: @"<table>\n"];
    [htmlText appendFormat:@"<tr><td>App</td><td>%@</td></tr>\n",appName];
    [htmlText appendFormat:@"<tr><td>Team</td><td>%@</td></tr>\n",teamName];
    [htmlText appendFormat:@"<tr><td>UUID</td><td>%@</td></tr>\n",UUID];
    [htmlText appendFormat:@"<tr><td>Creation Date</td><td>%@</td></tr>\n",creationDate];
    [htmlText appendFormat:@"<tr><td>Expiration Date</td><td>%@</td></tr>\n",expirationDate];
    [htmlText appendFormat: @"</table>\n"];
    
    [htmlText appendFormat:@"<div id='provisionedDevices-section'>\n"];
    [htmlText appendFormat:@"Total Provisioned Devices: %ld",[provisionedDevices count]];
    [htmlText appendFormat: @"<table class='provisioned-devices'>\n"];
    [htmlText appendFormat:@"<tr><th></th><th>UDID</th></tr>\n"];

    for (NSString *deviceUDID in provisionedDevices) {
        [htmlText appendFormat:@"<tr><td>%lu</td><td>%@</td></tr>\n",[provisionedDevices indexOfObject:deviceUDID]+1 ,[self splitInToken:[deviceUDID lowercaseString]]];
    }
    [htmlText appendFormat: @"</table>\n"];
    [htmlText appendFormat:@"</div>\n"];
    [htmlText appendFormat: @"</body>\n"];
    [htmlText appendFormat: @"</html>\n"];
    return htmlText;
}

- (NSString *) splitInToken:(NSString *)stringToSplit {
    NSMutableArray *splitted = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 7 ; i++) {
        [splitted addObject:[stringToSplit substringWithRange:NSMakeRange(i * 5, 5)]];
    }
    return [splitted componentsJoinedByString:@" "];
}
@end
