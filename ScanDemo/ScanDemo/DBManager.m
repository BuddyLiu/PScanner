//
//  DBManager.m
//  PLFMDBTest
//
//  Created by Paul on 11/29/16.
//  Copyright © 2016 Paul. All rights reserved.
//

#import "DBManager.h"
#import<objc/runtime.h>

@interface DBManager()

@property(nonatomic, strong) NSLock *lock;

@end

@implementation DBManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

+(DBManager *)sharedManager
{
    static DBManager *manager = nil;
    @synchronized(self){
        if(manager == nil)
        {
            manager=[[DBManager alloc] init];
        }
    }
    return manager;
}

-(BOOL)createDatabaseWithName:(NSString *)dbName
{
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath   = [docsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", (dbName != nil)?([dbName isEqualToString:@""]?@"default.db":dbName):@"default.db"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
        [[NSFileManager defaultManager] createFileAtPath:dbPath contents:nil attributes:nil];
    }
    [DBManager sharedManager].database = [FMDatabase databaseWithPath:dbPath];
    if ([[DBManager sharedManager].database open])
    {
        [[DBManager sharedManager].database close];
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)insertDataToDatabase:(NSString *)dbName tableName:(NSString *)tbName model:(id)model
{
    //操作之间对数据库加锁
    [_lock lock];
    [self createDatabaseWithName:dbName];
    [[DBManager sharedManager].database open];
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"insert into %@(", tbName];
    NSDictionary *proDic = [self getAllPropertiesFromClass:model];
    for (int i = 0; i<[proDic allKeys].count; i++)
    {
        if(i == 0)
        {
            [sql appendString:[NSString stringWithFormat:@"%@", [self translateToInsertName:[proDic allKeys][i]]]];
        }
        else
        {
            [sql appendString:[NSString stringWithFormat:@",%@", [self translateToInsertName:[proDic allKeys][i]]]];
        }
    }
    [sql appendString:@")values("];
    for (int i = 0; i<[proDic allKeys].count; i++)
    {
        if(i == 0)
        {
            [sql appendString:[NSString stringWithFormat:@"'%@'",[model valueForKey:[proDic allKeys][i]]]];
        }
        else
        {
            [sql appendString:[NSString stringWithFormat:@",'%@'",[model valueForKey:[proDic allKeys][i]]]];
        }
    }
    [sql appendString:@")"];
    //参数必须是id,存储时自动转换为相应的类型
    BOOL ret=[[DBManager sharedManager].database executeUpdate:sql];
    if(!ret)
    {
        NSLog(@"insert error!");
    }
    else
    {
        NSLog(@"insert success!");
    }
    [[DBManager sharedManager].database close];

    [_lock unlock];
}

-(void)deleteDataFromDatabase:(NSString *)dbName tableName:(NSString *)tbName model:(id)model
{
    [_lock lock];
    [self createDatabaseWithName:dbName];
    [[DBManager sharedManager].database open];
    NSDictionary *proDic = [self getAllPropertiesFromClass:model];

    [_lock unlock];
    NSArray *arr = [self fetchAllDataFromDataBaseName:dbName tableName:tbName];
    [_lock lock];
    
    NSString *modelId = @"";
    for (NSDictionary *dic in arr)
    {
        NSInteger count = 0;
        for(NSString *proName in [proDic allKeys])
        {
            if(![proName isEqualToString:@"id"])
            {
                if([[model valueForKey:proName] isEqual:dic[proName]])
                {
                    count++;
                }
            }
        }
        if(count == [proDic allKeys].count)
        {
            modelId = dic[@"id"];
            break;
        }
    }

    [[DBManager sharedManager].database open];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where id='%@'",
                     tbName, modelId];
    BOOL ret = [[DBManager sharedManager].database executeUpdate:sql, @""];
    if(!ret)
    {
        NSLog(@"delete error!");
    }
    else
    {
        NSLog(@"delete success!");
    }
    
    [[DBManager sharedManager].database close];
    [_lock unlock];
}

-(BOOL)addTableToDatabase:(NSString *)dbName withTBName:(NSString *)tbName model:(id)model
{
    //操作之间对数据库加锁
    [_lock lock];
    
    [[DBManager sharedManager].database open];
    BOOL state = nil;
    if([[DBManager sharedManager].database open])
    {
        NSLog(@"database can open.");
        //创建数据表，图片采用blob类型
        NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"create table if not exists %@(id integer primary key autoincrement", tbName];
        NSDictionary *proDic = [self getAllPropertiesFromClass:model];
        for(NSString *proName in [proDic allKeys])
        {
            [sql appendString:[NSString stringWithFormat:@",%@ varchar(128)",[self translateToInsertName:proName]]];
        }
        [sql appendString:@")"];
        
        //执行sql语句创建数据表
        state = [[DBManager sharedManager].database executeUpdate:sql];
        if(!state)
        {
            NSLog(@"create table error!");
        }
        else
        {
            NSLog(@"create table success!");
        }
    }
    else
    {
        NSLog(@"database can't open.");
    }
    [[DBManager sharedManager].database close];

    [_lock unlock];
    
    return state;
}

