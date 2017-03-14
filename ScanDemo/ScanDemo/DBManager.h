//
//  DBManager.h
//  PLFMDBTest
//
//  Created by Paul on 11/29/16.
//  Copyright © 2016 Paul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBManager : NSObject

@property(nonatomic, strong) FMDatabase *database;
@property(nonatomic, copy) NSString *databasePath;

+(DBManager *)sharedManager;

/**
 * 创建数据库
 * param:dbName->要创建的数据库的名字
 * 返回YES表示创建成功，NO表示失败
 */
-(BOOL)createDatabaseWithName:(NSString *)dbName;

/**
 * 添加数据表
 * param:dbName->数据库名
 * param:tbName->要添加的表名
 * param:model->使用模型来创建表，每一列对应model里的每一个属性
 * 返回YES表示添加成功，NO表示添加失败
 */
-(BOOL)addTableToDatabase:(NSString *)dbName withTBName:(NSString *)tbName model:(id)model;

/**
 * 插入数据
 * param:dbName->数据库名
 * param:tbName->表名
 * param:model->使用模型来插入数据，每一列对应model里的每一个属性
 */
-(void)insertDataToDatabase:(NSString *)dbName tableName:(NSString *)tbName model:(id)model;

/**
 * 删除数据
 * param:dbName->数据库名
 * param:tbName->表名
 * param:model->使用模型来删除数据，每一列对应model里的每一个属性
 */
-(void)deleteDataFromDatabase:(NSString *)dbName tableName:(NSString *)tbName model:(id)model;

/**
 查询所有数据

 @param dbName 数据库名
 @param tbName 表名
 @param model 使用model来查询数据，每一列对应model里的每一个属性；此处不必传入带数据的model，只需一个空的实例即可，例如"[TestModel new]",返回的数组中就会以改对象形式返回；如果传入nil，则以字典形式返回
 @return 以数组存放多个模型（或字典）形式返回
 */
-(NSArray*)fetchAllDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName model:(id)model;

/**
 查询所有数据

 @param dbName 数据库名
 @param tbName 表名
 @return 以数组存放多个字典形式返回
 */
-(NSArray*)fetchAllDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName;

/**
 查询指定条数数据

 @param dbName 数据库名
 @param tbName 表名
 @param model 使用model来查询数据，每一列对应model里的每一个属性；此处不必传入带数据的model，只需一个空的实例即可，例如"[TestModel new]",返回的数组中就会以改对象形式返回；如果传入nil，则以字典形式返回
 @param counts 返回记录的条数
 @return 以数组存放多个模型（或字典）形式返回
 */
-(NSArray*)fetchDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName model:(id)model withCounts:(NSInteger)counts;

/**
 查询指定条数数据

 @param dbName 数据库名
 @param tbName 表名
 @param counts 返回记录的条数
 @return 以数组存放多个字典形式返回
 */
-(NSArray*)fetchDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName withCounts:(NSInteger)counts;

/**
 查询指定位置数据

 @param dbName 数据库名
 @param tbName 表名
 @param model 使用model来查询数据，每一列对应model里的每一个属性；此处不必传入带数据的model，只需一个空的实例即可，例如"[TestModel new]",返回的数组中就会以改对象形式返回；如果传入nil，则以字典形式返回
 @param startIndex 返回数据条数起始位置
 @param endIndex 返回数据条数结束位置
 @return 以数组存放多个模型（或字典）形式返回
 */
-(NSArray*)fetchDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName model:(id)model from:(NSInteger)startIndex to:(NSInteger)endIndex;

/**
 查询指定位置数据

 @param dbName 数据库名
 @param tbName 表名
 @param startIndex 返回数据条数起始位置
 @param endIndex 返回数据条数结束位置
 @return 以数组存放多个字典形式返回
 */
-(NSArray*)fetchDataFromDataBaseName:(NSString *)dbName tableName:(NSString *)tbName from:(NSInteger)startIndex to:(NSInteger)endIndex;

/**
 往已有表中插入字段

 @param dbName 数据库名
 @param tbName 表名
 @param ptName 字段名
 @param propertyType 字段类型
 */
-(void)insertPropertyToDatabase:(NSString *)dbName inTable:(NSString *)tbName withPropertyName:(NSString *)ptName propertyType:(NSString *)propertyType;

/**
 往已有表中插入多个字段
 
 @param dbName 数据库名
 @param tbName 表名
 @param ptNames 字段名数组
 @param propertyTypes 字段类型数组
 */
-(void)insertPropertyToDatabase:(NSString *)dbName inTable:(NSString *)tbName withPropertyNames:(NSMutableArray *)ptNames propertyTypes:(NSMutableArray *)propertyTypes;


/**
 修改某条数据

 @param dbName 数据库名
 @praam tbName 数据表名
 @param model 某条要修改的数据
 @return BOOL 返回是否修改成功
 */

-(BOOL)rewriteDataFromDatabase:(NSString *)dbName inTable:(NSString *)tbName model:(id)model;

@end
