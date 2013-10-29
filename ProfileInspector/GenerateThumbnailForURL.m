#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>
#include <WebKit/WebKit.h>
#include "ZipFile.h"
#include "FileInZipInfo.h"
#include "ZipReadStream.h"
#include <Security/CMSDecoder.h>

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);
NSDictionary * provisioningProfileAtPath(NSData *data);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */


OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
 
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:@"app.ipa"
                                                     mode:ZipFileModeUnzip];

    [unzipFile locateFileInZip:@"Payload/spotmyride.app/embedded.mobileprovision"];
    ZipReadStream *read= [unzipFile readCurrentFileInZip];
    
    
    NSMutableData *data= [[NSMutableData alloc] initWithLength:9092];
    long bytesRead = [read readDataWithBuffer:data];
    [read finishedReading];
    [unzipFile close];
    
    NSLog(@"Data Read: %ld",bytesRead);

    
//    NSString *dataStr;
//    
//    
//    NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", [data description]);
    
    provisioningProfileAtPath(data);
    
    /*
    NSString *_content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:NSUTF8StringEncoding error:nil];

    if (_content) {
        // Encapsulate the content of the .strings file in HTML
        NSString *_html = [NSString stringWithFormat:@"<html><body><pre>%@</pre></body></html>", _content];
        NSData *_data   = [_html dataUsingEncoding:NSUTF8StringEncoding];
        
		NSRect _rect = NSMakeRect(0.0, 0.0, 600.0, 800.0);
		float _scale = maxSize.height / 800.0;
		NSSize _scaleSize = NSMakeSize(_scale, _scale);
		CGSize _thumbSize = NSSizeToCGSize((CGSize) { maxSize.width * (600.0/800.0), maxSize.height});
        
        // Create the webview to display the thumbnail
        WebView *_webView = [[WebView alloc] initWithFrame:_rect];
		[_webView scaleUnitSquareToSize:_scaleSize];
        [_webView.mainFrame.frameView setAllowsScrolling:NO];
        [_webView.mainFrame loadData:_data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
        
		while([_webView isLoading]) CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
        [_webView display];
        
        // Draw the webview in the correct context
		CGContextRef _context = QLThumbnailRequestCreateContext(thumbnail, _thumbSize, false, NULL);
		if (_context) {
			NSGraphicsContext* _graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)_context flipped:_webView.isFlipped];
			[_webView displayRectIgnoringOpacity:_webView.bounds inContext:_graphicsContext];
			QLThumbnailRequestFlushContext(thumbnail, _context);
			CFRelease(_context);
		}
    }
    
    NSLog(@"GenerateThumbnailForURL");
    */
    return noErr;
}

NSDictionary * provisioningProfileAtPath(NSData *data){
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





void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
