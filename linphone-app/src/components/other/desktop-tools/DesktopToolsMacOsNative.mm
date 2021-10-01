#include "DesktopToolsMacOs.hpp"
#import <AVFoundation/AVFoundation.h>

void DesktopTools::init(){
// Request permissions
	if( @available(macOS 10.14, *) ) {
		if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined)
			[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL) {}];
		if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusNotDetermined)
			[AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL) {}];
	}
}
