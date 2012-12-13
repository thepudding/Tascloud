//
//  ToDoCloudTableViewController.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 11/6/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudTableViewController.h"

@implementation ToDoCloudTableViewController
@synthesize editing;

- (IBAction)dismissTable:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)editTasks:(id)sender {
    if(self.editing) {
        self.editing = false;
        [self showDoneButton];
        self.editButton.style = UIBarButtonItemStyleBordered;
        self.editButton.title = NSLocalizedString(@"Edit", @"Edit");
        self.toolbarTitle.title = @"Completed Tasks";
        [self.taskTable setEditing:false animated:YES];

    } else {
        self.editing = true;
        [self hideDoneButton];
        self.editButton.style = UIBarButtonItemStyleDone;
        self.editButton.title = NSLocalizedString(@"Done", @"Done");
        self.toolbarTitle.title = @"Edit Completed Tasks";
        [self.taskTable setEditing:editing animated:YES];

    }
}

-(void)showDoneButton {
    [self.toolbar setItems:[self.toolbar.items arrayByAddingObject:self.doneButton]];
}
-(void)hideDoneButton {
    [self.toolbar setItems:
     [self.toolbar.items filteredArrayUsingPredicate:
      [NSPredicate predicateWithBlock:^BOOL (id evaluatedObject, NSDictionary *bindings) {
         return [evaluatedObject tag] != 777;
     }]]];
}
@end
