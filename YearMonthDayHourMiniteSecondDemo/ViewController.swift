//
//  ViewController.swift
//  YearMonthDayHourMiniteSecondDemo
//
//  Created by 刘隆昌 on 2017/11/25.
//  Copyright © 2017年 刘隆昌. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var datePicker : YMDHMSDatePickerView! = YMDHMSDatePickerView();
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
        self.view.addSubview(self.datePicker);
        datePicker.doneAction = {(date:NSDate) in
            
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm";
            let strDate = dateFormatter.string(from: date as Date);
            print("\(strDate)");
            
        }
        
        
        let btn = UIButton(type: .custom)
        self.view.addSubview(btn);
        btn.frame = CGRect.init(x: 100, y: 100, width: 100, height: 40);
        btn.addTarget(self, action: #selector(ViewController.btnAction(btn:)), for: .touchUpInside)
        btn.backgroundColor = UIColor.black;
        
    }
    
    
    
    @objc func btnAction(btn:UIButton){
        
        self.datePicker.showView();
        
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

