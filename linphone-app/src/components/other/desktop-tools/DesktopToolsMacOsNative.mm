#include "DesktopToolsMacOs.hpp"
#include "config.h"

#import <AVFoundation/AVFoundation.h>
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#include <QDebug>
#include <QRect>
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
	Q_UNUSED(screenIndex)
#ifdef ENABLE_SCREENSHARING
	CGDirectDisplayID displays[screenIndex+1];
	CGDisplayCount displayCount;
	CGGetOnlineDisplayList(screenIndex+1, displays, &displayCount);
	CGDirectDisplayID display = 0;
	if(displayCount > screenIndex)
		display = displays[screenIndex];
	return reinterpret_cast<void*>(display);
#else
	return NULL;
#endif
}

int DesktopTools::getDisplayIndex(void* screenSharing){
	Q_UNUSED(screenSharing)
#ifdef ENABLE_SCREENSHARING
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
#endif
	return 0;
}

void DesktopTools::getWindowIdFromMouse(VideoSourceDescriptorModel *model) {
	Q_UNUSED(model)
#ifdef ENABLE_SCREENSHARING
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
#endif
}

QRect DesktopTools::getWindowGeometry(void* screenSharing) {
  Q_UNUSED(screenSharing)
  QRect result;
#ifdef ENABLE_SCREENSHARING
  CGWindowID windowId = *(CGWindowID*)&screenSharing;
  CFArrayRef descriptions = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow, windowId);
  if(CFArrayGetCount(descriptions) > 0) {
          CFDictionaryRef description = (CFDictionaryRef)CFArrayGetValueAtIndex ((CFArrayRef)descriptions, 0);
          if(CFDictionaryContainsKey(description, kCGWindowBounds)) {
                  CFDictionaryRef bounds = (CFDictionaryRef)CFDictionaryGetValue (description, kCGWindowBounds);
                  if(bounds) {
                          CGRect windowRect;
                          CGRectMakeWithDictionaryRepresentation(bounds, &windowRect);
                          result = QRect(windowRect.origin.x, windowRect.origin.y, windowRect.size.width, windowRect.size.height);
                  }else
                          qWarning() << "Bounds found be cannot be parsed for Window ID : " << windowId;
          }else
                  qWarning() << "No bounds specified in Apple description for Window ID : " << windowId;
  }else
          qWarning() << "No description found for Window ID : " << windowId;
  CFRelease(descriptions);
#endif
  return result;
}
