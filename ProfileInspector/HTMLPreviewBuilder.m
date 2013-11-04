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
    [htmlText appendFormat: @"<html><head><title></title></head>"];
    [htmlText appendFormat: @"<body>"];

    [htmlText appendFormat: @"<table>"];
    [htmlText appendFormat:@"<tr><td>App</td><td>%@</td></tr>",appName];
    [htmlText appendFormat:@"<tr><td>Team</td><td>%@</td></tr>",teamName];
    [htmlText appendFormat:@"<tr><td>UUID</td><td>%@</td></tr>",UUID];
    [htmlText appendFormat:@"<tr><td>Creation Date<td><td>%@</td></tr>",creationDate];
    [htmlText appendFormat:@"<tr><td>Expiration Date<td><td>%@</td></tr>",expirationDate];
    [htmlText appendFormat: @"</table>"];
    
    [htmlText appendFormat:@"Total Provisioned Devices: %ld",[provisionedDevices count]];
    [htmlText appendFormat: @"<table>"];
    for (NSString *deviceUDID in provisionedDevices) {
        [htmlText appendFormat:@"<tr><td>%@</td></tr>",[deviceUDID lowercaseString]];
    }
    [htmlText appendFormat: @"</table>"];
    [htmlText appendFormat: @"</body>"];
    [htmlText appendFormat: @"</html>"];
    return htmlText;
}

@end
