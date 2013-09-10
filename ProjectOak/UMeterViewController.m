//
//  UMeterViewController.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import "UMeterViewController.h"
#import "CPTTestAppScatterPlotView.h"
#import "CourseObject.h"
#import "AmbientNotificationView.h"

#import "UIView+SwipeTransitionLeftRight.h"
#import "UIColor+HexToRGB.h"
#import "NSString+TimeStamp.h"

#define NO_IDEA_TEXT NSLocalizedString(@"No Idea", @"No Idea")
#define PERFECT_TEXT NSLocalizedString(@"Perfect!", @"Perfect!")
#define CLASS_UNDERSTANDING_TEXT NSLocalizedString(@"Class Understanding", @"Class Understanding")
#define UNDERSTANDING_TEXT NSLocalizedString(@"Your Understanding", @"Your Understanding")
#define LAST_VOTE_TEXT NSLocalizedString(@"Last Vote: %@ ago",@"Last Vote: %@ ago")

#define NETWORK_ERROR NSLocalizedString(@"No Network Connection", @"No Network Connection")

#define SIDE_MARGIN_FOR_SLIDER 15.0f
#define SLIDER_HEIGHT 25.0f
#define SLIDER_LABEL_MARGIN 5.0f

#define GUIDE_FONT_SIZE 18.0f
#define SLIDER_FONT_SIZE 15.0f
#define LAST_VOTE_FONT_SIZE 12.0f

#define HEIGHT_OF_GRAPH 250.0f

#define LABEL_VERTICAL_MARGIN 5.0f
#define LABEL_HORIZONTAL_MARGIN 10.0f

#define VOTE_COUNTDOWN 3.0f

@implementation UMeterViewController
{
    BOOL isFirstLoad;
    
    UISlider *understandingSlider;
    UILabel *guidelinesLabel;
    UILabel *classUnderstandingLabel;
    UILabel *goodUnderstandingLabel;
    UILabel *badUnderstandingLabel;
    UILabel *lastVoteLabel;
    UIView *lowerBar;
    UIView *classLowerBar;
    
    NSTimer *sliderTimer;
    
    CPTTestAppScatterPlotView *plotView;
    
    AmbientNotificationView *ambientNotification;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

// The frame parameter is not completely updated in viewWillAppear, so viewDidAppear must be used. The only
//reason why both are used is to make the "glitchy" transaction seem smaller than it actually is on screen.
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CourseObjectNetworkConnectionError object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectionError:) name:CourseObjectNetworkConnectionError object:nil];
    
    if (!isFirstLoad) {
        return;
    }
    [self setUpFrameLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!isFirstLoad) {
        isFirstLoad = NO;
        return;
    }
    [self setUpFrameLayout];
}

-(void)prepareForUseWithCourse:(CourseObject*)course
{
    [self setCourse:course];
    [plotView prepareForUseWithCourse:course];
    [understandingSlider setValue: course.lastVoteValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:plotView selector:@selector(updateGraph) name:DidFinishLoadingPlotDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLastVoteLabel) name:DidFinishLoadingPlotDataNotification object:nil];
}

-(void)stopCourseUse
{
    [plotView stopCourseUse];
    
    [[NSNotificationCenter defaultCenter] removeObserver:plotView name:DidFinishLoadingPlotDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFinishLoadingPlotDataNotification object:nil];
}

