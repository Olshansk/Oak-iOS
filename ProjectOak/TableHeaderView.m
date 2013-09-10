//
//  TableHeaderView.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-31.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import "TableHeaderView.h"
#import "UIColor+HexToRGB.h"

#define SECTION_HEADER_FONT_SIZE 16.0f
#define SECTION_LABEL_MARGINS 5.0f

#define ACTIVITY_INDICATOR_VERTICAL_MARGIN 8.0f
#define ACTIVITY_INDICATOR_HORIZONTAL_MARGIN 10.0f

@implementation TableHeaderView
{
    UIActivityIndicatorView *activityIndicator;
}

- (id)initWithFrame:(CGRect)frame andLabelText:(NSString*)str
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithHexString:LIGHT_GRAY_BACKGROUND_COLOR]];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator setHidesWhenStopped:YES];
        [activityIndicator setFrame:CGRectMake(frame.size.width - activityIndicator.frame.size.width - ACTIVITY_INDICATOR_HORIZONTAL_MARGIN, frame.size.height - activityIndicator.frame.size.height - ACTIVITY_INDICATOR_VERTICAL_MARGIN , activityIndicator.frame.size.width, activityIndicator.frame.size.height)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SECTION_LABEL_MARGINS, SECTION_LABEL_MARGINS, frame.size.width - SECTION_LABEL_MARGINS * 2, HEADER_VIEW_HEIGHT - SECTION_LABEL_MARGINS * 2)];
        [label setFont:[UIFont boldSystemFontOfSize:SECTION_HEADER_FONT_SIZE]];
        [label setCenter:self.center];
        [label setBackgroundColor:[UIColor colorWithHexString:LIGHT_GRAY_BACKGROUND_COLOR]];
        [label setText:str];
        [label setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
        
        UIView *lowerBar = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_VIEW_HEIGHT - LOWER_BAR_HEIGHT, frame.size.width, LOWER_BAR_HEIGHT)];
        [lowerBar setBackgroundColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
        
        [self addSubview:label];
        [self addSubview:lowerBar];
        [self addSubview:activityIndicator];

    }
    return self;
}

-(void)startedLoadingData
{
    [activityIndicator startAnimating];
}
-(void)finishedLoadingData;
{
    [activityIndicator stopAnimating];
}

@end
