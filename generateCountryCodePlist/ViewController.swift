//
//  ViewController.swift
//  generateCountryCodePlist
//
//  Created by Mary Qian on 16/9/23.
//  Copyright © 2016年 User. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        generate()
    }
    
    func generate() {
        let codeDict = getDataFromJson()
        let codeArray2 = addChinese()
        
        var CountryCodeArray = [[String: AnyObject]]()
        var foundNum = 0
        var notFoundNum = 0
        for (_, value) in codeDict {
            var dict = [String: AnyObject]()
            let country = value as! [String: AnyObject]
            
            let dialling = country["dialling"] as! [String: AnyObject]
            let diallingCode = dialling["calling_code"] as! [String]
            let national_number_lengths = dialling["national_number_lengths"]
            
            let name = country["name"] as! [String: AnyObject]
            let common_name = name["common"] as! String
            
            var chinese_name = ""
            
            var name2 = ""
//            for item in codeArray2 {
//                let name = item["enName"]!
//                if name == common_name {
//                    name2 = name!
//                    chinese_name = item["zhName"]!!
//                    foundNum += 1
//                    break
//                }
//            }
//            if name2 == "" {
//                print("\(common_name) not found")
//                notFoundNum += 1
//            }
            
            for item in codeArray2 {
                let code = item["code"]!
                if code == diallingCode.first! {
                    name2 = code!
                    chinese_name = item["zhName"]!!
                    foundNum += 1
                    break
                }
            }
            if name2 == "" {
                print("\(common_name) not found")
                notFoundNum += 1
            }
            
            if isValid(diallingCode) && isValid(national_number_lengths) {
                dict["calling_code"] = diallingCode
                dict["common_name"] = common_name
                dict["national_number_lengths"] = national_number_lengths
                dict["chinese_name"] = chinese_name
                CountryCodeArray.append(dict)
            }
//            else {
//                print(common_name)
//                print("null")
//            }
            
        }
        
        print(foundNum)
        print("============")
        print(notFoundNum)
        
        let countryCodePlistPath = NSBundle.mainBundle().pathForResource("CountryCode.plist", ofType: nil)
        print(countryCodePlistPath)
        let fileArray = CountryCodeArray as NSArray
        let result = fileArray.writeToFile(countryCodePlistPath!, atomically: true)
    }
    
    func isValid(obj: AnyObject?) -> Bool {
        if obj == nil {
            return false
        }
        if obj!.isKindOfClass(NSNull) {
            return false
        }
        return true
    }
    
    func getDataFromJson() -> [String: AnyObject] {
        let stringPath = NSBundle.mainBundle().pathForResource("Directions", ofType: "geojson")
        let data = NSData(contentsOfFile: stringPath!)
        var codeDict = [String: AnyObject]()
        
        do {
            let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
            codeDict = dict as! [String: AnyObject]
        } catch {}
        return codeDict
    }
    
    func addChinese() -> [[String: String?]]{

        let chinesePath = NSBundle.mainBundle().pathForResource("CountryWithChinese", ofType: "geojson")
        let data = NSData(contentsOfFile: chinesePath!)

        var codeArray: [String] = []
        do {
            let temp = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
            codeArray = temp as! [String]
        } catch {
            print("error")
        }
        var printArray = [[String: String?]]()
        for item in codeArray {
            let array = item.componentsSeparatedByString(" ")
            let count = array.count
            var enName = ""
            for i in 0..<(count - 2) {
                enName.appendContentsOf(array[i])
            }
            let zhName = array[count - 2]
            let codeString = array.last!
            let code = codeString.substringFromIndex(codeString.startIndex.advancedBy(1))
            let dict = ["enName": enName, "zhName": zhName, "code": code]
            printArray.append(dict)
        }
        return printArray
    }

}

