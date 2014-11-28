//
//  ME_SQLMassager.m
//  IOSMirror
//
//  Created by gaoluyangrc on 14-7-14.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "ME_SQLMassager.h"
#import "RC_AppInfo.h"
#define kAppsInfoFileName @"AppsInfo"

@implementation ME_SQLMassager

+ (instancetype)shareStance
{
    static ME_SQLMassager *shareSQLMassager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSQLMassager = [[[self class] alloc] init];
    });
    
    return shareSQLMassager;
}

//会话列表
- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:kAppsInfoFileName];
}

//创建，打开数据库
- (BOOL)openDB {
	
	NSString *path = [self dataFilePath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL find = [fileManager fileExistsAtPath:path];
	
	if (find) {
        
		if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
			
			sqlite3_close(self.database);
			NSLog(@"Error: open database file.");
			return NO;
		}
		
		[self createTable:self.database];
		
		return YES;
	}
	if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
		
		[self createTable:self.database];
		return YES;
    }else {
		sqlite3_close(self.database);
		NSLog(@"Error: open database file.");
		return NO;
    }
	return NO;
}

//创建数据库
- (BOOL)createTable:(sqlite3 *)db
{
    NSString *str = @"create table if not exists appsInfoTable(ID INTEGER PRIMARY KEY AUTOINCREMENT, appCate text,appComment int,appId int,appName text,bannerUrl text,downUrl text,iconUrl text,packageName text,price text,openUrl text,appDesc text, state int)";
    const char *sql = [str UTF8String];
    
	sqlite3_stmt *statement;
	//sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
	NSInteger sqlReturn = sqlite3_prepare_v2(_database, sql, -1, &statement, nil);

	if(sqlReturn != SQLITE_OK) {
		NSLog(@"Error: failed to prepare statement:create test table");
		return NO;
	}
	
	//执行SQL语句
	int success = sqlite3_step(statement);
	//释放sqlite3_stmt
	sqlite3_finalize(statement);
	
	//执行SQL语句失败
	if ( success != SQLITE_DONE) {
		NSLog(@"Error: failed to dehydrate:create table test");
		return NO;
	}
    
	return YES;
}

