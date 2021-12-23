//
//  CourseDetailViewController.swift
//  Prodio
//
//  Created by Shahrukh Jain on 22/03/20.
//  Copyright © 2020 Shahrukh. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SDWebImage
import  SwiftRichString
import SwiftAudio

class ChapterDetailViewController: UIViewController {
    
    
    @IBOutlet weak var audioView: AudioView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableHeadeView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sengemtControl: UISegmentedControl!
    
    
    @IBOutlet weak var instructorNameLabel: ProdioLabel!
    @IBOutlet weak var courseNameLabel: ProdioLabel!
    
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var chapterTableView: UITableView!
    
    
    
    @IBOutlet weak var audioViewheightContraint: NSLayoutConstraint!
    
    
    var course : Course!
    var chapters =  [Chapter]()
    var handouts = [Handout]()
    var selectedQuizSection : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(courseDownloadedNotification(notification:)), name: .downloaded, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(quizRetakeNotification(notification:)), name: .retakeQuiz, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(quizCompletedNotification(notification:)), name: .quizCompleted, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(quizCompletedNotification(notification:)), name: .courseCompleted, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(moduleCompletedNotification(notification:)), name: .moduleCompleted, object: nil)
        
        
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 10
        headerView.dropShadow()
        
        tableHeadeView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 31 / 40 + 71)
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 31 / 40)
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderColor = UIColorFromRGB(rgbValue: 0xF89A20).cgColor
        profileImageView.layer.borderWidth = 1.5
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValue: 0xF89A20), NSAttributedString.Key.font : UIFont(name: "ProximaNova-Regular", size: 13)!], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font : UIFont(name: "ProximaNova-Regular", size: 13)!], for: .normal)
        
        
        self.setData()
        
        
        audioView.smallImageView.image = UIImage(named: "cover_place")
        
        
        
        
        let logoImage = UIImageView(frame: CGRect(x: 0,y: 0,width: 60,height: 40))
        logoImage.image = UIImage(named: "logo")
        logoImage.contentMode = .scaleAspectFit
        
        self.navigationItem.titleView = logoImage
        
        
        // Do any additional setup after loading the view.
        
        
        if self.sengemtControl.selectedSegmentIndex == 0
        {
            self.callModuleAPI()
            
        }
        else
        {
            self.callHandoutAPI()
        }
    }
    
    
    func setData()
    {
        
        
        
        //self.title =  self.course.name!
        self.instructorNameLabel.text = self.course.instructorName!
        self.instructorNameLabel.commonInit()
        
        self.courseNameLabel.text = self.course.name!
        self.courseNameLabel.commonInit()
        self.courseImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.courseImageView.sd_setImage(with: URL(string: BASEURL_MEDIA + course.image!), placeholderImage: UIImage(named: "cover_place"), options: .refreshCached, context: nil)
        
        self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.profileImageView.sd_setImage(with: URL(string: BASEURL_MEDIA + course.instructorPicture!), placeholderImage: UIImage(named: "user_place"), options: .refreshCached, context: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        
        
        
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
        
        self.chapterTableView.reloadData()
        
    }
    
    
    @objc func courseDownloadedNotification(notification: NSNotification)
    {
        self.chapterTableView.reloadData()
    }
    
    @objc func quizCompletedNotification(notification: NSNotification)
    {
        self.callModuleAPI()
    }
    
    @objc func moduleCompletedNotification(notification: NSNotification)
    {
        self.callModuleAPI()
    }
    
    
    @objc func quizRetakeNotification(notification: NSNotification)
    {
        DispatchQueue.main.async {
            
            let userInfo = notification.userInfo
            
            let quizId = userInfo!["quizID"] as! String
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let quizViewController = storyboard.instantiateViewController(withIdentifier: "QuizViewController") as! QuizViewController
            quizViewController.course = self.course
            quizViewController.chapter =  self.chapters[self.selectedQuizSection!]
            quizViewController.quizIndex = self.selectedQuizSection!
            quizViewController.isRetake = true
            quizViewController.quizId = quizId
            
            quizViewController.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            appdelegate.window?.rootViewController!.present(quizViewController, animated: false, completion: nil)
        }
    }
    
    @IBAction func segmentControllerAction(_ sender: Any) {
        
        
        if self.sengemtControl.selectedSegmentIndex == 0
        {
            if self.chapters.count == 0
            {
                self.callModuleAPI()
            }
            else
            {
                self.chapterTableView.reloadData()
            }
            
        }
        else
        {
            if self.handouts.count == 0
            {
                self.callHandoutAPI()
            }
            else
            {
                self.chapterTableView.reloadData()
            }
            
        }
        
    }
    
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        self.navigationController?
            .popViewController(animated: true)
    }
    
    
    
    
    @IBAction func downloadButtonAction(_ sender: UIButton) {
        
        if sender.isSelected == false
        {
            let moduleID = "\(sender.tag)"
            
            currenttlyDownloadingModuleIdS.append(moduleID)
            
            var audioUrl : String!
            var currentChapter : Chapter!
            var currentModule : ModuleFile!
            
            for chapter in self.chapters
            {
                for module in chapter.moduleFiles!
                {
                    if module.id == moduleID
                    {
                        audioUrl = module.audio!
                        currentChapter = chapter
                        currentModule = module
                        break
                    }
                }
            }
            //saveCourseoffine(course: self.course, chapter: currentChapter, module: currentModule)
            self.chapterTableView.reloadData()
            
            downloadAudio(url:  BASEURL_MEDIA + audioUrl, moduleId: moduleID, course: self.course, chapter: currentChapter, module: currentModule) { (success) in
                // SVProgressHUD.dismiss()
                self.chapterTableView.reloadData()
                
            }
        }
        
        
        
    }
    
    
    @IBAction func downloadAllAction(_ sender: Any) {
        
        let downloadBtn = sender as! UIButton
        
        
        let chapter = self.chapters[downloadBtn.tag]
        let modules = chapter.moduleFiles!
        
        
        for module in modules
        {
            
            if (UserDefaults.standard.object(forKey: module.id!) == nil)
            {
                
                if !currenttlyDownloadingModuleIdS.contains(module.id!)
                {
                    currenttlyDownloadingModuleIdS.append(module.id!)
                    
                    let audioUrl : String = module.audio!
                    let currentChapter : Chapter = chapter
                    let currentModule : ModuleFile =  module
                    
                    
                    self.chapterTableView.reloadData()
                    
                    downloadAudio(url:  BASEURL_MEDIA + audioUrl, moduleId: module.id!, course: self.course, chapter: currentChapter, module: currentModule) { (success) in
                        // SVProgressHUD.dismiss()
                        self.chapterTableView.reloadData()
                        
                    }
                }
                
                
            }
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    func callModuleAPI()
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
            "course_id" : self.course.id!
        ]
        
        let arrRequest = NSMutableArray.init(object: parameters)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrRequest)
        let strR = String(data: jsonData!, encoding: .utf8)
        
        var url = NSString.init(format: "%@ws-course.php?type=MODULELIST&signature=5deb0b3dfe08a7ce5337618de5d416fdae773737&data=%@", BASEURL,strR!)
        
        print(url)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
        
        
        
        
        AF.request(url as String, method:.get, parameters: nil,encoding: URLEncoding.default) .responseDecodable(of: ModuleResponse.self) { (response) in
            print(response)
            
            SVProgressHUD.dismiss()
            
            switch response.result {
            case .success(let result):
                if result.status == "true"
                {
                    
                    
                    self.chapters = result.data!
                    self.chapterTableView.reloadData()
                    
                    
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
    
    
    
    func callHandoutAPI()
    {
        
        self.chapterTableView.reloadData()
        
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
            "course_id":self.course.id!
            
        ]
        
        let arrRequest = NSMutableArray.init(object: parameters)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: arrRequest)
        let strR = String(data: jsonData!, encoding: .utf8)
        
        var url = NSString.init(format: "%@ws-course.php?type=HANDOUTSLIST&signature=5deb0b3dfe08a7ce5337618de5d416fdae773737&data=%@", BASEURL,strR!)
        
        print(url)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
        
        
        
        
        AF.request(url as String, method:.get, parameters: nil,encoding: URLEncoding.default) .responseDecodable(of: HandoutRespones.self) { (response) in
            print(response)
            
            SVProgressHUD.dismiss()
            
            switch response.result {
            case .success(let result):
                if result.status == "true"
                {
                    self.handouts = result.data!
                    self.chapterTableView.reloadData()
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
    
    
    func openQuiz(course : Course,chapter : Chapter, quizIndex : Int, isLastQuiz : Bool )
    {
        
        
        let controller =  AudioController.shared
        if controller.player.currentItem != nil
        {
            let actionSheetController: UIAlertController = UIAlertController(title: "ProDio", message: "In order to access the Quiz, we need to close the Audio Player. Please confirm.", preferredStyle: .alert)
            
            // create an action
            let firstAction: UIAlertAction = UIAlertAction(title: "Confirm", style: .default) { action -> Void in
                
                
                controller.player.stop()
                try? controller.player.removeItem(at: 0)
                
                self.audioView.isHidden = true
                self.audioViewheightContraint.constant = 0
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.selectedQuizSection  = quizIndex
                let quizViewController = storyboard.instantiateViewController(withIdentifier: "QuizViewController") as! QuizViewController
                quizViewController.course = course
                quizViewController.chapter =  chapter
                quizViewController.quizIndex = quizIndex
                quizViewController.isLastQuiz = isLastQuiz
                quizViewController.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
                appdelegate.window?.rootViewController!.present(quizViewController, animated: false, completion: nil)
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
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.selectedQuizSection  = quizIndex
            let quizViewController = storyboard.instantiateViewController(withIdentifier: "QuizViewController") as! QuizViewController
            quizViewController.course = course
            quizViewController.chapter =  chapter
            quizViewController.quizIndex = quizIndex
            quizViewController.isLastQuiz = isLastQuiz
            quizViewController.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            appdelegate.window?.rootViewController!.present(quizViewController, animated: false, completion: nil)
            
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


extension ChapterDetailViewController : UITableViewDelegate, UITableViewDataSource
{
    // number of rows in table view
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if sengemtControl.selectedSegmentIndex == 0
        {
            return  self.chapters.count
            
        }
        else{
            return  self.handouts.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sengemtControl.selectedSegmentIndex == 0
        {
            let chapter = self.chapters[section]
            return chapter.moduleFiles!.count +  3
            
        }
        else{
            let handout = self.handouts[section]
            return handout.handoutFiles!.count
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if sengemtControl.selectedSegmentIndex == 0
        {
            return 20
            
        }
        else{
            return 20
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        
        if sengemtControl.selectedSegmentIndex == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "main_header_cell")
            let chapter = self.chapters[section]
            
            let namelabel = cell?.viewWithTag(100) as! UILabel
            namelabel.text = "Chapter " + "\(section + 1) : " + chapter.title!
            
            let downloadAllBtn = cell?.viewWithTag(200) as! UIButton
            downloadAllBtn.tag = section
            downloadAllBtn.isHidden = true
            
            
            for module in chapter.moduleFiles!
            {
                if (UserDefaults.standard.object(forKey: module.id!) == nil)
                {
                    downloadAllBtn.isHidden = false
                    break
                    
                }
            }
            
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "main_header_cell")
            let handout = self.handouts[section]
            
            let namelabel = cell?.viewWithTag(100) as! UILabel
            namelabel.text = "Chapter " + "\(section + 1) : " + handout.title!
            
            let downloadAllBtn = cell?.viewWithTag(200) as! UIButton
            downloadAllBtn.isHidden = true
            
            return cell
        }
        
    }
    
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if sengemtControl.selectedSegmentIndex == 0
        {
            // create a new cell if needed or reuse an old one
            let chapter = self.chapters[indexPath.section]
            
            if indexPath.row == 0
            {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "header_cell")
                let typelabel = cell?.viewWithTag(100) as! UILabel
                let countlabel = cell?.viewWithTag(200) as! UILabel
                
                typelabel.text = "Modules"
                countlabel.text = "\(chapter.moduleFiles!.count)"
                
                return cell!
            }
            
            else if indexPath.row == chapter.moduleFiles!.count + 1
            {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "header_cell")
                let typelabel = cell?.viewWithTag(100) as! UILabel
                let countlabel = cell?.viewWithTag(200) as! UILabel
                
                typelabel.text = "Quiz"
                countlabel.text = chapter.noOfQuestions!
                
                return cell!
            }
            
            
            else if indexPath.row == chapter.moduleFiles!.count + 2
            {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "quiz_cell") as! ChapterTableViewCell
                let chapter = self.chapters[indexPath.section]
                
                
                cell.moduleNameLabel.text = "Quiz: Chapter " + "\(indexPath.section + 1) " + "Review"
                cell.durationLabel.text = "Quiz - " + chapter.noOfQuestions! + " Questions"
                
                if chapter.isQuizComplete == "0"
                {
                    cell.courseCompleteBtn.isSelected = false
                }
                else{
                    cell.courseCompleteBtn.isSelected = true
                    
                }
                
                return cell
            }
            
            
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "chapter_cell") as! ChapterTableViewCell
                let chapter = self.chapters[indexPath.section]
                let module = chapter.moduleFiles![indexPath.row - 1]
                
                cell.courseImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.courseImageView.sd_setImage(with: URL(string: BASEURL_MEDIA + course.image!), placeholderImage: UIImage(named: "cover_place"), options: .refreshCached, context: nil)
                cell.moduleNameLabel.text = module.moduleName!
                cell.durationLabel.text = "Audio - " + module.duration! + " Min"
                cell.downloadBtn.tag = Int(module.id!)!
                
                
                if (UserDefaults.standard.object(forKey: module.id!) != nil)
                {
                    cell.downloadBtn.isSelected = true
                }
                else
                {
                    cell.downloadBtn.isSelected = false
                    
                }
                
                if currenttlyDownloadingModuleIdS.contains(module.id!)
                {
                    cell.activityIndicator.startAnimating()
                    cell.downloadBtn.isHidden = true
                    
                }
                else
                {
                    cell.activityIndicator.stopAnimating()
                    cell.downloadBtn.isHidden = false
                    
                }
                
                
                cell.bringSubviewToFront( cell.downloadBtn)
                cell.contentView.bringSubviewToFront( cell.downloadBtn)
                cell.backView.bringSubviewToFront( cell.downloadBtn)
                if module.isModuleComeplete == "0"
                {
                    cell.courseCompleteBtn.isSelected = false
                }
                else{
                    cell.courseCompleteBtn.isSelected = true
                    
                }
                
                return cell
            }
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "handouts_cell") as! ChapterTableViewCell
            let handout = self.handouts[indexPath.section]
            let module = handout.handoutFiles![indexPath.row]
            
            cell.courseImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.courseImageView.sd_setImage(with: URL(string: BASEURL_MEDIA + module.backgroundImage!), placeholderImage: UIImage(named: "cover_place"), options: .refreshCached, context: nil)
            cell.moduleNameLabel.text = module.title!
            cell.durationLabel.text = module.type!
            
            
            
            
            return cell
            
        }
        
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if sengemtControl.selectedSegmentIndex == 0
        {
            let chapter = self.chapters[indexPath.section]
            
            
            if indexPath.row == 0
            {
                return 40
            }
            
            else if indexPath.row == chapter.moduleFiles!.count + 1
            {
                return 50
            }
            
            else if indexPath.row == chapter.moduleFiles!.count + 2
            {
                return 70
            }
            
            return 100
        }
        else
        {
            return 100
            
        }
        
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        
        if sengemtControl.selectedSegmentIndex == 0
        {
            let chapter = self.chapters[indexPath.section]
            
            if indexPath.row == 0
            {
                // Module header click
            }
            else if indexPath.row == chapter.moduleFiles!.count + 1{
                // Quiz header click
                
                
            }
            
            else if indexPath.row == chapter.moduleFiles!.count + 2
            {
                //Quiz clicl
                
                //let chapter = self.chapters[indexPath.section]
                
                
                DispatchQueue.main.async {
                    
                    if self.course.isCourseComplete == "0"
                    {
                        if indexPath.section == self.chapters.count - 1
                        {
                            var index = 0
                            for chapter in self.chapters
                            {
                                for module in chapter.moduleFiles!
                                {
                                    if module.isModuleComeplete == "0"
                                    {
                                        showAlert(title: "ProDio", message: "Our system indicates that not all items in this course are completed. Before taking the final quiz, please check and complete all modules/quizzes", on: self)
                                        return
                                    }
                                }
                                
                                if index != self.chapters.count - 1
                                {
                                    if chapter.isQuizComplete == "0"
                                    {
                                        showAlert(title: "ProDio", message: "Our system indicates that not all items in this course are completed. Before taking the final quiz, please check and complete all modules/quizzes", on: self)
                                        return
                                    }
                                }
                                index = index + 1
                            }
                            
                            
                            
                            
                            self.openQuiz(course: self.course, chapter: self.chapters[indexPath.section], quizIndex: indexPath.section, isLastQuiz: true)
                            
                            
                        }
                        else{
                            
                            self.openQuiz(course: self.course, chapter: self.chapters[indexPath.section], quizIndex: indexPath.section, isLastQuiz: false)
                            
                        }
                        
                        
                    }
                }
                
                
                
                
                
                
                
                
            }
            else{
                
                //audio click
                
                let chapter = self.chapters[indexPath.section]
                let module = chapter.moduleFiles![indexPath.row - 1]
                
                let musicPlayerViewController = storyboard!.instantiateViewController(withIdentifier: "MusicPlayerViewController") as! MusicPlayerViewController
                musicPlayerViewController.course = self.course
                musicPlayerViewController.chapters = self.chapters
                musicPlayerViewController.currentPlayingModule = module
                musicPlayerViewController.currentPlayingChapter = chapter
                //musicPlayerViewController.source = [item]
                musicPlayerViewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(musicPlayerViewController, animated: true, completion: nil)
                
            }
            
            
            
        }
        else{
            
            
            let handout = self.handouts[indexPath.section]
            let module = handout.handoutFiles![indexPath.row]
            let webViewController = storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.pdfUrl = BASEURL_MEDIA + module.file!
            self.navigationController?.pushViewController(webViewController, animated: true)
            
            
        }
        
        
        
        
        
        
        
    }
    
    
    
    
}





extension ChapterDetailViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
