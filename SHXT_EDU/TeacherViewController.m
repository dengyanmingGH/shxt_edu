//
//  TeacherViewController.m
//  SHXT_EDU
//
//  Created by ccshxt on 16/6/7.
//  Copyright © 2016年 ccshxt. All rights reserved.
//

#import "TeacherViewController.h"

@interface TeacherViewController ()
@property (strong, nonatomic) IBOutlet UITableView *teacherTV;
@property (nonatomic,strong)  NSDictionary *dictData;
@property (nonatomic,strong) NSArray *teacherArr;
@property (nonatomic,strong) NSArray *teacherAllArr;
@property (nonatomic,strong) UIWebView * phoneCallWebView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation TeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getTeacherInfo];
}

//异步获取学生信息
-(void) getTeacherInfo{
    NSString *urlStr = [[NSString alloc]initWithFormat:URL_TEACHER_GETALL];
    [CoreHttp getUrl:urlStr params:nil success:^(NSString *obj) {
        if(obj.length == 0){
            NSLog(@"TeacherViewController - getTeacherInfo : 没有查到数据");
        }else{
            NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.teacherArr = arr;
            self.teacherAllArr = arr;
            //回主线程更新ui
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.teacherTV reloadData];
            });
        }
    } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
        NSLog(@"get - error - %@",errorMsg);
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获得选择节中选中的行索引
    NSUInteger row = [indexPath row];
    NSDictionary *teacherInfo = [self.teacherArr objectAtIndex:row];
    //拨打电话
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",[teacherInfo objectForKey:@"PHONE"]];
    UIWebView *callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

//获得每一小节的记录条数
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.teacherArr count];
}
//表视图分节个数设置
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//设置当前单元格样式和内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teacherCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"teacherCell"];
    }
    NSUInteger row = [indexPath row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *teacherInfo = [self.teacherArr objectAtIndex:row];
    cell.textLabel.text = [teacherInfo objectForKey:@"MASTERNAME"];
    cell.detailTextLabel.text = [teacherInfo objectForKey:@"PHONE"];
    return cell;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self filterContentForSearchText:self.searchBar.text scope:self.searchBar.selectedScopeButtonIndex];
    [self.teacherTV reloadData];
}
//通过搜索字符串过滤数据
-(void)filterContentForSearchText:(NSString *)searchText scope:(NSUInteger)scope{
    if([searchText length]==0){
        self.teacherArr = self.teacherAllArr;
        return;
    }
    NSPredicate *scopePredicate;
    NSArray *tempArray;
    switch (scope) {
        case 0:
            scopePredicate = [NSPredicate predicateWithFormat:@"SELF.USERNAME contains[c] %@",searchText];
            tempArray = [self.teacherArr filteredArrayUsingPredicate:scopePredicate];
            self.teacherArr = tempArray;
            //self.teacherFilterArr = [NSMutableArray arrayWithArray:tempArray];
            break;
        case 1:
            scopePredicate = [NSPredicate predicateWithFormat:@"SELF.MASTERNAME contains[c] %@",searchText];
            tempArray = [self.teacherArr filteredArrayUsingPredicate:scopePredicate];
            //self.teacherFilterArr = [NSMutableArray arrayWithArray:tempArray];
            self.teacherArr = tempArray;
            break;
        default:
            self.teacherArr = self.teacherAllArr;
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
