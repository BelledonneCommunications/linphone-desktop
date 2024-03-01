#include "DesktopToolsMacOs.hpp"
#import <AVFoundation/AVFoundation.h>
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#include <QDebug>
#include <QThread>
#include "components/videoSource/VideoSourceDescriptorModel.hpp"

void DesktopTools::init(){
// Request permissions
  if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
    qDebug() << "Requesting Video permission";
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL) {}];
  }
  if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] != AVAuthorizationStatusAuthorized){
    qDebug() << "Requesting Audio permission";
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL) {}];
  }
}


void *DesktopTools::getDisplay(int screenIndex){
	CGDirectDisplayID displays[screenIndex+1];
	CGDisplayCount displayCount;
	CGGetOnlineDisplayList(screenIndex+1, displays, &displayCount);
	CGDirectDisplayID display = 0;
	if(displayCount > screenIndex)
		display = displays[screenIndex];
	return reinterpret_cast<void*>(display);
}

int DesktopTools::getDisplayIndex(void* screenSharing){
	CGDirectDisplayID displayId = *(CGDirectDisplayID*)&screenSharing;
	int maxDisplayCount = 10;
	CGDisplayCount displayCount;
	do {
		CGDirectDisplayID displays[maxDisplayCount];
		CGGetOnlineDisplayList(maxDisplayCount, displays, &displayCount);
		for(int i = 0 ; i < displayCount ; ++i)
			if( displays[i] == displayId) {
				return i;
			}
		maxDisplayCount *= 2;
	}while(displayCount == maxDisplayCount/2);
	return 0;
}

void DesktopTools::getWindowIdFromMouse(VideoSourceDescriptorModel *model) {
      __block id globalMonitorId;
      __block id localMonitorId;
      __block DesktopTools * tools = this;
      emit windowIdSelectionStarted();
      globalMonitorId = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown
                                    handler:^(NSEvent *event){
				CGWindowID windowID = (CGWindowID)[event windowNumber];
				if(event.type == NSEventTypeLeftMouseDown)
					model->setScreenSharingWindow(reinterpret_cast<void *>(windowID));
				[NSEvent removeMonitor:globalMonitorId];
				[NSEvent removeMonitor:localMonitorId];
				emit tools->windowIdSelectionEnded();
  }];
      localMonitorId = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown
                                    handler:^NSEvent *(NSEvent *event){
              CGWindowID windowID = (CGWindowID)[event windowNumber];
              if(event.type == NSEventTypeLeftMouseDown)
                model->setScreenSharingWindow(reinterpret_cast<void *>(windowID));
              [NSEvent removeMonitor:globalMonitorId];
              [NSEvent removeMonitor:localMonitorId];
              emit tools->windowIdSelectionEnded();
              return nil;
  }];
}
