//
//  YMDHMSDatePickerView.swift
//  YearMonthDayHourMiniteSecondDemo
//
//  Created by 刘隆昌 on 2017/11/25.
//  Copyright © 2017年 刘隆昌. All rights reserved.
//

import Foundation

import UIKit



let T_Number_Rows = 16384
let T_Row_Height = 32
let T_ToolBar_Height : CGFloat = 44
let T_DatePicker_Height : CGFloat = 200
let T_Number_YearRows = 10000
let Screen_Width = UIScreen.main.bounds.size.width
let Screen_Height = UIScreen.main.bounds.size.height


func UIColorFromHexWithAlpha(hexValue:Int,a:CGFloat)->UIColor{
    return UIColor.init(red: CGFloat(Double((hexValue & 0xff0000) >> 16)/255.0), green: CGFloat(Double((hexValue & 0xff00) >> 16)/255.0), blue: CGFloat(Double((hexValue & 0xff) >> 16)/255.0), alpha: a);
}


func UIColorFromHex(hexValue:Int)->UIColor{
    return UIColorFromHexWithAlpha(hexValue: hexValue, a: 1.0);
}


let T_Separtor_Color = UIColorFromHex(hexValue: 0xcccccc)


let isIos8 = (Double(UIDevice.current.systemVersion)! >= 8.0)





typealias ToolBarAction = (_ date:NSDate)->Void


class YMDHMSDatePickerView: UIView,UIPickerViewDataSource,UIPickerViewDelegate {

    //最大值
    var maximumDate : NSDate! = nil;
    //最小值
    var minimumDate : NSDate! = nil;
    //用于手动设置时间
    var date : NSDate! = nil;
    //用于回调
    var doneAction : ToolBarAction! = nil;
    //是否不可选择过去的时间
    var canChoicePastTime : Bool! = false;
    //选择器背景颜色
    var backGroundColor : UIColor! = nil;
    
    
    
