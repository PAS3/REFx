//
//  RXRailsController.m
//  REFx
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "RXRailsController.h"



@implementation RXRailsController

@synthesize railsRootDirectory;
@synthesize runningRailsPort;


- (id)initWithRailsRootDir: (NSString*)dir {
    self = [super init];
    
    if (self) {
        self.railsRootDirectory = [dir copy];
        //NSLog(@"init railscontroller with dir %@", railsRootDirectory);
    }
    
    return self;
}

// startComServer starts a RAILS instance at a specific port
- (void)startComServer:(NSString*)railsPort :(NSString*)environment
{
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"useNewWebserver"]) {
        NSLog(@"Not starting communication... the new server is running");

        return;
    }
    
    NSLog(@"start communication server ...");
   
    if(comServerRunning == NO)
    {        
        
        
        NSLog(@"start communication server %@",railsRootDirectory);

        NSString *railsCommand = [NSString stringWithFormat:@"%@/script/server", railsRootDirectory];
        
        if(![railsPort intValue]) {
            NSLog(@"ERROR: No port set");
        }
        
        runningRailsPort = [NSString stringWithFormat:@"%li", [[NSUserDefaults standardUserDefaults] integerForKey:@"listenPort"]];
        
        NSString *railsEnvironment = [NSString stringWithFormat:@"--environment=%@", environment];

        comServerProcess = [[NSTask alloc] init];    
        
        [comServerProcess setCurrentDirectoryPath:railsRootDirectory];
        [comServerProcess setLaunchPath: railsCommand];
        [comServerProcess setArguments: [NSArray arrayWithObjects: @"webrick", @"--port", railsPort,railsEnvironment,nil]];
        
        comServerRunning = YES;
        [comServerProcess launch];
    }
}


// stopComServer stops a RAILS instance at a specific port by calling the terminator script
- (void)stopComServer
{
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"useNewWebserver"]) {
        NSLog(@"Not stopping communication... the new server is running");
        return;
    }
    
    NSString * railsPort =[NSString stringWithFormat:@"%li", [[NSUserDefaults standardUserDefaults] integerForKey:@"listenPort"]];
    NSString *terminatePath = [NSString stringWithFormat:@"%@/Contents/Resources/",[[NSBundle mainBundle] bundlePath]];
    NSLog(@"term path: %@",terminatePath);
    
    NSString *terminateCommand = [NSString stringWithFormat:@"%@railsTerminator.rb", terminatePath];
    
    NSLog(@"term cmd: %@",terminateCommand);
    
    NSTask *terminatebProcess = [[NSTask alloc] init];    
    [terminatebProcess setCurrentDirectoryPath:terminatePath];
    [terminatebProcess setLaunchPath: terminateCommand];
    [terminatebProcess setArguments: [NSArray arrayWithObjects:@"-p",railsPort,nil]];
    [terminatebProcess launch];        
    
    [terminatebProcess waitUntilExit];
    int status = [terminatebProcess terminationStatus];
    
    if (status == 0){
        NSLog(@"Task succeeded.");
        comServerRunning = NO;
    }
    else NSLog(@"Task failed.");
}




@end
