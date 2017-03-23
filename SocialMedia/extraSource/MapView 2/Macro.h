#define ApplicationDelegate                 ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define UserDefaults                        [NSUserDefaults standardUserDefaults]
#define NotificationCenter                  [NSNotificationCenter defaultCenter]
#define SharedApplication                   [UIApplication sharedApplication]
#define Bundle                              [NSBundle mainBundle]
#define MainScreen                          [UIScreen mainScreen]
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x
#define NavBar                              self.navigationController.navigationBar
#define TabBar                              self.tabBarController.tabBar
#define NavBarHeight                        self.navigationController.navigationBar.bounds.size.height
#define TabBarHeight                        self.tabBarController.tabBar.bounds.size.height
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define ViewWidth(v)                        v.frame.size.width
#define ViewHeight(v)                       v.frame.size.height
#define ViewX(v)                            v.frame.origin.x
#define ViewY(v)                            v.frame.origin.y
#define SelfViewWidth                       self.view.bounds.size.width
#define SelfViewHeight                      self.view.bounds.size.height
#define RectX(f)                            f.origin.x
#define RectY(f)                            f.origin.y
#define RectWidth(f)                        f.size.width
#define RectHeight(f)                       f.size.height
#define RectSetWidth(f, w)                  CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectSetHeight(f, h)                 CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectSetX(f, x)                      CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectSetY(f, y)                      CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))
#define RectSetSize(f, w, h)                CGRectMake(RectX(f), RectY(f), w, h)
#define RectSetOrigin(f, x, y)              CGRectMake(x, y, RectWidth(f), RectHeight(f))
#define DATE_COMPONENTS                     NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
#define TIME_COMPONENTS                     NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
#define FlushPool(p)                        [p drain]; p = [[NSAutoreleasePool alloc] init]
#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXCOLOR(c)                         [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0];


#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES) objectAtIndex:0]

//For setting static images for iPhone 4 and iPhone 5
#define ASSET_BY_SCREEN_HEIGHT(regular, longScreen) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : longScreen)

//For Checking device is iPhone 4 or iPhone 5
#define isIphone5() (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? 0 : 1)
#define isIphone5OffSet() (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? 0 : 88)
#define isIpad() (([[UIDevice currentDevice] userInterfaceIdiom]== UIUserInterfaceIdiomPad) ? 1 : 0)

//Step:1
//To stop print NSLog write this code

#define __DEBUG__

#ifdef __DEBUG__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif

//Step:2
//and When don't want logs in app then just comment the first line i.e

#define __DEBUG__


#ifdef __IPHONE_6_0
# define LINE_BREAK_WORD_WRAP NSLineBreakByWordWrapping
#define  TEXT_ALIGNLEFT   NSTextAlignmentLeft
#define  TEXT_ALIGNCENTER   NSTextAlignmentCenter
#else
# define LINE_BREAK_WORD_WRAP UILineBreakModeWordWrap
#define  TEXT_ALIGNLEFT   UITextAlignmentLeft
#define  TEXT_ALIGNCENTER   UITextAlignmentCenter
#endif

#define ProjectName @"Mapkit Demo"
#define alertLocationLibAcess @"Please grant Mapkit Demo to access your Location.\n To do so, go in 'Settings' ->'Privacy' ->'Location' and enable Mapkit Demo."
#import "AppDelegate.h"