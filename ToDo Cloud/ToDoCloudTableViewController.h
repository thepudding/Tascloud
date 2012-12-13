//
//  ToDoCloudTableViewController.h
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 11/6/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToDoCloudTableViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *taskTable;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolbarTitle;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) BOOL editing;
- (IBAction)dismissTable:(id)sender;
- (IBAction)editTasks:(id)sender;

@end
