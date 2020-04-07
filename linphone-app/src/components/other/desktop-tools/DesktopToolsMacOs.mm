#include "DesktopToolsMacOs.hpp"
#import <AVFoundation/AVFoundation.h>

void DesktopTools::initialize(){
// Request permissions
	if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized)
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL) {}];
	if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] != AVAuthorizationStatusAuthorized)
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL) {}];
}
