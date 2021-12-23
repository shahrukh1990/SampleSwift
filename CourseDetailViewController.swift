//
//  CourseDetailViewController.swift
//  Prodio
//
//  Created by Shahrukh Jain on 22/03/20.
//  Copyright © 2020 Shahrukh. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import Alamofire
import SwiftRichString
import SwiftAudio
import SwiftyStoreKit
class CourseDetailViewController: UIViewController {
    
    
    @IBOutlet weak var audioView: AudioView!
    @IBOutlet weak var audioViewheightContraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var courseImageView: UIImageView!
    
    @IBOutlet weak var instructorNameLabel: ProdioLabel!
    @IBOutlet weak var courseNameLabel: ProdioLabel!
    
    @IBOutlet weak var durationPointsLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var cpdPointLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    var course : Course!
    var courseID : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 10
        headerView.dropShadow()
        
        
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderColor = UIColorFromRGB(rgbValue: 0xF89A20).cgColor
        profileImageView.layer.borderWidth = 1.5
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProximaNova-Bold", size: 15)!]
        audioView.smallImageView.image = UIImage(named: "cover_place")
        
        
        
        //        let navLabel = UILabel()
        //           let bold = Style {
        //               $0.font = UIFont(name: "ProximaNova-Bold", size: 17)
        //               $0.color =  UIColorFromRGB(rgbValue: 0xF89A20)
        //               $0.backColor = UIColor.clear
        //               $0.smallCaps = [.fromLowercase]
        //           }
        //
        //           let bold2 = Style {
        //                     $0.font = UIFont(name: "ProximaNova-Bold", size: 17)
        //                     $0.color = UIColor.darkText
        //                     $0.backColor = UIColor.clear
        //                     $0.smallCaps = [.fromLowercase]
        //                 }
        //
        
