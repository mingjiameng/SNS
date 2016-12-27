//
//  SNSTaskDistributionCenter.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSTaskDistributionCenter.h"

#import "SNSDetailDetectSatellite.h"
#import "SNSMath.h"
#import "SNSPlanedDetailDetectTask.h"

@interface SNSTaskDistributionCenter ()
@property (nonatomic, strong, nonnull) NSMutableArray<SNSSGDetailDetectTask *> *taskList;
@property (atomic) NSInteger taskToAllocate;
@end


@implementation SNSTaskDistributionCenter

+ (instancetype)sharedTaskDistributionCenter
{
    static dispatch_once_t onceToken;
    static SNSTaskDistributionCenter *taskDistributionCenter = nil;
    
    dispatch_once(&onceToken, ^{
        taskDistributionCenter = [[SNSTaskDistributionCenter alloc] init];
    });
    
    return taskDistributionCenter;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self readInTaskFile];
    }
    
    return self;
}

- (void)readInTaskFile
{
    FILE *task_input_txt = fopen("/Users/zkey/Desktop/science/sns_input/sns_task_source.txt", "r");
    assert(task_input_txt != NULL);
    
    _taskList = [NSMutableArray arrayWithCapacity:8000];
    
    double longitude, latitude;
    double x, y, z;
    int value;
    double compression_ratio, compression_ratio_dis;
    double area_length;
    int expected_visit_count;
    
    NSUInteger task_unique_id = 0;
    _taskToAllocate = 0;
    while(fscanf(task_input_txt, "%lf %lf %lf %lf %lf %d %lf %lf %lf %d", &longitude, &latitude, &x, &y, &z, &value, &compression_ratio, &compression_ratio_dis, &area_length, &expected_visit_count) != EOF) {
        SNSEarthPoint *earthPoint = [[SNSEarthPoint alloc] initWithLongitude:longitude andLatitude:latitude];
        SNSHotArea *hotArea = [[SNSHotArea alloc] init];
        hotArea.earthPoint = earthPoint;
        hotArea.areaLength = area_length;
        hotArea.areaGeoValue = value;
        hotArea.areaGraphicCompressionRatio = compression_ratio;
        if (compression_ratio < 1) {
            NSLog(@"unormal ratio %lf with geo value %d", compression_ratio, value);
        }
        hotArea.areaGraphicCompressionRatioDis = compression_ratio_dis;
        SNSSGDetailDetectTask *task = [[SNSSGDetailDetectTask alloc] init];
        task.uniqueID = ++task_unique_id;
        task.hotArea = hotArea;
        task.expectedExecutedCount = expected_visit_count;
        _taskToAllocate += expected_visit_count;
        [_taskList addObject:task];
    }
    
    fclose(task_input_txt);
    
    NSLog(@"%ld task readed", task_unique_id);
}

