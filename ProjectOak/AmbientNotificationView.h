//
//  AmbientNotificationView.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-17.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AmbientNotificationDelegate <NSObject>
    -(void)ambientNotificationDidDissapear;
@end

enum {
    AmbientNotificationSuccess      = 0,
    AmbientNotificationProcessing   = 1,
    AmbientNotificationError        = 2,
    AmbientNotificationNetworkError = 3,
};

typedef NSUInteger AmbientNotificationType;

@interface AmbientNotificationView : UIView

@property (nonatomic, strong) id <AmbientNotificationDelegate> delegate;

-(void)showAmbientNotificationofType:(AmbientNotificationType)type WithMessage:(NSString*)msg inView:(UIView*)view andHideAfterwards:(BOOL)hide;
-(void)hideAmbientNotification;

@end
