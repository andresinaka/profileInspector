#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <Cocoa/Cocoa.h>
#include <QuickLook/QuickLook.h>
#include "ZipFile.h"
#include "FileInZipInfo.h"
#include "ZipReadStream.h"
#include <Security/CMSDecoder.h>
#include "HTMLPreviewBuilder.h"

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
    HTMLPreviewBuilder *previewBuilder = [[HTMLPreviewBuilder alloc]init];
    NSString *html;
    if (provisioningProfile) {
        html = [previewBuilder createHTMLPreviewFromDictionary:provisioningProfile];
    }
    
    
    NSString *_content = provisioningProfile[@"TeamName"];
    
    QLPreviewRequestSetDataRepresentation(preview,(__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],kUTTypeHTML,NULL);
    
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
