//
//  AppDelegate.m
//  Huban
//
//  Created by sean on 15/7/22.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AppDelegate.h"
#import "RootTabViewController.h"
#import "LoginViewController.h"
#import "BaseNavigationController.h"
#import "EaseMob.h"
#import "Message_RootViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface AppDelegate () <BMKGeneralDelegate>
@end

@implementation AppDelegate

#pragma mark RemoteNotification
- (void)registerPush{
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(sysVer < 8){
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }else{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self clearNotification];
    //初始化百度地图
    // 要使用百度地图，请先启动BaiduMapManager
    BMKMapManager *mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [mapManager start:@"W1Nt5ondGGq68LHoK1y5pfjx" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    //推送权限
    [self registerPush];
    //定位权限
    [[LocationManager shareInstance] requestAuthorization];
    //注册极光推送
    [APService setupWithOption:launchOptions];
    //注册环信
    [self registerForEaseMobForApplication:application andLaunchingWithOptions:launchOptions];
    //数据库
    [[DataBaseManager shareInstance] initDatabase];
    //设置样式
    [self customizeInterface];
    if ([Login isLogin]) {
        [self setupTabBarViewController];
    } else {
        [self setupLoginViewController];
    }
    //获取图片主路径
    [self getRootImageURL];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@",deviceToken);
    //极光推送
    [APService registerDeviceToken:deviceToken];
    //环信的推送
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [APService handleRemoteNotification:userInfo];
    [BaseViewController handleNotification:userInfo applicationState:[application applicationState]];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self clearNotification];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - Private
- (void)clearNotification { //清楚通知栏消息,清除角标
    [APService setBadge:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

//导航页面
- (void)setupIntroductionViewController {
    
}

//登录界面
- (void)setupLoginViewController {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:loginVC];
    [self.window setRootViewController:baseNav];
}

//主界面
- (void)setupTabBarViewController {
    RootTabViewController *rootVC = [[RootTabViewController alloc] init];
    rootVC.tabBar.translucent = YES;
    [self.window setRootViewController:rootVC];
}

- (void)customizeInterface {
    //设置Nav的背景色和title色
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setTintColor:[UIColor colorWithHexString:@"0xffffff"]];//返回按钮的箭头颜色
    //背景颜色
    [navigationBarAppearance setBackgroundImage:[UIImage imageWithColor:SYSBACKGROUNDCOLOR_BLUE] forBarMetrics:UIBarMetricsDefault];
    NSDictionary *textAttributes = nil;
    //字体
    textAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:kNavTitleFontSize],
                       NSForegroundColorAttributeName: [UIColor whiteColor]};
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}

- (void)getRootImageURL {
    [[NetAPIManager shareManager] request_image_rooturlWithBlock:^(id data, NSError *error) {
        if (data) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:data[@"siteurl"] forKey:kImaget_Root];
            [userDefaults synchronize];
        }
    }];
}

- (void)registerForEaseMobForApplication:(UIApplication *)application andLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self _setupAppDelegateNotifications];
    //注册环信
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"qzkj#huban" apnsCertName:@"dev_push" otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    //启动环信
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)_setupAppDelegateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

- (void)appDidEnterBackgroundNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:notif.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}

#pragma mark - 下面代码实际不执行,辅助用于持久化数据
- (void)getProvinceInfo { //获取省市区信息,写成plist直接保存在app里
    NSDictionary *provParams = @{@"method":@"common.prov.pager",@"start":@0,@"limit":@0};
    [[NetAPIManager shareManager] request_get_regionInfoWithParams:provParams andBlock:^(id data, NSError *error) {
        if (data) {
            NSArray *provDictArray = [data objectForKey:@"list"];
            for (NSDictionary *provDict in provDictArray) {
                Province *prov = [NSObject objectOfClass:@"Province" fromJSON:provDict];
                [[DataBaseManager shareInstance] saveProvince:prov];
            }
        }
    }];
}

- (void)getCityInfo {
   NSArray *provArr = [[DataBaseManager shareInstance] provinceList];
    for (Province *prov in provArr) {
        NSDictionary *parmas = @{@"method":@"common.city.pagerbyprov",@"provcode":prov.provcode};
        [[NetAPIManager shareManager] request_get_regionInfoWithParams:parmas andBlock:^(id data, NSError *error) {
            if (data) {
                NSArray *cityDictArray = [data objectForKey:@"list"];
                for (NSDictionary *cityDict in cityDictArray) {
                    Region *region = [NSObject objectOfClass:@"Region" fromJSON:cityDict];
                    [[DataBaseManager shareInstance] saveRegion:region];
                }
            }
        }];
    }
}
@end
