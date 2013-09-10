//
//  UITableViewCell+ClearForReuse.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-03.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import "UITableViewCell+ClearForReuse.h"

@implementation UITableViewCell (ClearForReuse)

+(void)clearCellContentViewForReuse:(UITableViewCell*)cell
{
    for (UIView *view in [[cell contentView] subviews]) {
        [view removeFromSuperview];
    }
}

@end