        let logoImage = UIImageView(frame: CGRect(x: 0,y: 0,width: 60,height: 40))
        logoImage.image = UIImage(named: "logo")
        logoImage.contentMode = .scaleAspectFit
        //           let attStr = "Pro".set(style:bold) + "Dio".set(style:bold2)
        //           navLabel.attributedText = attStr
        //
        self.navigationItem.titleView = logoImage
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        self.callCourseDetailAPI()
        
        
        let controller =  AudioController.shared
        if controller.player.currentItem != nil
        {
            audioView.isHidden = false
            audioViewheightContraint.constant = 70
            audioView.setupController()
        }
        else
        {
            audioView.isHidden = true
            audioViewheightContraint.constant = 0
            
        }
        
    }
    
    
    func setData()
    {
        
        
        
        //self.title =  self.course.name!
        self.instructorNameLabel.text = self.course.instructorName!
        self.instructorNameLabel.commonInit()
        
        self.courseNameLabel.text = self.course.name!
        self.courseNameLabel.commonInit()
        
        
        self.durationPointsLabel.text = self.course.duration! + " " +  "hours"
        self.cpdPointLabel.text = self.course.cpdCredit!
        self.descriptionLabel.attributedText = self.course.overview!.htmlToAttributedString
        self.descriptionLabel.textColor = UIColor.darkGray
        self.courseImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.courseImageView.sd_setImage(with: URL(string: BASEURL_MEDIA + course.image!), placeholderImage: UIImage(named: "cover_place"), options: .refreshCached, context: nil)
        
        if course.instructorPicture != nil
        {
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_setImage(with: URL(string: BASEURL_MEDIA + course.instructorPicture!), placeholderImage: UIImage(named: "user_place"), options: .refreshCached, context: nil)
        }
        
        
        if self.course.courseBuy == "1"
        {
            self.buyButton.setTitle("View Course", for: .normal)
            
        }
        else
        {
            self.buyButton.setTitle("CAD " + self.course.price! + " " + "Buy", for: .normal)
            
            
            if course.price! == "0.00"
            {
                self.buyButton.setTitle("View Course", for: .normal)
            }
            
        }
        
    }
    
    @IBAction func miniPlayerTapAction(_ sender: Any) {
        
        let musicPlayerViewController = storyboard!.instantiateViewController(withIdentifier: "MusicPlayerViewController") as! MusicPlayerViewController
        
        musicPlayerViewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(musicPlayerViewController, animated: true, completion: nil)
    }
    
    @IBAction func playerCloseAction(_ sender: Any) {
        
        let controller =  AudioController.shared
        
        controller.player.stop()
        try? controller.player.removeItem(at: 0)
        controller.player.nowPlayingInfoController.clear()
        try? controller.audioSessionController.deactivateSession()
        controller.player.automaticallyUpdateNowPlayingInfo = true
        audioView.isHidden = true
        audioViewheightContraint.constant = 0
        
    }
    
    
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        self.navigationController?
            .popViewController(animated: true)
    }
    
    
    @IBAction func butBtnAction(_ sender: Any) {
        
        
        if getUser() != nil{
            
            if self.course.courseBuy == "1"
            {
                let chapterViewController = storyboard!.instantiateViewController(withIdentifier: "ChapterDetailViewController") as! ChapterDetailViewController
                chapterViewController.course = self.course
                self.navigationController?.pushViewController(chapterViewController, animated: true)
            }
            else
            {
                if course.price! == "0.00"
                {
                    
                    self.callBuyAPI(transcationID: "free")
                    
                }
                else
                    
                {
                    self.purchaseCourse(productId: self.course.productIdentifier!)
                    
                }
                
            }
        }
        else
        {
            
            self.showLoginConfirmation()
        }
        
    }
    
    @IBAction func plusBtnAction(_ sender: Any) {
        
        let button  = sender as! UIButton
        if button.isSelected == true{
            
            self.descriptionLabel.numberOfLines = 0
            
        }
        else{
            self.descriptionLabel.numberOfLines = 10
            
        }
        
        button.isSelected =  !button.isSelected
        
        
    }
    
    
    @IBAction func imageTapAction(_ sender: Any) {
        
        let courseDetailViewController = storyboard!.instantiateViewController(withIdentifier: "OthersProfileViewController") as! OthersProfileViewController
        
        
        courseDetailViewController.instructorId = self.course.instructorID!
        self.navigationController?.pushViewController(courseDetailViewController, animated: true)
        
    }
    
    @IBAction func PreviewBtnAction(_ sender: Any) {
        
        let item =  DefaultAudioItem(audioUrl: BASEURL_MEDIA + course.audio!, artist: "0", title: course.name!, albumTitle: "0", sourceType: .stream, artwork: nil)
        
        let musicPlayerViewController = storyboard!.instantiateViewController(withIdentifier: "MusicPlayerViewController") as! MusicPlayerViewController
        musicPlayerViewController.course = self.course
        musicPlayerViewController.modalPresentationStyle = .fullScreen
        musicPlayerViewController.source = [item]
        self.present(musicPlayerViewController, animated: true, completion: nil)
    }
    
    
    func showLoginConfirmation()
    {
        let actionSheetController: UIAlertController = UIAlertController(title: "ProDio", message: "Please Sign Up or Sign In to purchase courses”", preferredStyle: .alert)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Login", style: .default) { action -> Void in
            
            
            let mystoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = mystoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginController.isFromSkipFlow = true
            loginController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(loginController, animated: true)
            
        }
        
        // create an action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
            
        }
        
        
        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        
        
        present(actionSheetController, animated: true) {
        }
    }
    
    func purchaseCourse(productId : String)
    {
        SVProgressHUD.show(withStatus: "Please wait")
        
        
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            
            SVProgressHUD.dismiss()
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                
                let transactionIdentifier  = product.transaction.transactionIdentifier!
                
                self.callBuyAPI(transcationID: transactionIdentifier)
                
                
            case .error(let error):
                switch error.code {
                case .unknown: showAlert(title: "Failed", message: "Unknown error. Please contact support", on: self)
                case .clientInvalid:  showAlert(title: "Failed", message: "Not allowed to make the payment", on: self)
                case .paymentCancelled: showAlert(title: "Failed", message: "Payment cancelled", on: self)
                case .paymentInvalid: showAlert(title: "Failed", message: "The purchase identifier was invalid", on: self)
                case .paymentNotAllowed: showAlert(title: "Failed", message: "The device is not allowed to make the payment", on: self)
                case .storeProductNotAvailable: showAlert(title: "Failed", message: "The product is not available in the current storefront", on: self)
                case .cloudServicePermissionDenied: showAlert(title: "Failed", message: "Access to cloud service information is not allowed", on: self)
                case .cloudServiceNetworkConnectionFailed: showAlert(title: "Failed", message: "Could not connect to the network", on: self)
                case .cloudServiceRevoked: showAlert(title: "Failed", message: "User has revoked permission to use this cloud service", on: self)
                default: showAlert(title: "Failed", message: (error as NSError).localizedDescription, on: self)
                }
            }
        }
    }
    
    
    func callBuyAPI(transcationID : String)
    {
        
        var userID = ""
        if let currentUser = getUser()
        {
            userID = currentUser.userid!
        }
        else{
            return
        }
        
        SVProgressHUD.show(withStatus: "Please wait")
        
        let parameters: [String: Any] =
        [
            "userid": userID,
            "course_id":self.course.id!,
            "transaction_id" : transcationID,
            "amount" : self.course.price!
            
        ]
        
        let arrRequest = NSMutableArray.init(object: parameters)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrRequest)
        let strR = String(data: jsonData!, encoding: .utf8)
        
        var url = NSString.init(format: "%@ws-course.php?type=BUYIOSCOURSE&signature=5deb0b3dfe08a7ce5337618de5d416fdae773737&data=%@", BASEURL,strR!)
        
        print(url)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
        
        
        
        
        AF.request(url as String, method:.get, parameters: nil,encoding: URLEncoding.default) .responseJSON(completionHandler:  { (response) in
            print(response)
            
            SVProgressHUD.dismiss()
            
            switch response.result {
            case .success(let result):
                print(result)
                let result =  result as? [String : Any]
                if result!["status"] as! String == "true"
                {
                    self.course.courseBuy = "1"
                    self.setData()
                    
                    
                    if (transcationID == "free")
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        let chapterViewController = storyboard.instantiateViewController(withIdentifier: "ChapterDetailViewController") as! ChapterDetailViewController
                        chapterViewController.course = self.course
                        self.navigationController?.pushViewController(chapterViewController, animated: true)
                    }
                    else
                    {
                        showAlert(title: "Success", message: result!["msg"] as! String, on: self)
                    }
                }
                else{
                    showAlert(title: "Failed", message:result!["msg"] as! String, on: self)
                }
            case .failure(let error):
                print(error)
                showAlert(title: "Failed", message: error.localizedDescription, on: self)
                
            }
        })
    }
    
    
    
    
    
    
    
    func callCourseDetailAPI()
    {
        
        
        
        
        
        SVProgressHUD.show(withStatus: "Please wait")
        
        var parameters: [String: Any] =
        [
            "course_id": (self.course != nil) ? self.course.id! : self.courseID!
        ]
        
        if let currentUser = getUser()
        {
            parameters["userid"] = currentUser.userid!
        }
        
        let arrRequest = NSMutableArray.init(object: parameters)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrRequest)
        let strR = String(data: jsonData!, encoding: .utf8)
        
        var url = NSString.init(format: "%@ws-course.php?type=COURSEDETAIL&signature=5deb0b3dfe08a7ce5337618de5d416fdae773737&data=%@", BASEURL,strR!)
        
        print(url)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
        
        
        
        
        AF.request(url as String, method:.get, parameters: nil,encoding: URLEncoding.default) .responseDecodable(of: CourseDetailResponse.self) { (response) in
            print(response)
            
            SVProgressHUD.dismiss()
            
            switch response.result {
            case .success(let result):
                if result.status == "true"
                {
                    self.course = result.data!
                    self.setData()
                }
                else
                {
                    showAlert(title: "Failed", message: result.msg!, on: self)
                }
            case .failure(let error):
                print(error)
                showAlert(title: "Failed", message: error.localizedDescription, on: self)
                
            }
        }
        
        
    }
    
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
    
    
}






extension CourseDetailViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