-(void) setUpFrameLayout
{
    CGSize labelSize = [guidelinesLabel.text sizeWithFont:guidelinesLabel.font];
    [classUnderstandingLabel setFrame:CGRectMake(LABEL_HORIZONTAL_MARGIN, LABEL_VERTICAL_MARGIN, self.view.frame.size.width - LABEL_HORIZONTAL_MARGIN * 2, labelSize.height)];
    [classLowerBar setFrame: CGRectMake(0, classUnderstandingLabel.frame.origin.y + classUnderstandingLabel.frame.size.height, self.view.frame.size.width, LOWER_BAR_HEIGHT)];
    
    CGSize lastSize = [lastVoteLabel.text sizeWithFont:lastVoteLabel.font];
    [lastVoteLabel setFrame:CGRectMake(0, self.view.frame.size.height - lastSize.height, self.view.frame.size.width, lastSize.height)];
    
    CGSize yesSize = [goodUnderstandingLabel.text sizeWithFont:goodUnderstandingLabel.font];
    CGSize noSize = [badUnderstandingLabel.text sizeWithFont:badUnderstandingLabel.font];
    [understandingSlider setFrame:CGRectMake(SIDE_MARGIN_FOR_SLIDER, lastVoteLabel.frame.origin.y - SLIDER_HEIGHT * 1.5, self.view.frame.size.width - SIDE_MARGIN_FOR_SLIDER * 2, SLIDER_HEIGHT)];
    [goodUnderstandingLabel setFrame:CGRectMake(SLIDER_LABEL_MARGIN, understandingSlider.frame.origin.y + SLIDER_HEIGHT, yesSize.width, yesSize.height)];
    [badUnderstandingLabel setFrame:CGRectMake(self.view.frame.size.width - noSize.width - SLIDER_LABEL_MARGIN, understandingSlider.frame.origin.y + SLIDER_HEIGHT, noSize.width, noSize.height)];
    
    [guidelinesLabel setFrame:CGRectMake(LABEL_HORIZONTAL_MARGIN, understandingSlider.frame.origin.y - labelSize.height - LABEL_VERTICAL_MARGIN, self.view.frame.size.width - LABEL_HORIZONTAL_MARGIN * 2, labelSize.height)];
    [lowerBar setFrame: CGRectMake(0, guidelinesLabel.frame.origin.y + guidelinesLabel.frame.size.height, self.view.frame.size.width, LOWER_BAR_HEIGHT)];
    
    [plotView setFrame:CGRectMake(0, classUnderstandingLabel.frame.origin.y + classUnderstandingLabel.frame.size.height, self.view.frame.size.width, guidelinesLabel.frame.origin.y - classUnderstandingLabel.frame.size.height - classUnderstandingLabel.frame.origin.y)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
 
    isFirstLoad = YES;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];

    plotView = [[CPTTestAppScatterPlotView alloc] init];
    
    understandingSlider = [[UISlider alloc] init];
    understandingSlider.minimumValue = 0.0f;
    understandingSlider.maximumValue = 100.0f;
    understandingSlider.value = -1;
    [understandingSlider setThumbTintColor:[UIColor colorWithHexString:LOGO_CYAN]];
    [understandingSlider setMinimumTrackTintColor:[UIColor colorWithHexString:LOGO_CYAN]];
    
    goodUnderstandingLabel = [[UILabel alloc] init];
    [goodUnderstandingLabel setText:NO_IDEA_TEXT];
    [goodUnderstandingLabel setTextAlignment:NSTextAlignmentCenter];
    [goodUnderstandingLabel setFont:[UIFont boldSystemFontOfSize:SLIDER_FONT_SIZE]];
    [goodUnderstandingLabel setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    [goodUnderstandingLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
    
    badUnderstandingLabel = [[UILabel alloc] init];
    [badUnderstandingLabel setText:PERFECT_TEXT];
    [badUnderstandingLabel setTextAlignment:NSTextAlignmentCenter];
    [badUnderstandingLabel setFont:[UIFont boldSystemFontOfSize:SLIDER_FONT_SIZE]];
    [badUnderstandingLabel setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    [badUnderstandingLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
 
    classUnderstandingLabel = [[UILabel alloc] init];
    [classUnderstandingLabel setText:CLASS_UNDERSTANDING_TEXT];
    [classUnderstandingLabel setFont:[UIFont boldSystemFontOfSize:GUIDE_FONT_SIZE]];
    [classUnderstandingLabel setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    [classUnderstandingLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
    
    classLowerBar = [[UIView alloc] init];
    [classLowerBar setBackgroundColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    
    guidelinesLabel = [[UILabel alloc] init];
    [guidelinesLabel setText:UNDERSTANDING_TEXT];
    [guidelinesLabel setFont:[UIFont boldSystemFontOfSize:GUIDE_FONT_SIZE]];
    [guidelinesLabel setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    [guidelinesLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
    
    lowerBar = [[UIView alloc] init];
    [lowerBar setBackgroundColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    
    lastVoteLabel = [[UILabel alloc] init];
    [lastVoteLabel setText:[NSString stringWithFormat:LAST_VOTE_TEXT, @"5 Minutes"]];
    [lastVoteLabel setTextAlignment:NSTextAlignmentCenter];
    [lastVoteLabel setFont:[UIFont boldSystemFontOfSize:LAST_VOTE_FONT_SIZE]];
    [lastVoteLabel setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    [lastVoteLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
    
    [understandingSlider addTarget:self action:@selector(didFinishMovingSlider:) forControlEvents:UIControlEventValueChanged];
    
    ambientNotification = [[AmbientNotificationView alloc] init];
    
    [self.view addSubview:plotView];
    [self.view addSubview:classUnderstandingLabel];
    [self.view addSubview:guidelinesLabel];
    [self.view addSubview:classLowerBar];
    [self.view addSubview:lowerBar];
    [self.view addSubview:lastVoteLabel];
    [self.view addSubview:goodUnderstandingLabel];
    [self.view addSubview:badUnderstandingLabel];
    [self.view addSubview:understandingSlider];
    
}

-(void) swipeLeft:(id)sender
{
    NSInteger selectedIndex = [self.tabBarController selectedIndex];
    
    UIView *fromView = self.tabBarController.selectedViewController.view;
    UIView *toView = [[self.tabBarController.viewControllers objectAtIndex:selectedIndex + 1] view];
    
    [UIView swipeFromView:fromView toView:toView duration:0.5f options:UIViewAnimationOptionSwipeLeft completion:^(BOOL finished) {
        [self.tabBarController setSelectedIndex:selectedIndex + 1];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)updateLastVoteLabel
{
    if (![sliderTimer isValid]) {
        [lastVoteLabel setText:[NSString stringWithFormat:LAST_VOTE_TEXT, [NSString generateTimeStamp:[_course timeLastVoted]]]];
        [understandingSlider setValue: _course.lastVoteValue];
    }
}

-(void)networkConnectionError:(NSNotification *)notification
{
    [ambientNotification showAmbientNotificationofType:AmbientNotificationNetworkError WithMessage:NETWORK_ERROR inView:self.view andHideAfterwards:YES];
}


#pragma mark Timer Control

-(void)didFinishMovingSlider:(id)sender
{
    [sliderTimer invalidate];
    
    sliderTimer = [NSTimer scheduledTimerWithTimeInterval: VOTE_COUNTDOWN target: self selector: @selector(sendVote) userInfo: nil repeats: NO];
    
    [lastVoteLabel setText:[NSString stringWithFormat:LAST_VOTE_TEXT, @"0m"]];
}

-(void)sendVote
{
    [_course voteCourse:(NSInteger)(understandingSlider.value)];
}

@end
