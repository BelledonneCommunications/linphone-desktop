#include "DesktopToolsMacOs.hpp"
#include "config.h"

#import <AVFoundation/AVFoundation.h>
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#include <QDebug>
#include <QRect>
#include <QThread>
#include <Availability.h>

void DesktopTools::init(){
}

void DesktopTools::requestPermissions(){
// Request permissions
	if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
		qInfo() << "Requesting Video permission";
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
			qInfo() << "Video permission has" << (granted ? "" : " not") << " been granted";
		}];
	} else
		qInfo() << "Video permission is already granted";
	if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] != AVAuthorizationStatusAuthorized){
		qInfo() << "Requesting Audio permission";
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
			qInfo() << "Audio permission has" << (granted ? "" : " not") << " been granted";
		}];
	} else
		qInfo() << "Audio permission is already granted";
}

bool isWindowMinimized(CGWindowID id) {
	CFArrayRef ids = CFArrayCreate(NULL, reinterpret_cast<const void **>(&id), 1, NULL);
	CFArrayRef descriptions = CGWindowListCreateDescriptionFromArray(ids);
	bool minimized = false;

	if (descriptions && CFArrayGetCount(descriptions)) {
		CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(descriptions, 0));
		minimized = ! reinterpret_cast<CFBooleanRef>(CFDictionaryGetValue(window, kCGWindowIsOnscreen));
	}

	CFRelease(descriptions);
	CFRelease(ids);

	return minimized;
}

QList<QVariantMap> DesktopTools::getWindows() {
	QList<QVariantMap> windows;
	bool haveAccess = CGPreflightScreenCaptureAccess();
	//Requests event listening access if absent, potentially prompting
	if(!haveAccess) haveAccess = CGRequestScreenCaptureAccess();

	CFArrayRef infos = CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID);
	for(int windowIndex = 0 ; windowIndex < CFArrayGetCount(infos) ; ++windowIndex) {
		CFDictionaryRef description = (CFDictionaryRef)CFArrayGetValueAtIndex ((CFArrayRef)infos, windowIndex);
		if(CFDictionaryContainsKey(description, kCGWindowNumber)
			&& CFDictionaryContainsKey(description, kCGWindowLayer)
			&& CFDictionaryContainsKey(description, kCGWindowName)
			) {
			CFNumberRef idRef = (CFNumberRef)CFDictionaryGetValue (description, kCGWindowNumber);
			CFNumberRef layerRef = (CFNumberRef)CFDictionaryGetValue (description, kCGWindowLayer);
			CFStringRef titleRef = (CFStringRef)CFDictionaryGetValue (description, kCGWindowName);
			CGWindowID id=0, layer=0;

			if (!CFNumberGetValue(idRef, kCFNumberIntType, &id) || !CFNumberGetValue(layerRef, kCFNumberIntType, &layer)) {
				continue;
			}

			QVariantMap window;
			if(CFDictionaryContainsKey(description, kCGWindowName)) {
				window["name"] = QString::fromCFString(titleRef);
			}
			if( window["name"] == "") continue;
			window["windowId"] = id;

			// Skip layer != 0 like menu or dock
			if(layer != 0 || isWindowMinimized(id))
				continue;
			// Remove System status indicator from the list as they are on layer 0
			CFStringRef ownerName = reinterpret_cast<CFStringRef>(CFDictionaryGetValue(description, kCGWindowOwnerName));
			if (titleRef && CFEqual(titleRef, CFSTR("StatusIndicator")) && ownerName && CFEqual(ownerName, CFSTR("Window Server"))) {
				continue;
			}
			windows << window;
		}
	}
	if(infos) CFRelease(infos);
	return windows;
}
CGBitmapInfo CGBitmapInfoForQImage(const QImage &image) {
	CGBitmapInfo bitmapInfo = kCGImageAlphaNone;

	switch (image.format()) {
	case QImage::Format_ARGB32:
		bitmapInfo = kCGImageAlphaFirst | kCGBitmapByteOrder32Host;
		break;
	case QImage::Format_RGB32:
		bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
		break;
	case QImage::Format_RGBA8888_Premultiplied:
		bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
		break;
	case QImage::Format_RGBA8888:
		bitmapInfo = kCGImageAlphaLast | kCGBitmapByteOrder32Big;
		break;
	case QImage::Format_RGBX8888:
		bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big;
		break;
	case QImage::Format_ARGB32_Premultiplied:
		bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
		break;
	default:
		break;
	}

	return bitmapInfo;
}

QImage CGImageToQImage(CGImageRef cgImage) {
	const size_t width = CGImageGetWidth(cgImage);
	const size_t height = CGImageGetHeight(cgImage);
	QImage image(width, height, QImage::Format_ARGB32_Premultiplied);
	image.fill(Qt::transparent);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
	CGContextRef context = CGBitmapContextCreate((void *)image.bits(), image.width(), image.height(), 8,
												 image.bytesPerLine(), colorSpace, CGBitmapInfoForQImage(image));

	// Scale the context so that painting happens in device-independent pixels
	const qreal devicePixelRatio = image.devicePixelRatio();
	CGContextScaleCTM(context, devicePixelRatio, devicePixelRatio);

	CGRect rect = CGRectMake(0, 0, width, height);
	CGContextDrawImage(context, rect, cgImage);

	if(colorSpace) CFRelease(colorSpace);
	if(context) CFRelease(context);

	return image;
}

