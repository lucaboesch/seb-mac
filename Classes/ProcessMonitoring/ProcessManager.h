//
//  ProcessManager.h
//  Safe Exam Browser
//
//  Created by Daniel R. Schneider on 07.07.20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProcessManager : NSObject

@property (strong, nonatomic) NSMutableArray *prohibitedRunningApplications;
@property (strong, nonatomic) NSMutableArray *permittedRunningApplications;
@property (strong, nonatomic) NSMutableArray *prohibitedBSDProcesses;
@property (strong, nonatomic) NSMutableArray *permittedBSDProcesses;

@end

NS_ASSUME_NONNULL_END
