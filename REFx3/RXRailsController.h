//
//  RXRailsController.h
//  REFx
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RXRailsController : NSObject{
    NSTask *comServerProcess;
    BOOL comServerRunning;
}

- (id)initWithRailsRootDir: (NSString *)dir;
- (void)startComServer:(NSString*)railsPort :(NSString*)environment;
- (void)stopComServer;

@property (retain) NSString *railsRootDirectory;
@property (assign) NSString *runningRailsPort;

@end
