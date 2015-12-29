//
//  main.m
//  SnubCommand
//
//  Created by Ashok Gelal on 10/18/15.
//  Copyright © 2015 Ashok Gelal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SnubCore;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[Bootstrapper sharedInstance] setupForCommandLine];
    }
    return 0;
}
