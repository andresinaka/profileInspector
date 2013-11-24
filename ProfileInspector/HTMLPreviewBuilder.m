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
    NSString *appId = provisioningProfile[@"Entitlements"][@"application-identifier"];
    NSString *creationDate = provisioningProfile[@"CreationDate"];
    NSString *expirationDate = provisioningProfile[@"ExpirationDate"];
    NSString *UUID = provisioningProfile[@"UUID"];
    
    
    
    NSMutableString *htmlText = [[NSMutableString alloc] init];
    [htmlText appendFormat: @"<!DOCTYPE html><html><head><link rel='stylesheet' type='text/css' href='cid:bootstrap.css'><link rel='stylesheet' type='text/css' href='cid:inspectorStyle.css'><title></title></head>"];
    [htmlText appendFormat: @"<body>"];
    
    [htmlText appendFormat: @"<dl class='dl-horizontal'>\n"];
    [htmlText appendFormat:@"<dt>App</dt><dd>%@</dd>\n",appName];
    [htmlText appendFormat:@"<dt>App Id</dt><dd>%@</dd>\n",appId];
    [htmlText appendFormat:@"<dt>Team</dt><dd>%@</dd>\n",teamName];
    [htmlText appendFormat:@"<dt>UUID</dt><dd>%@</dd>\n",UUID];
    [htmlText appendFormat:@"<dt>Creation Date</dt><dd>%@</dd>\n",creationDate];
    [htmlText appendFormat:@"<dt>Expiration Date</dt><dd>%@</dd>\n",expirationDate];
    [htmlText appendFormat: @"</dl>\n"];

    
    
    [htmlText appendFormat:@"<div class='panel panel-default'>"];
    [htmlText appendFormat:@"<div class='panel-heading'><strong>Provisioned Devices: %lu</strong></div>",(unsigned long)[provisionedDevices count]];
    [htmlText appendFormat: @"<table class='table table-condensed table-striped'>\n"];
    [htmlText appendFormat:@"<tr><th>#</th><th>UDID</th></tr>\n"];

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
