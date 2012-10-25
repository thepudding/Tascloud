//
//  ToDoCloudLabel.h
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/9/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//
#import "utils.h"

#define MINIMUM_FONT_SIZE   20
#define MAXIMUM_FONT_SIZE   40
#define FONT_RESIZE_FACTOR  12.5

@interface ToDoCloudLabel : UILabel <NSCoding>{
    CGPoint currentPoint;
}
@property (nonatomic, assign) CGPoint visualCenter;
@property (nonatomic,  readwrite) CGPoint velocity;
- (id)initWithFrame:(CGRect)frame visualCenter:(CGPoint)visualCenter;
- (void)checkAndUpdateOverlappingLabelsExcluding:(NSMutableArray *)exclude;
- (void)checkAndUpdateOverlappingLabels;
- (void)moveToCenter;
- (void)updateFontSize;
@end
