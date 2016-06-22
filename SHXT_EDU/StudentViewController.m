//
//  StudentViewController.m
//  SHXT_EDU
//
//  Created by ccshxt on 16/5/12.
//  Copyright © 2016年 ccshxt. All rights reserved.
//
	
#import "StudentViewController.h"

@interface StudentViewController ()
@property (nonatomic,strong)  NSArray *listGroupName;
@property (strong, nonatomic) IBOutlet UIView *stuDetailView;
@property (nonatomic,strong)  NSDictionary *stuInfo;
@property (strong, nonatomic) IBOutlet UITableView *stuTableView;
@property (nonatomic,strong) NSArray *stuArr;
@property (nonatomic,strong) NSArray *ClassArr;
@property (nonatomic,strong) NSMutableDictionary *ClassAndStuDict;
@property (nonatomic,strong) NSMutableDictionary *ClassAndStuAllDict;
@property (strong, nonatomic) IBOutlet UILabel *uNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *uSchoolLabel;
@property (strong, nonatomic) IBOutlet UILabel *uInSchoolTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *uGhsLabel;
@property (strong, nonatomic) IBOutlet UILabel *uShClassLabel;
@property (strong, nonatomic) IBOutlet UILabel *uPhone;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UILabel *uShClassTypeLabel;
@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ClassAndStuDict = [[NSMutableDictionary alloc]init];
    self.ClassAndStuAllDict = [[NSMutableDictionary alloc]init];
    [self getClassInfo];
    //------------------------------------------------------------//
    //NSArray *tempArr = [self.dictData allKeys];
    //对key进行排序，否则取到对key（A,B,C等)为乱序
    //self.listGroupName = [tempArr sortedArrayUsingSelector:@selector(compare:)];
    //学生详细信息视图初始化
    self.stuDetailView.frame = CGRectMake(0, 0,SCREEN_WIDTH , SCREEN_HEIGHT);
    self.stuDetailView.hidden = YES;
    //创建一个导航栏集合
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"学生信息"];
    //创建一个自定义按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStyleDone target:self action:@selector(clickBackButton)];
    //把导航栏集合添加入导航栏中，设置动画关闭
    [self.navigationBar pushNavigationItem:navigationItem animated:NO];
    //把按钮添加入导航栏集合中
    [navigationItem setLeftBarButtonItem:backButton];
    [self.view addSubview:self.stuDetailView];
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    self.uGhsLabel.text = @"";
    [super layoutSublayersOfLayer:layer];
}

-(void)clickBackButton{
    self.stuDetailView.hidden = YES;
}

- (IBAction)callStudent:(id)sender {
    //拨打电话
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",[self.stuInfo objectForKey:@"TELEPHONE"]];
    UIWebView *callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}
