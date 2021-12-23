//
//  CourseCompleteViewController.swift
//  Prodio
//
//  Created by Shahrukh Jain on 22/05/20.
//  Copyright © 2020 Shahrukh. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SideMenuSwift


class CourseCompleteViewController: UIViewController, UITextViewDelegate {
    
    
    var firstRating  : Int!
    var secondRating  : Int!
    var thirdRating  : Int!
    var fourthRating  : Int!
    var fifthRating  : Int!
    var sixthRating  : Int!
    
    
    
    @IBOutlet weak var commentTextView  : UITextView!
    @IBOutlet weak var ratingLabel  : UILabel!
    
    var course : Course!
    var certificate : String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        let rating = Float(firstRating! + secondRating! + thirdRating! + fourthRating! + fifthRating! + sixthRating!) /  6.0
        self.ratingLabel.text =  String(format: "%.2f", rating)
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func finishButtonAction(_ sender: Any) {
        
        self.callEvaluationAPI()
    }
    
    
    
    
    
    
    
    
    func callEvaluationAPI()
    {
        SVProgressHUD.show(withStatus: "Please Wait")
        var userID = ""
        if let currentUser = getUser()
        {
            userID = currentUser.userid!
            
        }
        let parameters: [String: Any] =
        [
            "userid": userID,
            "course_id" : self.course.id!,
            "rating1" : "\(firstRating!)",
            "rating2" : "\(secondRating!)",
            "rating3" : "\(thirdRating!)",
            "rating4" : "\(fourthRating!)",
            "rating5" : "\(fifthRating!)",
            "rating6" : "\(sixthRating!)",
            "comments" :  (self.commentTextView.text == "Enter Your Review") ? "" : self.commentTextView.text!
            
            
        ]
        
        let arrRequest = NSMutableArray.init(object: parameters)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrRequest)
        let strR = String(data: jsonData!, encoding: .utf8)
        
        var url = NSString.init(format: "%@ws-course.php?type=COURSEEVALUATION&data=%@", BASEURL,strR!)
        
        print(url)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
        print(url)
        
        AF.request(url as String, method:.post, parameters: parameters,encoding: URLEncoding.default) .responseJSON { (response) in
            print(response)
            
            SVProgressHUD.dismiss()
            
            switch response.result {
            case .success(let result):
                let result =  result as? [String : Any]
                if result!["status"] as! String == "true"
                {
                    self.dismiss(animated: false) {
                        
                        if  let sideMenuController = appdelegate.window?.rootViewController as? SideMenuController
                        {
                            if let homeViewController = sideMenuController.contentViewController as? HomeTabViewController
                            {
                                let navigationController = homeViewController.selectedViewController as! UINavigationController
                                navigationController.popToRootViewController(animated: false)
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                                webViewController.pdfUrl = self.certificate!
                                navigationController.pushViewController(webViewController, animated: true)
                                
                                
                            }
                        }
                        
                    }
                    
                }
                else{
                    showAlert(title: "Failed", message:result!["msg"] as! String, on: self)
                }
            case .failure(let error):
                print(error)
                showAlert(title: "Failed", message: error.localizedDescription, on: self)
            }
        }
        
    }
    
    
    
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Enter Your Review"
        {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
    }
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Your Review"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


