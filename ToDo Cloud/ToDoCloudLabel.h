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

typedef struct {
    int    x;
    int    y;
} Direction;

@interface ToDoCloudLabel : UILabel <NSCoding, UIActionSheetDelegate>{
    CGPoint currentPoint;
    CGRect previousPosition;
}
@property (nonatomic, assign) CGPoint visualCenter;
@property (nonatomic, assign) Direction lastPushedDirection;
@property (nonatomic, assign) CGRect anchor;

- (id)initWithText: (NSString *)text center:(CGPoint)center;
- (id)initAtCenterWithText: (NSString *)text withVisualCenter:(CGPoint)visualCenter;

- (Direction)pushDirectionFor:(ToDoCloudLabel *)pushedLabel;

- (CGPoint)getShift;
- (CGRect)anchoredFrame;

- (void)moveToCenter;
- (void)boundedShiftBy:(CGPoint)shiftFactor;
- (void)boundedMoveToNewCenter:(CGPoint)newPoint;
- (void)snapToAnchor;
- (void)updateFontSize;


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
