//
//  UITableViewCell+ClearForReuse.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-03.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (ClearForReuse)

+(void)clearCellContentViewForReuse:(UITableViewCell*)cell;

@end