- (BOOL)insertAppInfo:(NSMutableArray *)appsInfo
{
    //先判断数据库是否打开
	if ([self openDB]) {
        
        char *zErrorMsg;
        int ret;
        ret = sqlite3_exec(_database, "begin transaction" , 0 , 0 , &zErrorMsg);
        
        for (RC_AppInfo *appInfo in appsInfo) {
            //能够使用sqlite3_step()执行编译好的准备语句的指针
            
            sqlite3_stmt *statement;
            
            //这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
            NSString *str = @"INSERT INTO appsInfoTable(appCate, appComment ,appId ,appName , bannerUrl, downUrl, iconUrl, packageName, price, openUrl ,appDesc ,state) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
            const char *sql = [str UTF8String];
            
            //准备语句：第三个参数是从zSql中读取的字节数的最大值
            int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
            if (success2 != SQLITE_OK)
            {
                sqlite3_close(_database);
                return NO;
            }
            
            //这里的数字1，2，3代表第几个问号，这里将两个值绑定到两个绑定变量
            sqlite3_bind_text(statement, 1, [appInfo.appCate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int (statement, 2, appInfo.appComment);
            sqlite3_bind_int (statement, 3, appInfo.appId);
            sqlite3_bind_text(statement, 4, [appInfo.appName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [appInfo.bannerUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [appInfo.downUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 7, [appInfo.iconUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 8, [appInfo.packageName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 9, [appInfo.price UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 10, [appInfo.openUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 11, [appInfo.appDesc UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int (statement, 12, appInfo.state);
            
            //执行插入语句
            success2 = sqlite3_step(statement);
            //释放statement
            sqlite3_finalize(statement);
            
            //如果插入失败
            if (success2 == SQLITE_ERROR) {
                NSLog(@"Error: failed to insert into the database with message.");
                ret = sqlite3_exec(_database , "rollback transaction" , 0 , 0 , & zErrorMsg);
                //关闭数据库
                sqlite3_close(_database);
                return NO;
            }
        }
        
        ret = sqlite3_exec(_database , "commit transaction" , 0 , 0 , & zErrorMsg);
		sqlite3_close(_database);
        
		return YES;
	}
	return NO;
    
}

- (NSMutableArray *)getAllData
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        sqlite3_stmt *statement = nil;
        
        const char *sql = "SELECT appCate ,appComment ,appId ,appName ,bannerUrl ,downUrl ,iconUrl, packageName, price, openUrl ,appDesc,state FROM appsInfoTable";
        
        if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            return nil;
        }
        else
        {
            //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
            while (sqlite3_step(statement) == SQLITE_ROW) {
                RC_AppInfo* appInfo = [[RC_AppInfo alloc] init] ;
                
                char* appCate  = (char*)sqlite3_column_text(statement, 0);
                appInfo.appCate = [NSString stringWithUTF8String:appCate];
                
                appInfo.appComment  = sqlite3_column_int(statement,1);
                
                appInfo.appId  = sqlite3_column_int(statement,2);
                
                char* appName  = (char*)sqlite3_column_text(statement, 3);
                appInfo.appName = [NSString stringWithUTF8String:appName];
                
                char* bannerUrl  = (char*)sqlite3_column_text(statement, 4);
                appInfo.bannerUrl = [NSString stringWithUTF8String:bannerUrl];
                
                char* downUrl  = (char*)sqlite3_column_text(statement, 5);
                appInfo.downUrl = [NSString stringWithUTF8String:downUrl];
                
                char* iconUrl  = (char*)sqlite3_column_text(statement, 6);
                appInfo.iconUrl = [NSString stringWithUTF8String:iconUrl];
                
                char* packageName  = (char*)sqlite3_column_text(statement, 7);
                appInfo.packageName = [NSString stringWithUTF8String:packageName];
                
                char* price  = (char*)sqlite3_column_text(statement, 8);
                appInfo.price = [NSString stringWithUTF8String:price];
                
                char* openUrl  = (char*)sqlite3_column_text(statement, 9);
                appInfo.openUrl = [NSString stringWithUTF8String:openUrl];
                
                char* appDesc  = (char*)sqlite3_column_text(statement, 10);
                appInfo.appDesc = [NSString stringWithUTF8String:appDesc];
                
                appInfo.state  = sqlite3_column_int(statement,11);
                
                [array addObject:appInfo];
            }
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(_database);
    }
    
    return array;
}

- (BOOL)updagteAppInfo:(int)appId withIsHaveDownLoad:(int)haveDownload
{
    if ([self openDB]) {
		
		//我想下面几行已经不需要我讲解了，嘎嘎
		sqlite3_stmt *statement;
		//组织SQL语句
        NSString *str = @"UPDATE appsInfoTable SET isHave = ? WHERE appId = ?;";
		const char *sql = [str UTF8String];
		
		//将SQL语句放入sqlite3_stmt中
		int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
		if (success != SQLITE_OK) {
			sqlite3_close(_database);
			return NO;
		}
		
		//这里的数字1，2，3代表第几个问号。这里只有1个问号，这是一个相对比较简单的数据库操作，真正的项目中会远远比这个复杂
		//当掌握了原理后就不害怕复杂了
        
        sqlite3_bind_int(statement, 1, haveDownload);
		sqlite3_bind_int(statement, 2, appId);
		
		//执行SQL语句。这里是更新数据库
		success = sqlite3_step(statement);
		//释放statement
		sqlite3_finalize(statement);
		
		//如果执行失败
		if (success == SQLITE_ERROR) {
			NSLog(@"Error: failed to update the database with message.");
			//关闭数据库
			sqlite3_close(_database);
			return NO;
		}
		//执行成功后依然要关闭数据库
		sqlite3_close(_database);
		return YES;
	}
	return NO;
}

- (BOOL)deleteAllData
{
    if ([self openDB])
    {
        sqlite3_stmt *statement;
        NSString *str = @"delete from appsInfoTable";
        const char *sql = [str UTF8String];
        
        //将SQL语句放入sqlite3_stmt中
		int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success != SQLITE_OK) {
			sqlite3_close(_database);
			return NO;
		}
        
        success = sqlite3_step(statement);
		sqlite3_finalize(statement);
        
		if (success == SQLITE_ERROR) {
			sqlite3_close(_database);
			return NO;
		}
		sqlite3_close(_database);
		return YES;
    }
    
    return NO;
}

@end