-(void) getClassInfo{
    NSString *path = [self applicationDocumentDirectory];
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSString *urlStr = [[NSString alloc]initWithFormat:URL_TEACHER_GETALLCLASS,[dict objectForKey:@"userId"]];
    [CoreHttp getUrl:urlStr params:nil success:^(NSString *obj) {
        if(obj.length == 0){
            NSLog(@"StudentViewController - getClassInfo : 没有查到数据");
        }else{
            NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.ClassArr = arr;
            for(NSDictionary *dict in arr){
                [self getStusInfo:dict];
            }
        }
    } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
        NSLog(@"get - error - %@",errorMsg);
    }];
}
//异步获取学生信息
-(void) getStusInfo:(NSDictionary *)classDict{
    NSString *urlStr = [[NSString alloc]initWithFormat:URL_STUDENT_GETBYCLASS,[classDict objectForKey:@"SHXTYEAR"],[classDict objectForKey:@"CLASSNUMBER"]];
    [CoreHttp getUrl:urlStr params:nil success:^(NSString *obj) {
        if(obj.length == 0){
            NSLog(@"StudentViewController - getStusInfo : 没有查到数据");
        }else{
            NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.ClassAndStuDict[[classDict objectForKey:@"SHNAME"]] = arr;
            [self.ClassAndStuAllDict setDictionary:self.ClassAndStuDict];
            //回主线程更新ui
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.stuTableView reloadData];
            });
        }
    } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
        NSLog(@"get - error - %@",errorMsg);
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath");
    //获得选择节中选中的行索引
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString *sectionName = [[self.ClassArr objectAtIndex:section] objectForKey:@"SHNAME"];
    self.stuArr = [self.ClassAndStuDict objectForKey:sectionName];
    self.stuInfo = [self.stuArr objectAtIndex:row];
    
    self.uPhone.text = [self.stuInfo objectForKey:@"TELEPHONE"];
    self.uGhsLabel.text = [self.stuInfo objectForKey:@"VOCATIONMASTER"];
    self.uNameLabel.text = [self.stuInfo objectForKey:@"STUNAME"];
    self.uSchoolLabel.text = [self.stuInfo objectForKey:@"UNIVERSITY"];
    self.uShClassLabel.text = [[NSString alloc]initWithFormat:@"%@期",[self.stuInfo objectForKey:@"SHXTNUMBER"]];
    self.uShClassTypeLabel.text = [self.stuInfo objectForKey:@"CLASSTYPE"];
    self.uInSchoolTimeLabel.text = [self.stuInfo objectForKey:@"INSCHOOLYEAR"];
    self.stuDetailView.hidden = NO;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//获得每一小节的记录条数
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     NSLog(@"numberOfRowsInSection");
    NSString *sectionName = [[self.ClassArr objectAtIndex:section] objectForKey:@"SHNAME"];
    self.stuArr = [self.ClassAndStuDict objectForKey:sectionName];
    return [self.stuArr count];
}
//表视图分节个数设置
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"numberOfSectionsInTableView");
    return [self.ClassArr count];
}
//表视图分节标题设置
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self.ClassArr objectAtIndex:section] objectForKey:@"SHNAME"];
}
//设置当前单元格样式和内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForRowAtIndexPath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"studentCell"];
    }
    //获得选择的节
    NSInteger section = [indexPath section];
    //获得选择节中选中的行索引
    NSUInteger row = [indexPath row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *sectionName = [[self.ClassArr objectAtIndex:section] objectForKey:@"SHNAME"];
    NSArray *stuArr = [self.ClassAndStuDict objectForKey:sectionName];
    NSDictionary *stuInfo = [stuArr objectAtIndex:row];
    cell.textLabel.text = [stuInfo objectForKey:@"STUNAME"];
    [cell setRestorationIdentifier:[stuInfo objectForKey:@"ID"]];
    return cell;
    
}

//搜索条输入值变化时调用方法
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self filterContentForSearchText:self.searchBar.text];
    [self.stuTableView reloadData];
}
//通过搜索字符串过滤数据
-(void)filterContentForSearchText:(NSString *)searchText{
    if([searchText length]==0){
        [self.ClassAndStuDict setDictionary: self.ClassAndStuAllDict];
        return;
    }
    NSPredicate *scopePredicate;
    NSArray *tempArray;
    NSString *sectionName ;
    for(NSDictionary *dict in self.ClassArr){
        sectionName = [dict objectForKey:@"SHNAME"];
        scopePredicate = [NSPredicate predicateWithFormat:@"SELF.STUNAME contains[c] %@",searchText];
        tempArray = [[self.ClassAndStuAllDict objectForKey:sectionName] filteredArrayUsingPredicate:scopePredicate];
        self.ClassAndStuDict[sectionName] = tempArray;
    }
}
//监听视图滑动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)hiddenStuDetialView:(UIButton *)sender {
    self.stuDetailView.hidden = YES;
}
-(NSString *) applicationDocumentDirectory{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingString:@"/userInfo.plist"];
    return path;
}


@end