-(NSArray*)fetchAllDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName model:(id)model
{
    //操作之间对数据库加锁
    [_lock lock];
    
    if(model == nil)
    {
        [_lock unlock];
        return [self fetchAllDataFromDataBaseName:dbName tableName:tbName];
    }
    else
    {
        [self createDatabaseWithName:dbName];
        [[DBManager sharedManager].database open];
        NSMutableArray *array = [NSMutableArray new];
        NSString *sql = [NSString stringWithFormat:@"select * from %@", tbName];
        NSDictionary *proDic = [self getAllPropertiesFromClass:model];
        //查询结果集
        FMResultSet *set=[[DBManager sharedManager].database executeQuery:sql];
        
        //自动取每行记录，如果存在为true，否则为false
        while ([set next])
        {
            id tmpModel = [model copy];
            //根据字段名取出当前行的值
            for (int i = 0; i<[proDic allKeys].count; i++)
            {
                NSString *proValue = [set stringForColumn:[self translateToInsertName:[proDic allKeys][i]]];
                [tmpModel setValue:proValue forKey:[proDic allKeys][i]];
            }
            [array addObject:tmpModel];
        }
        [[DBManager sharedManager].database close];

        [_lock unlock];
        
        return array;
    }
}

-(NSArray*)fetchAllDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName
{
    //操作之间对数据库加锁
    [_lock lock];
    [self createDatabaseWithName:dbName];
    [[DBManager sharedManager].database open];
    NSMutableArray *array = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select * from %@", tbName];
    //查询结果集
    FMResultSet *set = [[DBManager sharedManager].database executeQuery:sql];
    
    NSDictionary *dic = [set columnNameToIndexMap];
    while ([set next])
    {
        NSMutableDictionary *tmpDic = [NSMutableDictionary new];
        for(NSString *str in [dic allKeys])
        {
            NSLog(@"allKeys str = %@", str);
            //根据字段名取出当前行的值
            NSString *proValue = [NSString stringWithFormat:@"%@", [set stringForColumn:str]];
            [tmpDic setValue:proValue forKey:[self translateToOutPutName:str]];
        }
        [array addObject:tmpDic];
    }
    
    [[DBManager sharedManager].database close];

    [_lock unlock];
    
    return array;
}

-(NSArray*)fetchDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName model:(id)model withCounts:(NSInteger)counts
{
    return [self fetchDataFromDataBaseName:dbName tableName:tbName model:model from:0 to:counts];
}

-(NSArray*)fetchDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName withCounts:(NSInteger)counts
{
    return [self fetchDataFromDataBaseName:dbName tableName:tbName from:0 to:counts];
}

-(NSArray*)fetchDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName model:(id)model from:(NSInteger)startIndex to:(NSInteger)endIndex
{
    //操作之间对数据库加锁
    [_lock lock];
    
    if(model == nil)
    {
        [_lock unlock];
        return [self fetchAllDataFromDataBaseName:dbName tableName:tbName];
    }
    else
    {
        [self createDatabaseWithName:dbName];
        [[DBManager sharedManager].database open];
        NSMutableArray *array = [NSMutableArray new];
        NSString *sql = [NSString stringWithFormat:@"select * from %@", tbName];
        NSDictionary *proDic = [self getAllPropertiesFromClass:model];
        //查询结果集
        FMResultSet *set=[[DBManager sharedManager].database executeQuery:sql];
        
        //自动取每行记录，如果存在为true，否则为false
        while ([set next])
        {
            static int index = 0;
            if(index < startIndex)
            {
                index++;
                continue;
            }
            else if(index>=startIndex && index<endIndex)
            {
                index++;
                id tmpModel = [model copy];
                //根据字段名取出当前行的值
                for (int i = 0; i<[proDic allKeys].count; i++)
                {
                    NSString *proValue = [set stringForColumn:[self translateToInsertName:[proDic allKeys][i]]];
                    [tmpModel setValue:proValue forKey:[self translateToOutPutName:[proDic allKeys][i]]];
                }
                [array addObject:tmpModel];
            }
            else
            {
                index = 0;
                break;
            }
        }
        [[DBManager sharedManager].database close];
        
        [_lock unlock];
        
        return array;
    }
}

