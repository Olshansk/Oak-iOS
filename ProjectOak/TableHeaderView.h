//
//  TableHeaderView.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-31.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableHeaderView : UIView

- (id)initWithFrame:(CGRect)frame andLabelText:(NSString*)str;

-(void)startedLoadingData;
-(void)finishedLoadingData;

@end