QImage DesktopTools::getWindowIcon(void *window) {
	CGWindowID windowId = *(CGWindowID*)&window;
	pid_t pid=0;

	CFArrayRef infos = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow, windowId);
	NSString *bundleIdentifier = @"";
	if (infos && CFArrayGetCount(infos)) {
		CFDictionaryRef w = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(infos, 0));
		CFNumberRef pidRef = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(w, kCGWindowOwnerPID));
		CFNumberGetValue(pidRef, kCFNumberIntType, &pid) ;
		bundleIdentifier = [[NSRunningApplication runningApplicationWithProcessIdentifier:pid] bundleIdentifier];
	}

	if(infos) CFRelease(infos);

	if(bundleIdentifier) {
		NSURL* url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:bundleIdentifier];
		NSString * noScheme = [[url absoluteString] substringFromIndex:7];
		NSImage *nsImage = [[NSWorkspace sharedWorkspace] iconForFile:noScheme];

		NSRect rect = NSMakeRect(0, 0, nsImage.size.width, nsImage.size.height);
		CGImageRef cgImage = [nsImage CGImageForProposedRect:&rect context:NULL hints:nil];

		return CGImageToQImage(cgImage);
	}else {
		qWarning() << "Screensharing : Bundle identifier is null for CGID=" << windowId << " pid="<< pid;
		return QImage();
	}
}

QImage DesktopTools::takeScreenshot(void *window) {
#if __MAC_OS_X_VERSION_MIN_REQUIRED > 140000
	__block bool haveAccess = false;
	// Must be call from main thread! If not, you may be in deadlock.
	dispatch_sync(dispatch_get_main_queue(), ^{
		// Checks whether the current process already has screen capture access
		haveAccess = CGPreflightScreenCaptureAccess();
		//Requests event listening access if absent, potentially prompting
		if(!haveAccess) haveAccess = CGRequestScreenCaptureAccess();
	});
	if(!haveAccess){
		qCritical() << "The application don't have the permission to capture the screen";
		return QImage();
	}
	std::condition_variable condition;
	std::mutex lock;
	BOOL ended = FALSE;
	__block SCContentFilter *filter = nil;
	__block  CGImageRef capture = nil;
	__block BOOL *_ended = &ended;
	__block std::condition_variable *_condition = &condition;
	CGWindowID windowId = *(CGWindowID*)&window;

	[SCShareableContent
		getShareableContentWithCompletionHandler:^(SCShareableContent *shareableContent,
												   NSError *error) {
			if (!error || error.code == 0) {
				if(windowId) {
					for (int i = 0; i < shareableContent.windows.count && !filter; ++i){
						if (shareableContent.windows[i].windowID == windowId) {
							filter = [[SCContentFilter alloc] initWithDesktopIndependentWindow:shareableContent.windows[i]];
						}
					}
				}
			}else
				qCritical() << "SCShareableContent error: " << error.code;
			*_ended = TRUE;
			_condition->notify_all();
		}];
	std::unique_lock<std::mutex> locker(lock);
	condition.wait(locker, [&ended]{ return ended; });
	if(!filter){
		qCritical() << "Screenshot: The filter could not be created";
		return QImage();
	}
	*_ended = FALSE;

	SCStreamConfiguration *configuration = [[SCStreamConfiguration alloc] init];
	configuration.capturesAudio = NO;
	configuration.excludesCurrentProcessAudio = YES;
	configuration.preservesAspectRatio = YES;
	configuration.showsCursor = NO;
	configuration.captureResolution = SCCaptureResolutionBest;
	configuration.width = NSWidth(filter.contentRect) * filter.pointPixelScale;
	configuration.height = NSHeight(filter.contentRect) * filter.pointPixelScale;
	[SCScreenshotManager captureImageWithFilter:filter
		configuration:configuration
		completionHandler:^(CGImageRef sampleBuffer, NSError *error){
			if (!error || error.code == 0)  {
				capture = sampleBuffer;
				[capture retain];
			}else{
				qCritical() << "Screenshot: cannot capture: " << error.code;
			}
			*_ended = TRUE;
			_condition->notify_all();
		}
	];
	condition.wait(locker, [&ended]{ return ended; });
	[configuration dealloc];
	[filter dealloc];
	if(!capture) {
		return QImage();
	}
	QImage image = CGImageToQImage(capture);
	[capture release];
	return image;
	// Deprecated:
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		CGWindowID windowId = *(CGWindowID*)&window;
		CGImageRef capture = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, windowId, kCGWindowImageBoundsIgnoreFraming);
#pragma clang diagnostic pop
		return CGImageToQImage(capture);
#endif
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
  if(descriptions) CFRelease(descriptions);
#endif
  return result;
}
