//
//  AppDelegate.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-24.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import "AppDelegate.h"
#import "CoursesViewController.h"

#import "UIColor+HexToRGB.h"
#import "NSURL+Parameters.h"

#define NAV_BAR_TINT_COLOR @"2B78D0"

#define SERVER_ROOT @"http://oak-server.amandeep.ca/"
#define VALIDATE_BETA @"ValidateBetaKey"
#define VALIDATE_BETA_CODE_PARAMETER @"betaCode"
#define CODE @"MADD Trial"
#define IS_BETA @"IsBetaMode"

@implementation AppDelegate
{
    UITabBarController *tabBarController;
    UITextField *textfieldPassword;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:NAV_BAR_TINT_COLOR]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];

    _courses = [[CoursesViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_courses];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isBetaTester"]) {
        [self checkIfBeta];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)checkIfBeta
{
    NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,IS_BETA]];
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str isEqualToString:@"0"]) {
        return;
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beta Testing" message:@"Please enter a password to become a beta tester of Project Oak:"
                                                       delegate:self cancelButtonTitle:nil  otherButtonTitles:@"Submit", nil];

        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert setDelegate:self];
        [alert show];

    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *params = @{VALIDATE_BETA_CODE_PARAMETER : [alertView textFieldAtIndex:0].text};
    NSURL *url  = [NSURL URLWithRoot:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,VALIDATE_BETA] withParameters:params];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (![str isEqualToString:@"0"]) {
        [[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"isBetaTester"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    } else {
        [self checkIfBeta];

    }


}

@end
