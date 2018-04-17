//
//  second.swift
//  gddCalculator
//
//  Created by Mallika Tiwari on 25/07/16.
//  Copyright © 2016 Mallika Tiwari. All rights reserved.
//

import UIKit

class second: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var planDate: UIDatePicker!
    @IBOutlet weak var senseDate: UIDatePicker!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cumulativeGdd: UILabel!
    var info = [Data2]()
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var items = [String]()
    var cumuGdd:Double = 0.0
    var doneOnce = 0
//    var temps = [Double]()
//    var dates = [String]()
    var pickerData = ["Alfalfa", "Corn", "Cotton", "Grass Hay", "Peanuts", "Sorghum", "Soyabean", "Wheat"]
    var cropTbase:[String:Int] = ["Alfalfa":41, "Corn":50, "Cotton":60, "Grass Hay":50, "Peanuts":55, "Sorghum":55, "Soyabean":50, "Wheat":32]
    var cropTmax:[String:Int] = ["Alfalfa":86, "Corn":86, "Cotton":100, "Grass Hay":86, "Peanuts":95, "Sorghum":95, "Soyabean":95, "Wheat":86]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.myLabel.text = self.items[indexPath.item]
        cell.myLabel.sizeToFit()
        cell.backgroundColor = UIColor.yellow // make cell more visible in our example project
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
    }
    
    func pickerView(_ pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        items.removeAll()
        if(doneOnce == 0) {
            return
        }
        cumuGdd = 0.0
        items.append("Date")
        items.append("GDD")
        print("you are here")
        for i in 0 ..< info.count {
            let minimum = info[i].minTemp
            let maximum = info[i].maxTemp
            let cumu = getGdd(maximum, dayMin: minimum)
            cumuGdd = cumuGdd + cumu
            items.append("\(info[i].time)")
            items.append("\(cumu)")
        }
        collectionView.reloadData()
        print("picker view cumu \(cumuGdd)")
        cumulativeGdd.text = "\(cumuGdd)"
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
    }
    
    @IBAction func calculateCumulativeGdd(_ sender: AnyObject) {
        print(pickerData[pickerView.selectedRow(inComponent: 0)])
        collectionView.reloadData()
        if(zipCode.text == "") {
            alertBox("Please Enter ZIP Code.")
            return
        }
        getData()
        doneOnce = 1
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
    
    func getGdd(_ dayMax: String,dayMin: String) -> Double {
        let crop = pickerData[pickerView.selectedRow(inComponent: 0)]
        let cropMax = cropTmax["\(crop)"]!
        let finalCropMax = Double(cropMax)
        let cropBase = Double(cropTbase["\(crop)"]!)
        let dMax = Double(dayMax)!
        let dMin = Double(dayMin)!
        var tMax:Double
        if(finalCropMax<dMax) {
            tMax = finalCropMax
        } else {
            tMax = dMax
        }
        let cumuGDD = (tMax + dMin)/2 - cropBase
        if(cumuGDD<0) {
            return 0
        } else {
            return cumuGDD
        }
    }
    
    func getData() {
        info.removeAll()
        items.removeAll()
        cumuGdd = 0.0
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        formatter.timeZone = TimeZone(abbreviation: "CDT")
        let planFinal = formatter.string(from: planDate.date)
        let senseFinal = formatter.string(from: senseDate.date)
        //        print(planFinal)
        //        print(senseFinal)
        
        let calendar: Calendar = Calendar.current
        let date1 = calendar.startOfDay(for: planDate.date)
        let date2 = calendar.startOfDay(for: senseDate.date)
        let flags = NSCalendar.Unit.day
        let components = (calendar as NSCalendar).components(flags, from: date1, to: date2, options: [])
        var numberOfDays = components.day! + 1
        
        //        var newDate = addDaystoGivenDate(planDate.date, NumberOfDaysToAdd: 10)
        //        print(formatter.stringFromDate(newDate))
        
        //        print("number of days \(numberOfDays)")
        //        print("number of iterations \(numberOfDays/25)")
        //        print("number of data in last iteration \(numberOfDays%25)")
        
        if(numberOfDays == 1) {
            alertBox("Please enter Different dates")
            return
        } else {
            if(numberOfDays<=25) {
                let myURL = URL(string: "https://api.weathersource.com/v1/0a602b879fa4fb961f5b/history_by_postal_code.json?postal_code_eq=\(zipCode.text!)&limit=25&country_eq=US&timestamp_between=\(planFinal)T18:30+0000,\(senseFinal)T18:30+0000&fields=country,timestamp,tempMax,tempAvg,tempMin")!
                let request = NSMutableURLRequest(url: myURL)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Foundation.Data?, response: URLResponse?, error: NSError?) in
                    do {
                        let jsonresult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        //                            print(jsonresult.valueForKey("response_code")!)
                        if(jsonresult.value(forKey: "response_code") as? String == "400") {
                            DispatchQueue.main.async(execute: {
                                self.alertBox("Wrong Zip Code")
                            })
                            return
                        }
                        self.items.append("Date")
                        self.items.append("GDD")
                        for i in 0 ..< jsonresult.count {
                            let avgtemp = "\(jsonresult[i].value(forKey: "tempAvg")!)"
                            var timestamp = "\(jsonresult[i].value(forKey: "timestamp")!)"
                            let min = "\(jsonresult[i].value(forKey: "tempMin")!)"
                            let max = "\(jsonresult[i].value(forKey: "tempMax")!)"
                            timestamp = String(timestamp.characters.dropLast(15))
                            let d:Data2 = Data2(t: timestamp, temp: avgtemp, min: min, max: max)
                            self.info.append(d)
                            self.items.append("\(timestamp)")
                            let cumu = self.getGdd(max, dayMin: min)
                            self.cumuGdd = self.cumuGdd + cumu
                            self.items.append("\(cumu)")
                        }
                        //                        print("data count \(self.info.count)")
                    } catch{
                        print(error)
                    }
                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                        self.cumulativeGdd.text = "\(self.cumuGdd)"
                        self.cumulativeGdd.sizeToFit()
                    })
                }) 
                task.resume()
            } else {
                var initDate = planDate.date
                while (numberOfDays>=25) {
                    let finalDate = addDaystoGivenDate(initDate, NumberOfDaysToAdd: 24)
                    let initDateString = formatter.string(from: initDate)
                    let finalDateString = formatter.string(from: finalDate)
                    let myURL = URL(string: "https://api.weathersource.com/v1/0a602b879fa4fb961f5b/history_by_postal_code.json?postal_code_eq=\(zipCode.text!)&limit=25&country_eq=US&timestamp_between=\(initDateString)T18:30+0000,\(finalDateString)T18:30+0000&fields=country,timestamp,tempMax,tempAvg,tempMin")!
                    let request = NSMutableURLRequest(url: myURL)
                    request.httpMethod = "GET"
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Foundation.Data?, response: URLResponse?, error: NSError?) in
                        do {
                            let jsonresult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                            //                        print(jsonresult.count)
                            if(jsonresult.value(forKey: "response_code") as? String == "400") {
                                DispatchQueue.main.async(execute: {
                                    self.alertBox("Wrong Zip Code")
                                })
                                return
                            }
                            self.items.append("Date")
                            self.items.append("GDD")
                            for i in 0 ..< jsonresult.count {
                                let avgtemp = "\(jsonresult[i].value(forKey: "tempAvg")!)"
                                var timestamp = "\(jsonresult[i].value(forKey: "timestamp")!)"
                                let min = "\(jsonresult[i].value(forKey: "tempMin")!)"
                                let max = "\(jsonresult[i].value(forKey: "tempMax")!)"
                                timestamp = String(timestamp.characters.dropLast(15))
                                let d:Data2 = Data2(t: timestamp, temp: avgtemp, min: min, max: max)
                                self.info.append(d)
                                self.items.append("\(timestamp)")
                                let cumu = self.getGdd(max, dayMin: min)
                                self.cumuGdd = self.cumuGdd + cumu
                                self.items.append("\(cumu)")
                            }
                            //                            print("data count \(self.info.count)")
                        } catch{
                            print(error)
                        }
                    }) 
                    task.resume()
                    initDate = finalDate
                    initDate = addDaystoGivenDate(initDate, NumberOfDaysToAdd: 1)
                    numberOfDays = numberOfDays - 25
                }
                let finalDate = addDaystoGivenDate(initDate, NumberOfDaysToAdd: numberOfDays - 1)
                let initDateString = formatter.string(from: initDate)
                let finalDateString = formatter.string(from: finalDate)
                let myURL = URL(string: "https://api.weathersource.com/v1/0a602b879fa4fb961f5b/history_by_postal_code.json?postal_code_eq=\(zipCode.text!)&limit=25&country_eq=US&timestamp_between=\(initDateString)T18:30+0000,\(finalDateString)T18:30+0000&fields=country,timestamp,tempMax,tempAvg,tempMin")!
                let request = NSMutableURLRequest(url: myURL)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Foundation.Data?, response: URLResponse?, error: NSError?) in
                    do {
                        let jsonresult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        //                        print(jsonresult.count)
                        if(jsonresult.value(forKey: "response_code") as? String == "400") {
                            DispatchQueue.main.async(execute: {
                                self.alertBox("Wrong Zip Code")
                            })
                            return
                        }
                        for i in 0 ..< jsonresult.count {
                            let avgtemp = "\(jsonresult[i].value(forKey: "tempAvg")!)"
                            var timestamp = "\(jsonresult[i].value(forKey: "timestamp")!)"
                            let min = "\(jsonresult[i].value(forKey: "tempMin")!)"
                            let max = "\(jsonresult[i].value(forKey: "tempMax")!)"
                            timestamp = String(timestamp.characters.dropLast(15))
                            let d:Data2 = Data2(t: timestamp, temp: avgtemp, min: min, max: max)
                            self.info.append(d)
                            self.items.append("\(timestamp)")
                            let cumu = self.getGdd(max, dayMin: min)
                            self.cumuGdd = self.cumuGdd + cumu
                            self.items.append("\(cumu)")
                        }
                        //                        print("data count \(self.info.count)")
                    } catch{
                        print(error)
                    }
                    DispatchQueue.main.async(execute: {
                        print(self.cumuGdd)
                        self.collectionView.reloadData()
                        self.cumulativeGdd.text = "\(self.cumuGdd)"
                        self.cumulativeGdd.sizeToFit()
                    })
                }) 
                task.resume()
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func alertBox(_ msg: String) {
        let refreshAlert = UIAlertController(title: "Error", message: "\(msg)", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            refreshAlert .dismiss(animated: true, completion: nil)
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    func addDaystoGivenDate(_ baseDate:Date,NumberOfDaysToAdd:Int)->Date
    {
        var dateComponents = DateComponents()
        let CurrentCalendar = Calendar.current
        let CalendarOption = NSCalendar.Options()
        
        dateComponents.day = NumberOfDaysToAdd
        
        let newDate = (CurrentCalendar as NSCalendar).date(byAdding: dateComponents, to: baseDate, options: CalendarOption)
        return newDate!
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
