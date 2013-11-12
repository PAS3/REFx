//
//  RXJobPicker.h
//  REFx4
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include <sqlite3.h>
#import "VDKQueue.h"

@interface RXJobPicker : NSObject <VDKQueueDelegate> {

    BOOL jobRunning;
    BOOL loopIsEnabled;
    NSString* railsRootDir;
    NSString* railsDbPath;
    NSString* railsEnvironment;

    NSTask *rubyJobProcess;
    

}
@property (retain) NSTimer *refxTimer;
@property (retain) NSTimer *refxSafetyTimer;



- (id)initWithDbPath: dbPath railsRootDir: dir environment:(NSString*) env;

- (void) loopSingleAction;
- (void) setJobId:(NSInteger)rowId status:(NSInteger)status;
- (int)  selectJob;
- (void) flushAllJobs;
- (void) startREFxLoop;
- (void) stopREFxLoop;
- (void) startREFxLoopAction;
- (void) stopREFxLoopAction;
- (void) setJobsLastId:(NSInteger)rowId;
- (long) insertTestJobwithEngine:(NSString*)engine body:(NSString*)body;



@end
