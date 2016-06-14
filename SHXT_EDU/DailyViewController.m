//
//  DailyViewController.m
//  SHXT_EDU
//
//  Created by ccshxt on 16/4/26.
//  Copyright © 2016年 ccshxt. All rights reserved.
//

#import "DailyViewController.h"

@interface DailyViewController ()
@property (strong, nonatomic) IBOutlet UITableView *dailysTv;
//NSArray 为不可变数组，能遍历不能修改；NSMutableArray为可变数组，可以进行修改操作。
@property (nonatomic,strong)  NSMutableArray *dailyList;
@property (nonatomic,strong)  NSString *pageSize;
@property (nonatomic,strong)  UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *dailyDetailView;
@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *classTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *classBeginLabel;
@property (strong, nonatomic) IBOutlet UILabel *classEndLabel;
@property (strong, nonatomic) IBOutlet UILabel *courseKPLabel;

@end

@implementation DailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageSize = @"9";
    self.dailyList = [[NSMutableArray alloc] init];
    //创建一个导航栏集合
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"日报列表"];
    //把导航栏集合添加入导航栏中，设置动画关闭
    [self.navigationBar pushNavigationItem:navigationItem animated:NO];
    //将编辑按钮设置为导航栏右边的按钮
    [navigationItem setRightBarButtonItem:self.editButtonItem];
    
    NSLog(@"self.editButtonItem.action - %@",NSStringFromSelector(self.editButtonItem.action));
    
    NSLog(@"self.editButtonItem.target - %@",self.editButtonItem.target);
//    self.editButtonItem.target;
    
    
    //隐藏左按钮
     navigationItem.hidesBackButton = YES;
    //------------------------------------------------------------//
    //self.dailysTv.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(getDailysByPage)];
    [self getDailysByPage];
    //------------------------------------------------------------//
    //日报详细信息视图初始化
    self.dailyDetailView.frame = CGRectMake(0, 0,SCREEN_WIDTH , SCREEN_HEIGHT);
    self.dailyDetailView.hidden = YES;
    [self.view addSubview:self.dailyDetailView ];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dailyList count]+1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获得选择节中选中的行索引
    NSUInteger row = [indexPath row];
    NSDictionary *dict = [self.dailyList objectAtIndex:row];
    NSString *courseDate = [dict objectForKey:@"WORKDAY"];
    self.classEndLabel.text = [[NSString alloc]initWithFormat:@"%@ %@",courseDate,[dict objectForKey:@"CLASSTIMEEND"]];
    self.classNameLabel.text = [dict objectForKey:@"SHNAME"];
    self.classTypeLabel.text = [dict objectForKey:@"CLASSISDAY"];
    self.classBeginLabel.text = [[NSString alloc]initWithFormat:@"%@ %@",courseDate,[dict objectForKey:@"CLASSTIMESTART"]];
    self.courseKPLabel.text = [dict objectForKey:@"MEMO"];
    self.dailyDetailView.hidden = NO;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//异步获取日报信息(分页)
- (void)getDailysByPage{
    static int pageNum = 0;
    pageNum ++;
    NSString *path = [self applicationDocumentDirectory];
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSString *urlStr = [[NSString alloc]initWithFormat:URL_DAILYS_BY_PAGE,pageNum,self.pageSize,[dict objectForKey:@"userId"]];
        [CoreHttp getUrl:urlStr params:nil success:^(NSString *obj) {
            if(obj.length == 0){
                NSLog(@"DailyViewController - getDailysByPage : 没有查到数据");
            }else{
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                [self.dailyList addObjectsFromArray:[dictData objectForKey:@"list"]];
                self.dailyList = [[NSMutableArray alloc] initWithArray:[dictData objectForKey:@"list"]];
                //回主线程更新ui
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.dailysTv reloadData];
                });
                //[self.dailysTv.mj_footer endRefreshing];
            }
        } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
            NSLog(@"get - error - %@",errorMsg);
        }];

}

//设置当前单元格样式和内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    BOOL addCell_flag = (indexPath.row == 0);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    }
    if(!addCell_flag){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSUInteger row = [indexPath row];
        NSDictionary *rowDict = [self.dailyList objectAtIndex:row-1];
        cell.textLabel.text = [rowDict objectForKey:@"SHNAME"];
        NSString *detailText = [[NSString alloc]initWithFormat:@"%@ %@",[rowDict objectForKey:@"WORKDAY"],[rowDict objectForKey:@"CLASSTIMESTART"]];
        cell.detailTextLabel.text = detailText;
    }else{
        cell.textLabel.text = @"Add ...";
        cell.detailTextLabel.text = @"";
    }
    return cell;

}
//视图设置编辑状态时，调用该方法
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self.dailysTv setEditing:editing animated:animated];
    NSLog(@"set editing %d",editing);
}
//设置单元格编辑图标
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}
//实现删除或插入处理的方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.dailyList removeObjectAtIndex:indexPath.row-1];
        [self.dailysTv deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }else if(editingStyle == UITableViewCellEditingStyleInsert){
        //用模态跳转到日报新增界面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        id tabViewController = [storyboard instantiateViewControllerWithIdentifier:@"addDaily"];
        [self presentViewController:tabViewController animated:YES completion:^{}];
    }
}
- (IBAction)okBtnClick:(id)sender {
    self.dailyDetailView.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *) applicationDocumentDirectory{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingString:@"userInfo.plist"];
    return path;
}


@end
