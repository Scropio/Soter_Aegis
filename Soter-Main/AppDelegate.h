//
//  AppDelegate.h
//  Soter-Main
//
//  Created by Neil on 2015/5/6.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FileSystemAPI.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
//    UINavigationController *navigationController;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic) BOOL isInternet;

@property (nonatomic) UINavigationController *navigationController;


@end

