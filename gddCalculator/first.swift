//
//  first.swift
//  gddCalculator
//
//  Created by Mallika Tiwari on 25/07/16.
//  Copyright © 2016 Mallika Tiwari. All rights reserved.
//

import UIKit
import Charts
class first: UIViewController {
        
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var planDate: UIDatePicker!
    @IBOutlet weak var gddCount: UILabel!
    @IBOutlet weak var senseDate: UIDatePicker!
    @IBOutlet weak var zipCode: UITextField!
    var info = [Data]()
    var temps = [Double]()
    var dates = [String]()
    var gc:Int = Int()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        gddCount.text = "0"
    }
    
    @IBAction func calculateButton(_ sender: AnyObject) {
        if(zipCode.text == "") {
            alertBox("Please Enter ZIP Code.")
            return
        }
        info.removeAll()
        temps.removeAll()
        dates.removeAll()
        gc = 0
        print("new data")
        getData()
    }
    
    func getData() {
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
        
                print("number of days \(numberOfDays)")
        var numberOfDays2 = numberOfDays
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
                        for i in 0 ..< jsonresult.count {
                            let avgtemp = "\(jsonresult[i].value(forKey: "tempAvg")!)"
                            var timestamp = "\(jsonresult[i].value(forKey: "timestamp")!)"
                            timestamp = String(timestamp.characters.dropLast(15))
                            let d:Data = Data(t: timestamp, temp: avgtemp)
                            self.info.append(d)
                        }
//                        print("data count \(self.info.count)")
                    } catch{
                        print(error)
                    }
                    DispatchQueue.main.async(execute: {
//                        print(self.info)
                        for i in 0 ..< self.info.count {
                            let temp = Double(self.info[i].avgTemp)
                            self.temps.append(temp!)
                            self.dates.append(self.info[i].time)
                            if(self.temps[i]>=40) {
                                self.gc += 1
                            }
                        }
                        self.gddCount.text = "\(self.gc)"
                        self.setChart(self.dates, values: self.temps)
                    })
                }) 
                task.resume()
            } else {
//                var initDate = planDate.date
                var initDate = addDaystoGivenDate(planDate.date, NumberOfDaysToAdd: 0)
                while (numberOfDays>=25) {
                    let finalDate = addDaystoGivenDate(initDate, NumberOfDaysToAdd: 24)
                    let initDateString = formatter.string(from: initDate)
                    let finalDateString = formatter.string(from: finalDate)
//                    print("inside while initial date \(initDateString)")
//                    print("inside while final date \(finalDateString)")
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
                            DispatchQueue.main.async(execute: {
                            for i in 0 ..< jsonresult.count {
                                let avgtemp = "\(jsonresult[i].value(forKey: "tempAvg")!)"
                                var timestamp = "\(jsonresult[i].value(forKey: "timestamp")!)"
                                print("\(timestamp) \(avgtemp)")
                                timestamp = String(timestamp.characters.dropLast(15))
                                let d:Data = Data(t: timestamp, temp: avgtemp)
                                self.info.append(d)
                            }
                            })
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
//                print("outside while initial date \(initDateString)")
//                print("outside while final date \(finalDateString)")
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
//for taken from here
                        DispatchQueue.main.async(execute: {
                        for i in 0 ..< jsonresult.count {
                            let avgtemp = "\(jsonresult[i].value(forKey: "tempAvg")!)"
                            var timestamp = "\(jsonresult[i].value(forKey: "timestamp")!)"
                            print("\(timestamp) \(avgtemp)")
                            timestamp = String(timestamp.characters.dropLast(15))
                            let d:Data = Data(t: timestamp, temp: avgtemp)
                            self.info.append(d)
                        }
                        })
                        print("data count \(self.info.count)")
                    } catch{
                        print(error)
                    }
                    
                    DispatchQueue.main.async(execute: {
                        print(self.info.count)
                        for i in 0 ..< self.info.count {
                            let temp = Double(self.info[i].avgTemp)
                            self.temps.append(temp!)
                            self.dates.append(self.info[i].time)
                            if(self.temps[i]>=40) {
                                self.gc += 1
                            }
                        }
                        self.gddCount.text = "\(self.gc)"
                        self.setChart(self.dates, values: self.temps)
                    })
                }) 
                task.resume()
            }
        }
    }
    
    func setChart(_ dataPoints: [String], values: [Double]) {
        barChart.noDataText = "You need to provide data for the chart."
        barChart.descriptionText = "GDD"
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Average Temperature")
        chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        barChart.data = chartData
        barChart.animate(xAxisDuration: 0.75, yAxisDuration: 0.75, easingOption: .linear)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
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
}
