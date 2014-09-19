//
//  AppDelegate.h
//  RetinaConverter
//
//  Created by FirstMac on 19.09.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSButton *overwriteCheckbox;
@property (weak) IBOutlet NSButton *triretinaCheckbox;
@property (weak) IBOutlet NSButton *retinaCheckbox;
@property (weak) IBOutlet NSButton *normalCheckbox;
@property (weak) IBOutlet NSComboBox *scaleComboBox;
- (IBAction)selectInputPath:(id)sender;
- (IBAction)selectOutputPath:(id)sender;
@property (weak) IBOutlet NSTextField *inputPathField;
@property (weak) IBOutlet NSTextField *outputPathField;
- (IBAction)convert:(id)sender;
@end

