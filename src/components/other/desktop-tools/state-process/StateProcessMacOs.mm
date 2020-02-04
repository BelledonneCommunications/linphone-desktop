#include "../DesktopToolsMacOs.hpp"
#import <Foundation/NSString.h>
#import <Foundation/NSProcessInfo.h>

// Store a unique global instance of Activity to avoid App Nap of MacOs
static id g_backgroundActivity =0;

void DesktopTools::applicationStateChanged(Qt::ApplicationState p_currentState)
{
  if( p_currentState == Qt::ApplicationActive && g_backgroundActivity != 0 )
  {// Entering Foreground
    [[NSProcessInfo processInfo] endActivity:g_backgroundActivity];
    [g_backgroundActivity release];
    g_backgroundActivity = 0;
  }else if( g_backgroundActivity == 0 )
  {// Doesn't begin activity if it is already started
      g_backgroundActivity = [[NSProcessInfo processInfo] beginActivityWithOptions:NSActivityUserInitiatedAllowingIdleSystemSleep reason:@"Linphone : Continue to receive requests while in Background"];
      [g_backgroundActivity retain];
  }
}