-(NSArray*)fetchDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName from:(NSInteger)startIndex to:(NSInteger)endIndex
{
    //操作之间对数据库加锁
    [_lock lock];
    [self createDatabaseWithName:dbName];
    [[DBManager sharedManager].database open];
    NSMutableArray *array = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select * from %@", tbName];
    //查询结果集
    FMResultSet *set = [[DBManager sharedManager].database executeQuery:sql];
    
    NSDictionary *dic = [set columnNameToIndexMap];
    
    while ([set next])
    {
        static int index = 0;
        if(index < startIndex)
        {
            index++;
            continue;
        }
        else if(index>=startIndex && index<endIndex)
        {
            index ++;
            NSMutableDictionary *tmpDic = [NSMutableDictionary new];
            for(int i=0; i<[dic allKeys].count; i++)
            {
                NSString *str = [NSString stringWithFormat:@"%@", [dic allKeys][i]];
                NSLog(@"allKeys str = %@", str);
                //根据字段名取出当前行的值
                NSString *proValue = [set stringForColumn:str];
                [tmpDic setValue:proValue forKey:[self translateToOutPutName:str]];
            }
            [array addObject:tmpDic];
        }
        else
        {
            index = 0;
            break;
        }
    }
    
    [[DBManager sharedManager].database close];
    
    [_lock unlock];
    
    return array;
}

-(void)insertPropertyToDatabase:(NSString *)dbName inTable:(NSString *)tbName withPropertyNames:(NSMutableArray *)ptNames propertyTypes:(NSMutableArray *)propertyTypes
{
    //操作之间对数据库加锁
    [_lock lock];
    
    if(ptNames && propertyTypes && (ptNames.count == propertyTypes.count))
    {
        for (int i = 0; i<ptNames.count; i++)
        {
            [self insertPropertyToDatabase:dbName inTable:tbName withPropertyName:ptNames[i] propertyType:propertyTypes[i]];
        }
    }
    else
    {
        NSLog(@"传入数组不规范，请检查！");
    }

    [_lock unlock];
}

-(BOOL)rewriteDataFromDatabase:(NSString *)dbName inTable:(NSString *)tbName model:(id)model
{
    [_lock lock];
    [[DBManager sharedManager].database open];

    NSMutableString *sql=[NSMutableString stringWithFormat:@"update %@ set ", tbName];
    NSDictionary *proDic = [self getAllPropertiesFromClass:model];
    for(NSString *proName in [proDic allKeys])
    {
        [sql appendString:[NSString stringWithFormat:@"%@='%@',",[self translateToInsertName:proName], [NSString stringWithFormat:@"%@", [model valueForKey:proName]]]];
    }
    
    [_lock unlock];
    NSArray *arr = [self fetchAllDataFromDataBaseName:dbName tableName:tbName];
    [_lock lock];
    
    NSString *modelId = @"";
    for (NSDictionary *dic in arr)
    {
        NSInteger count = 0;
        for(NSString *proName in [proDic allKeys])
        {
            if(![proName isEqualToString:@"id"])
            {
                if([[model valueForKey:proName] isEqual:dic[proName]])
                {
                    count++;
                }
            }
        }
        if(count == [proDic allKeys].count-1)
        {
            modelId = dic[@"id"];
        }
    }
    [sql replaceCharactersInRange:NSMakeRange(sql.length-1, 1) withString:@" "];
    [sql appendFormat:@"where id='%@'", modelId];

    [[DBManager sharedManager].database open];

    BOOL ret=[[DBManager sharedManager].database executeUpdate:sql];
    
    if(!ret)
    {
        NSLog(@"update error!%@,",[DBManager sharedManager].database.lastErrorMessage);
    }
    [_lock unlock];

    return ret;
}


//获取class里的所有key属性名和value属性类型
- (NSDictionary *)getAllPropertiesFromClass:(id)class
{
    NSMutableDictionary *props = [NSMutableDictionary new];
    NSInteger i;
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([class class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        const char* char_a = property_getAttributes(property);
        NSString *originAttributeName = [NSString stringWithUTF8String:char_a];
        NSString *tmpString = [[originAttributeName componentsSeparatedByString:@","] firstObject];
        NSString *attributeName = [tmpString substringWithRange:NSMakeRange(3, tmpString.length-4)];
        [props setObject:attributeName forKey:propertyName];
    }
    free(properties);
    return props;
}

//驼峰名字转下划线名字
-(NSString *)translateToInsertName:(NSString *)name
{
    NSMutableString *insertName = [name mutableCopy];
    
    for(int i = 0; i < name.length; i++)
    {
        char c = [insertName characterAtIndex:i];
        if(c>64 && c<91)
        {
            NSRange range = NSMakeRange(i, 1);
            [insertName replaceCharactersInRange:range withString:[NSString stringWithFormat:@"_%@", [[NSString stringWithFormat:@"%c",c] lowercaseString]]];
        }
    }
    return insertName;
}

//下划线名字转驼峰名字
-(NSString *)translateToOutPutName:(NSString *)name
{
    NSMutableString *outputName = [NSMutableString stringWithString:name];
    while ([outputName containsString:@"_"]) {
        NSRange range = [outputName rangeOfString:@"_"];
        if (range.location + 1 < [outputName length]) {
            char c = [outputName characterAtIndex:range.location+1];
            [outputName replaceCharactersInRange:NSMakeRange(range.location, range.length+1) withString:[[NSString stringWithFormat:@"%c",c] uppercaseString]];
        }
    }
    return outputName;
}

@end
