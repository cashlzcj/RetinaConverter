//
//  AppDelegate.m
//  RetinaConverter
//
//  Created by FirstMac on 19.09.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "AppDelegate.h"

typedef enum
{
    kStandard,
    kRetina,
    kTriRetina
} Resolution ;

@interface AppDelegate ()
{
    NSOpenPanel *panel;
    NSString* inputDirectory;
    NSString* outputDirectory;
    NSInteger initialFactor;
}

@property (weak) IBOutlet NSWindow *window;
@end

NSString* imageMagicPath = @"/usr/local/Cellar/imagemagick/6.8.8-9/bin/convert";


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

- (void)initInterface
{
    [self.scaleComboBox selectItemAtIndex:1];
}

- (IBAction)convert:(id)sender
{
    initialFactor = self.scaleComboBox.indexOfSelectedItem + 1;
    [self prepareOutputDirectory];
    [self sizeImages];
}

- (void)prepareOutputDirectory
{
    if (!outputDirectory || [outputDirectory isEqualToString:@""] || [outputDirectory isEqualToString:inputDirectory])
    {
        outputDirectory = [inputDirectory stringByAppendingPathComponent:@"Converted"];
        [self.outputPathField setStringValue:outputDirectory];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:outputDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:outputDirectory withIntermediateDirectories:NO attributes:nil error:nil];
}

- (void)sizeImages
{
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputDirectory error:nil];
    for (NSString* inputFilename in directoryContents)
    {
        if (self.normalCheckbox.state == NSOnState)
            [self sizeImage:inputFilename andResolution:kStandard];
        if (self.retinaCheckbox.state == NSOnState)
            [self sizeImage:inputFilename andResolution:kRetina];
        if (self.triretinaCheckbox.state == NSOnState)
            [self sizeImage:inputFilename andResolution:kTriRetina];
    }
}


- (void)sizeImage:(NSString*)filename andResolution:(Resolution)resolution
{
    NSString* inputPath = [inputDirectory stringByAppendingPathComponent:filename];
    
    NSString* resolutionAppendix = [self appendixForResolution:resolution];
    NSString* outputFilename = [self outputNameForFile:filename withAppendix:resolutionAppendix];
    NSString* outputPath = [outputDirectory stringByAppendingPathComponent:outputFilename];
    
    NSString* sizeRatio = [self sizeStringForResolution:resolution];
    
    if (self.overwriteCheckbox.state == NSOffState || [[NSFileManager defaultManager]fileExistsAtPath:outputDirectory])
    {
        [self runImageMagickWithInputPath:inputPath outputPath:outputPath sizeRatio:sizeRatio];
    }
}

- (void)runImageMagickWithInputPath: (NSString*)inputPath outputPath: (NSString*)outputPath sizeRatio:(NSString*)sizeRatio
{
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = imageMagicPath;
    task.arguments = @[inputPath, @"-strip", @"-resize", sizeRatio, outputPath];
    task.standardOutput = pipe;
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *consoleOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"Image Magick returned:\n%@", consoleOutput);
}

- (NSString*)appendixForResolution:(Resolution)resolution
{
    NSString* appendix;
    switch (resolution)
    {
        case kTriRetina:
            appendix = @"@3x";
            break;
        case kRetina:
            appendix = @"@2x";
            break;
        default:
            appendix = @"";
            break;
    }
    return appendix;
}

- (NSString*)sizeStringForResolution:(Resolution)resolution
{
    CGFloat k;
    switch (resolution)
    {
        case kTriRetina:
            k = 3;
            break;
        case kRetina:
            k = 2;
            break;
        default:
            k = 1;
            break;
    }
    return [NSString stringWithFormat:@"%.0f%%", k / initialFactor * 100];
}

- (NSString*)outputNameForFile:(NSString*)name withAppendix:(NSString*)appendix
{
    NSString* pureName = [name stringByDeletingPathExtension];
    NSString* stringWithoutAppendix = [[pureName componentsSeparatedByString:@"@"] firstObject];
    NSString* stringWithAppendix = [stringWithoutAppendix stringByAppendingString:appendix];
    return [stringWithAppendix stringByAppendingPathExtension:@"png"];
}

- (NSInteger)showPanel
{
    panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    return [panel runModal];
}

- (IBAction)selectInputPath:(id)sender
{
    NSInteger clicked = [self showPanel];
    if (clicked == NSFileHandlingPanelOKButton)
    {
        if ([panel URLs].count > 0)
        {
            inputDirectory = ((NSURL*)[[panel URLs]firstObject]).path;
            [self.inputPathField setStringValue:inputDirectory];
            
            if (!outputDirectory || [outputDirectory isEqualToString:@""] || [outputDirectory isEqualToString:inputDirectory])
            {
                outputDirectory = [inputDirectory stringByAppendingPathComponent:@"Converted"];
                [self.outputPathField setStringValue:outputDirectory];
            }
        }
    }
}

- (IBAction)selectOutputPath:(id)sender
{
    NSInteger clicked = [self showPanel];
    if (clicked == NSFileHandlingPanelOKButton)
    {
        if ([panel URLs].count > 0)
        {
            outputDirectory = ((NSURL*)[[panel URLs]firstObject]).path;
            [self.outputPathField setStringValue:inputDirectory];
        }
    }
}
@end