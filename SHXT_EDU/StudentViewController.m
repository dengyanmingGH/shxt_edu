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
@property (strong, nonatomic) IBOutlet UILabel *uNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *uSchoolLabel;
@property (strong, nonatomic) IBOutlet UILabel *uInSchoolTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *uGhsLabel;
@property (strong, nonatomic) IBOutlet UILabel *uShClassLabel;
@property (strong, nonatomic) IBOutlet UILabel *uPhone;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UILabel *uShClassTypeLabel;
@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //------------------------------------------------------------//

    [self getStusInfo];
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
//异步获取学生信息
-(void) getStusInfo{
    NSString *urlStr = [[NSString alloc]initWithFormat:URL_STUDENT_GETALL];
    [CoreHttp getUrl:urlStr params:nil success:^(NSString *obj) {
        if(obj.length == 0){
            NSLog(@"StudentViewController - getStusInfo : 没有查到数据");
        }else{
            NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.stuArr = arr;
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
    //获得选择节中选中的行索引
    NSUInteger row = [indexPath row];
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
    /*NSString *groupName = [self.listGroupName objectAtIndex:section];
    NSArray *stuArr = [self.dictData objectForKey:groupName];
    return [stuArr count];
     */
    return [self.stuArr count];
}
//表视图分节个数设置
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //return [self.listGroupName count];
    return 1;
}
//表视图分节标题设置
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    //return [self.listGroupName objectAtIndex:section];
    return @"祥云29期";
}
//设置当前单元格样式和内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"studentCell"];
    }
    //获得选择的节
    //NSInteger section = [indexPath section];
    //获得选择节中选中的行索引
    NSUInteger row = [indexPath row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    /*
    NSString *groupName = [self.listGroupName objectAtIndex:section];
    NSArray *stuArr = [self.dictData objectForKey:groupName];
    cell.textLabel.text = [stuArr objectAtIndex:row];
    */
    NSDictionary *stuInfo = [self.stuArr objectAtIndex:row];
    cell.textLabel.text = [stuInfo objectForKey:@"STUNAME"];
    [cell setRestorationIdentifier:[stuInfo objectForKey:@"ID"]];
    return cell;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)hiddenStuDetialView:(UIButton *)sender {
    self.stuDetailView.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
