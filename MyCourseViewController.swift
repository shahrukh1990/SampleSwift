//
//  MyCourseViewController.swift
//  Prodio
//
//  Created by Shahrukh Jain on 22/03/20.
//  Copyright © 2020 Shahrukh. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SVProgressHUD


class MyCourseViewController: UIViewController {
    
    let continueCourseReuseIdentifier = "continue_course"
    let completedCourseReuseIdentifier = "completed_course"
    
    
    @IBOutlet weak var audioView: AudioView!
    @IBOutlet weak var audioViewheightContraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var continueCollectionView: UICollectionView!
    @IBOutlet weak var completedCollectionView: UICollectionView!
    
    
    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var signInBtn: UIButton!
    
    
    
    @IBOutlet weak var continueCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueCollectionTopConstraint: NSLayoutConstraint!
    
    
    var continueCourses = [Course]()
    var completedCourses = [Course]()
    
    var linekdCourseID : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioView.smallImageView.image = UIImage(named: "cover_place")
        
        NotificationCenter.default.addObserver(self, selector: #selector(courseLinkedNotification(notification:)), name: .courseLinked, object: nil)
        
        
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        
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
        
        self.callMyCoursesAPI()
        
    }
    
    @objc func courseLinkedNotification(notification: NSNotification)
    {
        self.callMyCoursesAPI()
    }
    
    
    