- (NSArray<SNSSatelliteGraphicTaskExecution *> *)newTaskExecutionQueueForSatellite:(SNSDetailDetectSatellite *)userSatellite
{
    if (![userSatellite isKindOfClass:[SNSDetailDetectSatellite class]]) {
        return [[NSArray alloc] init];
    }
    
    NSUInteger task_count = [SNSMath randomIntegerBetween:8 and:10];
    NSUInteger candidate_task_count = 20;
    NSMutableArray *tmp_task_list = [NSMutableArray arrayWithCapacity:task_count];
    NSUInteger task_index = 0;
    BOOL is_valide_task = NO;
    BOOL is_duplicate_task = NO;
    SNSSGDetailDetectTask *the_task = nil;
    int randomize_time_count = 0;
    SNSTimeRange next_circle_time_range;
    next_circle_time_range.beginAt = SYSTEM_TIME;
    next_circle_time_range.length = userSatellite.orbitPeriod;
    SNSTimeRange validTimeRange = {0, 0};
    while (candidate_task_count--) {
        if (self.taskList.count <= 0) {
            NSLog(@"task list has no task");
            break;
        }
        
        randomize_time_count = 20;
        is_valide_task = NO;
        is_duplicate_task = NO;
        // 先用随机，随机不行就用线性查找
        while (randomize_time_count--) {
            task_index = [SNSMath randomIntegerBetween:0 and:(_taskList.count - 1)];
            the_task = [self.taskList objectAtIndex:task_index];
            is_duplicate_task = NO;
            for (SNSPlanedDetailDetectTask *planedTask in tmp_task_list) {
                if (planedTask.task.uniqueID == the_task.uniqueID) {
                    is_duplicate_task = YES;
                    break;
                }
            }
            
            if (!is_duplicate_task) {
                validTimeRange = [SNSMath visibleTimeRangeBetweenSatellite:userSatellite andHotArea:the_task.hotArea inTimeRange:next_circle_time_range];
                if (validTimeRange.length > 0) {
                    is_valide_task = true;
                    break;
                }
            }
        }
        // 用线性查找valid_task
        if (!is_valide_task) {
            for (task_index = 0; task_index < _taskList.count; ++task_index) {
                the_task = [self.taskList objectAtIndex:task_index];
                is_duplicate_task = NO;
                for (SNSPlanedDetailDetectTask *planedTask in tmp_task_list) {
                    if (planedTask.task.uniqueID == the_task.uniqueID) {
                        is_duplicate_task = YES;
                        break;
                    }
                }
                
                if (!is_duplicate_task) {
                    validTimeRange = [SNSMath visibleTimeRangeBetweenSatellite:userSatellite andHotArea:the_task.hotArea inTimeRange:next_circle_time_range];
                    if (validTimeRange.length > 0) {
                        is_valide_task = true;
                        break;
                    }
                }
            }
        }
        
        if (is_valide_task) {
            if (the_task.expectedExecutedCount <= 0) {
                [self.taskList removeObjectAtIndex:task_index];
            }
            else {
                SNSPlanedDetailDetectTask *planed_task = [[SNSPlanedDetailDetectTask alloc] init];
                planed_task.task = the_task;
                planed_task.visibleTimeRange = validTimeRange;
                [tmp_task_list addObject:planed_task];
                
            }
        } else {
            NSLog(@"no more task for satellite-%ld", userSatellite.uniqueID);
            break;
        }
        
    }
    
    [tmp_task_list sortUsingComparator:^NSComparisonResult(SNSPlanedDetailDetectTask * _Nonnull obj1, SNSPlanedDetailDetectTask * _Nonnull obj2) {
        if (obj1.visibleTimeRange.beginAt < obj2.visibleTimeRange.beginAt) {
            return NSOrderedAscending;
        }

        return NSOrderedDescending;
    }];
    
    NSMutableArray *valid_task_list = [NSMutableArray arrayWithCapacity:10];
    SNSSatelliteGraphicTaskExecution *last_schedualed_task_execution = nil;
    SNSPlanedDetailDetectTask *the_planed_task = nil;
    for (NSUInteger index = 0; index < tmp_task_list.count; ++index) {
        if (task_count <= 0) {
            break;
        }
        
        the_planed_task = [tmp_task_list objectAtIndex:index];
        
        if (last_schedualed_task_execution == nil) {
            
        }
        else if (the_planed_task.visibleTimeRange.beginAt + the_planed_task.visibleTimeRange.length - 300 < last_schedualed_task_execution.imageAction.ExpectedStartTime) {
                continue;
        }
        
        SNSSatelliteGraphicTaskExecution *new_task_execution = [[SNSSatelliteGraphicTaskExecution alloc] init];
        new_task_execution.task = the_planed_task.task;
        new_task_execution.executor = userSatellite;
        SNSSatelliteAction *imageAction = [[SNSSatelliteAction alloc] init];
        imageAction.ExpectedStartTime = the_planed_task.visibleTimeRange.beginAt;
        if (last_schedualed_task_execution != nil) {
            imageAction.ExpectedStartTime = MAX(last_schedualed_task_execution.imageAction.ExpectedStartTime + 300, the_planed_task.visibleTimeRange.beginAt);
        }
        imageAction.expectedTimeCost = 10;
        new_task_execution.imageAction = imageAction;
        [valid_task_list addObject:new_task_execution];
        last_schedualed_task_execution = new_task_execution;
    }
    
#ifdef DEBUG
    //NSLog(@"allocate %ld tasks", valid_task_list.count);
#endif
    
    self.taskToAllocate -= valid_task_list.count;
    
    return valid_task_list;
}



@end
