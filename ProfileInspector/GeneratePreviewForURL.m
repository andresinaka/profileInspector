#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <Cocoa/Cocoa.h>
#include <QuickLook/QuickLook.h>
#include "ZipFile.h"
#include "FileInZipInfo.h"
#include "ZipReadStream.h"
#include <Security/CMSDecoder.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);
NSDictionary * provisioningProfileInData(NSData *data);
/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:@"app.ipa" mode:ZipFileModeUnzip];
    
    unsigned long fileSize = 0;
    NSString *fileName;
    
    NSArray *files = [unzipFile listFileInZipInfos];
    for (FileInZipInfo *info in files) {
        if (([info.name rangeOfString:@"embedded.mobileprovision"].length > 0)) {
            fileSize = (unsigned long) info.length;
            fileName = info.name;
            break;
        }
    }
    
    [unzipFile locateFileInZip:fileName];
    ZipReadStream *read= [unzipFile readCurrentFileInZip];
    
    NSMutableData *data= [[NSMutableData alloc] initWithLength:fileSize];
    [read readDataWithBuffer:data];
    [read finishedReading];
    [unzipFile close];
    
    NSDictionary *provisioningProfile = provisioningProfileInData(data);
    
    if (provisioningProfile) {
        NSString *_html = [NSString stringWithFormat:@"<html><body><pre>%@</pre></body></html>", provisioningProfile[@"TeamName"]];
        NSData *_data   = [_html dataUsingEncoding:NSUTF8StringEncoding];
        
//		NSRect _rect = NSMakeRect(0.0, 0.0, 600.0, 800.0);
//		float _scale = maxSize.height / 800.0;
//		NSSize _scaleSize = NSMakeSize(_scale, _scale);
//		CGSize _thumbSize = NSSizeToCGSize((CGSize) { maxSize.width * (600.0/800.0), maxSize.height});
//        //
//        //        // Create the webview to display the thumbnail
//        WebView *_webView = [[WebView alloc] initWithFrame:_rect];
//		[_webView scaleUnitSquareToSize:_scaleSize];
//        [_webView.mainFrame.frameView setAllowsScrolling:YES];
//        [_webView.mainFrame loadData:_data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
//        
//		while([_webView isLoading]) CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
//        [_webView display];
//        //
//        // Draw the webview in the correct context
//		CGContextRef _context = QLThumbnailRequestCreateContext(thumbnail, _thumbSize, false, NULL);
//		if (_context) {
//			NSGraphicsContext* _graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)_context flipped:_webView.isFlipped];
//			[_webView displayRectIgnoringOpacity:_webView.bounds inContext:_graphicsContext];
//			QLThumbnailRequestFlushContext(thumbnail, _context);
//			CFRelease(_context);
//		}
    }
    
    
    NSString *_content = @"THIS IS A TEXT FOR TEST";
    
    QLPreviewRequestSetDataRepresentation(preview,(__bridge CFDataRef)[_content dataUsingEncoding:NSUTF8StringEncoding],kUTTypePlainText,NULL);
    
    NSLog(@"GeneratePreviewForURL");
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}


NSDictionary * provisioningProfileInData(NSData *data){
    CMSDecoderRef decoder = NULL;
    CFDataRef dataRef = NULL;
    NSString *plistString = nil;
    NSDictionary *plist = nil;
    NSData *fileData = data;
    @try {
        CMSDecoderCreate(&decoder);
        CMSDecoderUpdateMessage(decoder, fileData.bytes, fileData.length);
        CMSDecoderFinalizeMessage(decoder);
        CMSDecoderCopyContent(decoder, &dataRef);
        plistString = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
        NSData *plistData = [plistString dataUsingEncoding:NSUTF8StringEncoding];
        plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Could not decode file.\n");
    }
    @finally {
        if (decoder) CFRelease(decoder);
        if (dataRef) CFRelease(dataRef);
    }
    
    return plist;
}
