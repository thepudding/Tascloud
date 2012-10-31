//
//  ToDoCloudDeleteActionDelegate.h
//  ToDo Cloud
//
//  Created by Jordan Bargas on 10/30/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoCloudDeleteActionDelegate : NSObject <UIActionSheetDelegate>

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
