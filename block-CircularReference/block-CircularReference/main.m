//
//  main.m
//  block-CircularReference
//
//  Created by 马天野 on 2018/9/7.
//  Copyright © 2018年 Maty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYPerson.h"

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        
        {
            TYPerson *person = [TYPerson new];
            person.age = 20;
            person.test1Block = ^{
                NSLog(@"age = %d",person.age);
            };
        }
        
        NSLog(@"-------");
        
    }

    return 0;
}