    fileprivate var datePicker : UIPickerView! = nil
    fileprivate var timer : DispatchTime! = nil
    fileprivate var dateView : UIView! = nil
    fileprivate var actionToolBar : UIToolbar! = nil
    fileprivate var selectedYear : NSInteger! = 0
    fileprivate var selectedMonth : NSInteger! = 0
    fileprivate var selectedDay : NSInteger! = 0
    fileprivate var selectedHour : NSInteger! = 0
    fileprivate var selectedMinute : NSInteger! = 0
    
    
    fileprivate var currentYear:NSInteger! = 0
    fileprivate var currentMonth:NSInteger! = 0
    fileprivate var currentDay:NSInteger! = 0
    fileprivate var currentHour:NSInteger! = 0
    fileprivate var currentMinute:NSInteger! = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.initUI();
    }
    
    
    func initUI(){
        self.frame = CGRect.init(x: 0, y: Screen_Height, width: Screen_Width, height: T_ToolBar_Height+T_DatePicker_Height)
        self.dateView = UIView.init(frame: CGRect.init(x: 0, y: T_ToolBar_Height, width: Screen_Width, height: Screen_Height))
        self.addSubview(self.dateView)
        
        
        self.datePicker = UIPickerView.init(frame: CGRect.init(x: 0, y: 0, width: Screen_Width, height: T_DatePicker_Height));
        self.datePicker.delegate = self as UIPickerViewDelegate;
        self.datePicker.dataSource = self;
        self.datePicker.showsSelectionIndicator = true;
        self.dateView.addSubview(self.datePicker);
        
        self.actionToolBar = UIToolbar()
        self.actionToolBar.barStyle = .default
        self.actionToolBar.sizeToFit()
        
        
        let cancelBtn : UIBarButtonItem! = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(YMDHMSDatePickerView.actionCancel(btn:)))
        
        let flexSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneBtn = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(YMDHMSDatePickerView.actionDone(btn:)));
    self.actionToolBar.setItems([cancelBtn,flexSpace,doneBtn], animated: true);
        self.addSubview(self.actionToolBar);
    }
    
    @objc func actionDone(btn:UIBarButtonItem){
        
        if self.doneAction != nil {
            let date = self.getDateByPickerView()
            self.doneAction(date);
        }
        self.hide();
    }
    
    @objc func actionCancel(btn:UIBarButtonItem){
        self.hide();
    }
    
    
    //隐藏视图
    func hide(){
        let datePickerView = self.getPCDatePickerView()
        let vc : UIViewController! = self.currentVC();
        UIView.animate(withDuration: 0.3) {
            datePickerView?.frame = CGRect.init(x: 0, y: vc.view.frame.height, width: Screen_Width, height: self.frame.size.height)
        }
    }
    
    //显示视图
    func showView(){
        self.configPickView()
        let vc = self.currentVC()
        let datePickerView = self.getPCDatePickerView()
        UIView.animate(withDuration: 0.3) {
            datePickerView?.frame = CGRect.init(x: 0, y: (vc?.view.frame.height)!-self.frame.size.height, width: Screen_Width, height: self.frame.size.height);
        }
    }
    
    //MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 3 || component == 4 || component == 1 || component == 2 {
            return T_Number_Rows
        }
        return T_Number_YearRows
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var str : String! = nil;
        if component == 0 {
            str = "\(row)年"
        }else if(component == 1){
            str = "\(row%12)月"
        }else if(component == 2){
            str = "\(row%31+1)日"
        }else if(component == 3){
            str = "\(row%24)时"
        }else{
            str = "\(row%60)分"
        };return str;
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(T_Row_Height);
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var str = "";
        if component == 0 {
            str = "\(row)年";
        }else if(component == 1){
            str = "\(row%12+1)月";
        }else if(component == 2){
            str = "\(row%31+1)日";
        }else if(component == 3){
            str = "\(row%24)时"
        }else{
            str = "\(row%60)分"
        };
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: Int(self.frame.size.width), height: T_Row_Height));
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.text = str
        return label;
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            if !self.canChoicePastTime {
                
            }else{
                self.selectedYear = row;
            }
            
        }else if(component == 1){
            
            
        }else if(component == 2){
            
            
        }else if(component == 3){
            
            
        }else{
            
            
        }
        
    }
    
    
    
    
    //判断选择的时间是否小于当前时间
    func judgeDate(row:Int,InComponent component:Int){
        if component == 0 {
            if(row < self.currentYear){
                self.datePicker.selectRow(self.currentYear, inComponent: 0, animated: true)
                self.judgeDate(row: self.currentYear, InComponent: 0)
            }else if(row == self.currentYear){
                self.selectedYear = row;
                self.judgeDate(row: self.selectedMonth-1, InComponent: 1)
            }else{
                self.selectedYear = row;
            }
        }else if(component == 1){
            if(row%12+1<self.currentMonth && self.selectedYear == self.currentYear){
                self.datePicker.selectRow(self.currentMonth-1+4800, inComponent: 1, animated: true)
            }else if(row%12+1 == self.currentMonth && self.selectedYear == self.currentYear){
                self.selectedMonth = row%12+1;
                self.judgeDate(row: self.selectedDay-1, InComponent: 2);
            }else{
                self.selectedMonth = row%12+1;
            }
        }else if(component == 2){
            if(row%31+1<self.currentDay && self.selectedYear == self.currentYear && self.selectedMonth == self.currentMonth){
                self.datePicker.selectRow(self.currentDay-1+6200, inComponent: 2, animated: true)
                self.judgeDate(row: self.currentDay-1+6200, InComponent: 2)
            }else if(row%31+1 == self.currentDay && self.selectedYear == self.currentYear && self.selectedMonth == self.currentMonth){
                self.selectedDay = row%31+1;
                self.judgeDate(row: self.selectedHour, InComponent: 3);
            }else{
                self.selectedDay = row%31+1;
            }
        }else if(component == 3){
            
            if (row%24 < self.currentHour && self.selectedYear == self.currentYear && self.selectedMonth == self.currentMonth && self.selectedDay == self.currentDay){
                self.datePicker.selectRow(self.currentHour+4800, inComponent: 3, animated: true)
                self.judgeDate(row: self.currentHour+4800, InComponent: 3);
            }else if(row%24 == self.currentHour && self.selectedYear == self.currentYear && self.selectedMonth == self.currentMonth && self.selectedDay == self.currentDay){
                self.selectedHour = row%24;
                self.judgeDate(row: self.selectedMinute, InComponent: 4)
            }else{
                self.selectedHour = row%24
            }
        }else{
            
            if(row%60 < self.currentMinute && self.selectedYear == self.currentYear && self.selectedMonth == self.currentMonth && self.selectedDay == self.currentDay && self.selectedHour  == self.currentHour){
                self.datePicker.selectRow(self.currentMinute+6000, inComponent: 4, animated: true)
                self.selectedMinute = self.currentMinute;
            }else{
                self.selectedMinute = row%60
            }
        }
        
    }
    
    
    //判断选择的时间是否大于最大时间或最小时间
    func judgeTime(){
        let date = self.getDateByPickerView()
        if ((self.minimumDate != nil) && date.compare(self.minimumDate as Date) == .orderedAscending) {
            let minComponents = NSDate.dateComponentsFromDate(date: self.minimumDate);
            self.configData(components: minComponents);
        }else if((self.maximumDate != nil) && date.compare(self.maximumDate as Date) == .orderedDescending){
            let maxComponents = NSDate.dateComponentsFromDate(date: self.maximumDate);
            self.configData(components: maxComponents)
        }
    }
    
    
    
    //获取选择的时间
    func getDateByPickerView()->NSDate{
        let year = "\(self.selectedYear!)";
        let month = "\(self.selectedMonth!)";
        let day = "\(self.selectedDay!)";
        let hour = "\(self.selectedHour!)";
        let minute = "\(self.selectedMinute!)";
        let str = "\(year)-\(month)-\(day) \(hour):\(minute)";
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm";
        let date = dateFormatter.date(from: str)
        return date! as NSDate
    }
    
    //
    func getPCDatePickerView()->YMDHMSDatePickerView?{
        let vc : UIViewController! = self.currentVC()
        let subViewsNow = vc.view.subviews
        var datePickerView : YMDHMSDatePickerView! = nil
        for view  in subViewsNow {
            if view is YMDHMSDatePickerView{
                datePickerView = view as! YMDHMSDatePickerView;
                return datePickerView
            }
        }
        return nil;
    }
    
    
    
   
    func currentVC(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentVC(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentVC(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentVC(base: presented)
        }
        return base
    }
    
    
    //显示view是配置相关属性
    func configPickView(){
        self.dateView.backgroundColor = self.backGroundColor != nil ? self.backGroundColor : T_Separtor_Color;
        var components : NSDateComponents! = nil;
        if self.date != nil {
            components = NSDate.dateComponentsFromDate(date: self.date);
        }else{
            components = NSDate.dateComponentsFromDate(date: nil);
        }
        
        if (self.minimumDate != nil) || (self.maximumDate != nil) {
            self.canChoicePastTime = true;
        }
        
        if self.canChoicePastTime != nil {
            self.currentYear = components.year;
            self.currentMonth = components.month;
            self.currentDay = components.day;
            self.currentHour = components.hour;
            self.currentMinute = components.minute;
        }
        self.configData(components: components);
    }
    
    
    func configData(components:NSDateComponents){
        self.datePicker.selectRow(components.year, inComponent: 0, animated: true)
        self.datePicker.selectRow(components.month-1 + 4800, inComponent: 1, animated: true)
        self.datePicker.selectRow(components.day-1 + 6200, inComponent: 2, animated: true)
        self.datePicker.selectRow(components.hour + 4800, inComponent: 3, animated: true)
        self.datePicker.selectRow(components.minute + 6000, inComponent: 4, animated: true);
        
        self.selectedYear = components.year;
        self.selectedMonth = components.month;
        self.selectedDay = components.day;
        self.selectedHour = components.hour;
        self.selectedMinute = components.minute;
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}









extension NSDate{
    
    class func dateComponentsFromDate(date:NSDate?)->NSDateComponents{
        var dateUse : NSDate? = date;
        if dateUse == nil {
            dateUse = NSDate();
        }
        let calendar = NSCalendar.current;
        let _dateComponents = calendar.dateComponents(NSDate.UnitFlags(), from: dateUse! as Date)
        return _dateComponents as NSDateComponents;
    }
    
    //获取当前月的天数
    class func  getNumberOfDaysInMonth(month:Int,year:Int)->Int{
        if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12 {
            return 31;
        }
        if month == 4 || month == 6 || month == 9 || month == 11 {
            return 30;
        }
        if year % 4 == 1 || year % 4 == 2 || year % 4 == 3 {
            return 28;
        }
        if year % 400 == 0 {return 29;}
        if year % 100 == 0 {return 28;}
        return 29;
    }
    
    
    
    class func UnitFlags()->Set<Calendar.Component>{
        var unitFlags : Set<Calendar.Component>! = nil;
        if isIos8 {
            unitFlags = [Calendar.Component.year,.month,.era,.day,.hour,.minute,.second,.weekday,.weekdayOrdinal];
        }else{
            unitFlags = [.year,.month,.day,.hour,.minute,.second,.weekdayOrdinal,.weekday,.weekOfMonth,.weekOfYear];
        }
        return unitFlags;
    }
    
}