    @IBAction func signInBtnAction(_ sender: Any) {
        
        let mystoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController = mystoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginController.isFromSkipFlow = true
        loginController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(loginController, animated: true)
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
    
    
    @IBAction func certificateTapAction(_ sender: Any) {
        
        
        let imageview = sender as! UIButton
        let course =  self.completedCourses[imageview.tag]
        
        
        if  course.certificate != nil
        {
            let webViewController = storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.pdfUrl = course.certificate!
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
        
        
    }
    
    
    
    func callMyCoursesAPI()
    {
        
        var userID = ""
        if let currentUser = getUser()
        {
            userID = currentUser.userid!
            self.messageLabel.isHidden = true
            self.signInBtn.isHidden = true
            
            
        }
        
        else{
            //  return
            self.completedLabel.text = ""
            self.messageLabel.isHidden = false
            self.continueLabel.text = ""
            self.messageLabel.text = "Please Sign Up or Sign In to see your courses"
            self.signInBtn.isHidden = false
            self.completedCollectionViewHeightConstraint.constant = 0
            self.continueCollectionTopConstraint.constant = -10
            
            return
            
        }
        
        SVProgressHUD.show(withStatus: "Please wait")
        
        let parameters: [String: Any] =
        [
            "userid": userID,
        ]
        
        let arrRequest = NSMutableArray.init(object: parameters)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrRequest)
        let strR = String(data: jsonData!, encoding: .utf8)
        
        var url = NSString.init(format: "%@ws-course.php?type=USERCOURSELIST&signature=5deb0b3dfe08a7ce5337618de5d416fdae773737&data=%@", BASEURL,strR!)
        
        print(url)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
        
        
        
        
        AF.request(url as String, method:.get, parameters: nil,encoding: URLEncoding.default) .responseDecodable(of: MyCoursesResponse.self) { (response) in
            print(response)
            
            SVProgressHUD.dismiss()
            
            switch response.result {
            case .success(let result):
                if result.status == "true"
                {
                    
                    
                    self.continueCourses = (result.data?.continueCourse)!
                    self.completedCourses = (result.data?.completedCourse)!
                    
                    
                    self.continueLabel.text = "Continue"
                    self.completedLabel.text = "Completed"
                    self.continueCollectionViewHeightConstraint.constant = 250
                    self.completedCollectionViewHeightConstraint.constant = 250
                    self.continueCollectionTopConstraint.constant = 10
                    
                    
                    
                    if  self.continueCourses.count == 0
                    {
                        self.continueLabel.text = ""
                        self.messageLabel.isHidden = true
                        self.continueCollectionViewHeightConstraint.constant = 0
                        self.continueCollectionTopConstraint.constant = -10
                    }
                    
                    if  self.completedCourses.count == 0
                    {
                        self.completedLabel.text = ""
                        
                        self.messageLabel.isHidden = true
                        self.completedCollectionViewHeightConstraint.constant = 0
                    }
                    
                    if  self.completedCourses.count == 0 && self.continueCourses.count == 0
                    {
                        self.completedLabel.text = ""
                        self.messageLabel.isHidden = false
                        self.continueLabel.text = ""
                        
                        self.completedCollectionViewHeightConstraint.constant = 0
                        self.continueCollectionTopConstraint.constant = -10
                        
                    }
                    
                    
                    
                    self.continueCollectionView.reloadData()
                    self.completedCollectionView.reloadData()
                    
                    self.view.layoutIfNeeded()
                    
                    if (self.linekdCourseID != nil)
                    {
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let courseDetailViewController = storyboard.instantiateViewController(withIdentifier: "CourseDetailViewController") as! CourseDetailViewController
                        courseDetailViewController.courseID = self.linekdCourseID
                        self.navigationController?.pushViewController(courseDetailViewController, animated: true)
                        
                        self.linekdCourseID = nil
                    }
                    
                    
                    
                    
                    
                }
                else
                {
                    self.messageLabel.isHidden = false
                    self.messageLabel.text = "Please add or buy to see your courses"
                    self.completedLabel.text = ""
                    self.continueLabel.text = ""
                    
                    //showAlert(title: "Failed", message: result.msg!, on: self)
                }
            case .failure(let error):
                print(error)
                self.messageLabel.isHidden = true
                self.completedLabel.text = ""
                self.continueLabel.text = ""
                showAlert(title: "Failed", message: error.localizedDescription, on: self)
                
            }
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


extension MyCourseViewController : UICollectionViewDelegate, UICollectionViewDataSource
{
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.continueCollectionView
        {
            return continueCourses.count
        }
        else if collectionView == self.completedCollectionView
        {
            return completedCourses.count
        }
        return  0
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == continueCollectionView
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: continueCourseReuseIdentifier, for: indexPath) as! CourseCollectionViewCell
            
            let course =  self.continueCourses[indexPath.item]
            cell.courseNameLabel.text = course.name!
            cell.instructorName.text = course.instructorName!
            cell.overviewLabel.text = course.overview?.htmlToString
            cell.courseImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            cell.courseImageView.sd_setImage(with: URL(string: BASEURL_MEDIA + course.thumbImage!), placeholderImage: UIImage(named: "cover_place"), options: .refreshCached, context: nil)
            
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: completedCourseReuseIdentifier, for: indexPath) as! CourseCollectionViewCell
            
            let course =  self.completedCourses[indexPath.item]
            cell.courseNameLabel.text = course.name!
            cell.instructorName.text = course.instructorName!
            cell.overviewLabel.text = course.overview?.htmlToString
            cell.certificateImageView.tag = indexPath.item
            cell.courseImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.courseImageView.sd_setImage(with: URL(string: BASEURL_MEDIA + course.thumbImage!), placeholderImage: UIImage(named: "cover_place"), options: .refreshCached, context: nil)
            cell.bringSubviewToFront(cell.certificateImageView)
            cell.certificateImageView.addTarget(self, action: #selector(certificateTapAction(_:)), for: .touchUpInside)
            cell.contentView.isUserInteractionEnabled = false
            return cell
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //let chapterViewController = storyboard!.instantiateViewController(withIdentifier: "ChapterDetailViewController") as! ChapterDetailViewController
        
        let courseDetailViewController = storyboard!.instantiateViewController(withIdentifier: "CourseDetailViewController") as! CourseDetailViewController
        
        
        
        
        if collectionView == self.continueCollectionView
        {
            courseDetailViewController.course = self.continueCourses[indexPath.item]
        }
        else if collectionView == self.completedCollectionView
        {
            courseDetailViewController.course = self.completedCourses[indexPath.item]
        }
        self.navigationController?.pushViewController(courseDetailViewController, animated: true)
        
        
        
        
    }
    
    
    
    
    
    
    
    
}

extension MyCourseViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
}




