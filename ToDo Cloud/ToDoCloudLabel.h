//
//  ToDoCloudLabel.h
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/9/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "AUIAnimatableLabel.h"

#define MINIMUM_FONT_SIZE   8
#define MAXIMUM_FONT_SIZE   20
#define FONT_RESIZE_FACTOR  12.5

@interface ToDoCloudLabel : UILabel {
    CGPoint currentPoint;
}
@property (nonatomic, assign) CGPoint visualCenter;
- (id)initWithFrame:(CGRect)frame visualCenter:(CGPoint)visualCenter;
- (void)moveToCenter;
@end
