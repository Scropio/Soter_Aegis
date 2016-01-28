//
//  Database.m
//  DBHelper
//
//  Created by Neil on 2015/5/13.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "Database.h"

@implementation Database

NSString *dbName = @"SoterAccount.sqlite";
sqlite3 *database = nil;

- (BOOL)open{
    NSArray *dbFolderPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbFilePath = [[dbFolderPath objectAtIndex:0] stringByAppendingPathComponent:dbName];
    
    return (sqlite3_open([dbFilePath UTF8String], &database) == SQLITE_OK);
}

- (void)close{
    if (database != nil) {
        sqlite3_close(database);
    }
}

- (void)initialized{
    if (database == nil)
    {
        return;
    }
    
    //CREATE TABLE SCHEMA FOR USERACCOUNG
    NSString *UserAccount = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",    @"CREATE TABLE IF NOT EXISTS `UserAccount` (",
                                                                                @"ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,",
                                                                                @"Name VARCHAR(100),",
                                                                                @"Username VARCHAR(100),",
                                                                                @"Password VARCHAR(100),",
                                                                                @"Comment TEXT)"];

    [self CreateTable:@"UserAccount" SqlSchema:UserAccount];
    
    //CREATE TABLE SCHEMA FOR SERVICECATEGORY
    NSString *ServiceCategory = [NSString stringWithFormat:@"%@ %@ %@ %@", @"CREATE TABLE IF NOT EXISTS `ServiceCategory` (",
                                                                           @"ID INTEGER PRIMARY KEY AUTOINCREMENT,",
                                                                           @"Name VARCHAR(100),",
                                                                           @"Pic VARCHAR(100))"];

    
    [self CreateTable:@"ServiceCategory" SqlSchema:ServiceCategory];
}

- (void)CreateTable:(NSString *)TableName SqlSchema:(NSString *)Schema
{
    const char *CreateSchema = [Schema UTF8String];
    char *errorMsg;
    
    if (sqlite3_exec(database, CreateSchema, NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_free(errorMsg);
    }
    else
    {
        NSLog(@"%@",[NSString stringWithFormat:@"CREATE TABLE %@ SUCCESS",TableName]);
    }
    
}

- (void)insertData:(NSString *)_Name Username:(NSString *)_Username Password:(NSString *)_Password Comment:(NSString *)_Comment
{
    char *errorMsg;
    if (database != nil) {
        NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO UserAccount (Name,Username,Password,Comment) values ('%@','%@','%@','%@')", _Name,_Username,_Password,_Comment];
        const char *insertSQL = [sqlString UTF8String];
        if (sqlite3_exec(database, insertSQL, NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"error: %s", errorMsg);
            sqlite3_free(errorMsg);
        }
        else
        {
            NSLog(@"SUCCESS: %@",sqlString);
        }
    }
    else
    {
        NSLog(@"Database optional");
    }
}

- (void)updataData:(NSString *)_ID ServiceName:(NSString *)_ServiceName Username:(NSString *)_Username Password:(NSString *)_Password Comment:(NSString *)_Comment
{
    char *errorMsg;
    if (database != nil) {
        
        NSString *sqlString = [NSString stringWithFormat:@"UPDATE UserAccount Set Name='%@',Username='%@',Password='%@',Comment='%@' WHERE ID='%@'",_ServiceName,_Username,_Password,_Comment,_ID];
        const char *updateSQL = [sqlString UTF8String];
        if (sqlite3_exec(database, updateSQL, NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"error: %s", errorMsg);
            sqlite3_free(errorMsg);
        }
        else
        {
            NSLog(@"SUCCESS: %@",sqlString);
        }
    }
}

- (NSArray*)selectData{
    NSMutableArray *DataArray = [[NSMutableArray alloc] init];
    Account *current = [[Account alloc]init];
    
    if (database != nil)
    {
        sqlite3_stmt *statement = nil;
        const char *selectSQL = [@"SELECT * FROM UserAccount" UTF8String];
        
        NSLog(@"%d",sqlite3_prepare_v2(database, selectSQL, -1, &statement, NULL));
        
        if (sqlite3_prepare_v2(database, selectSQL, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                current = [[Account alloc] init];
                
                current.ID       = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                current.Name     = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                current.Username = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                current.Password = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                current.Comment  = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                
                [DataArray addObject:current];
            }
        }
        sqlite3_finalize(statement);
    }
    return [NSArray arrayWithArray:DataArray];
}

- (NSArray*)selectData:(NSString *)_Table Name:(NSString *)_Name{
    NSMutableArray *DataArray = [[NSMutableArray alloc] init];
    if (database != nil) {
        sqlite3_stmt *statement = nil;
//        NSString *qSQL = [[NSString initWithFormat:[@"SELECT * FROM %@ WHERE Name ='%@'",_Table,_Name]];
        NSString *qSQL = [NSString stringWithFormat:@"SELECT * FROM dbname.sqlite_master WHERE type='table';"];
//        NSString *qSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE Name = '%@'",_Table,_Name];
        const char *selectSQL = [qSQL UTF8String];
        if (sqlite3_prepare_v2(database, selectSQL, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *data = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                [DataArray addObject:data];
            }
        }
        sqlite3_finalize(statement);
    }
    return [NSArray arrayWithArray:DataArray];
}

- (void)deleteData{
    char *errorMsg;
    if (database != nil) {
        const char *insertSQL = [@"DELETE FROM UserAccount" UTF8String];
        if (sqlite3_exec(database, insertSQL, NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"error: %s", errorMsg);
            sqlite3_free(errorMsg);
        }
    }
}

- (void)deleteData:(NSString *)_ID
{
    char *errorMsg;
    if (database != nil) {
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM UserAccount WHERE ID='%@'",_ID];
        const char *insertSQL = [SQL UTF8String];
        if (sqlite3_exec(database, insertSQL, NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"error: %s", errorMsg);
            sqlite3_free(errorMsg);
        }
    }
}

@end
