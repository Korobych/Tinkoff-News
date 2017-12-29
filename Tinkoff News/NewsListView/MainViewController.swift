//
//  ViewController.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RequestSenderDelegateProtocol, ModalViewControllerDelegate {
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    var newsListStorage: [Int:NewsListModel?] = [:]
    var fullPostsStorage: [CustomNewsTableViewCellData] = []
    var requestSender: RequestSenderProtocol = RequestSender()
    var refreshControl: UIRefreshControl!
    let internetFailAlert = UIAlertController(title: "Обновление данных", message: "Отсутствует подключение к сети.", preferredStyle: UIAlertControllerStyle.alert)
    var selectedPost: Int!
    var from: Int = 0
    var to: Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newsTableView.delegate = self
        self.newsTableView.dataSource = self
        self.requestSender.requestDelegate = self
        navbarStyleSetup()
        tableViewStyleSetup()
        setRefreshControl()
        self.internetFailAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        //
        getNewsList(manual_update: false)
        
    }
    
    @IBAction func syncButtonTapped(_ sender: Any) {
//        logic dedicated for manual sync the news
//        plus animation of rotation is required
    }
    
    @IBAction func upButtonClick(_ sender: Any) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.newsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        let desiredOffset = CGPoint(x: 0, y: -(self.navigationController?.navigationBar.frame.maxY)!)
        newsTableView.setContentOffset(desiredOffset, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsListStorage.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // добавляем размытие фона вместе с открытием модульного окна
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.overlayBlurredBackgroundView()
        self.selectedPost = indexPath.row
        self.fullPostsStorage[selectedPost].counter! += 1
        self.fullPostsStorage[selectedPost].isViewed = true
        self.performSegue(withIdentifier: "showModalView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! CustomNewsTableViewCell
        if let post = newsListStorage[indexPath.row] {
            cell.setupCell(title: post?.text.html2String, counter: fullPostsStorage[indexPath.row].counter! , isViewed: fullPostsStorage[indexPath.row].isViewed)
        }        
        if indexPath.row == newsListStorage.count - 1{
            // realisation of pagination
            getNewsList(manual_update: false)
        }
        return cell
        
    }

    
    func getNewsList(manual_update: Bool) {
        syncButton.rotate()
        if newsListStorage.count == 0{
            self.from = 0
            self.to = 20
        }
        if manual_update{
            // upgrade logic
            self.newsListStorage = [:]
            self.fullPostsStorage = []
            self.from = 0
            self.to = 20
            print("Manual update is started")
        }
        let config = RequestsFactory.GetNewsFromAPI.NewsListConfig(from: from, to: to)
        requestSender.send(config: config) { [weak self] (result) in
            switch result {
            case .success(let data):
                let number = self?.newsListStorage.count
                DispatchQueue.main.sync {
                    for (item, items) in data.enumerated()
                    {
                        // offers pagination
                        self?.newsListStorage[item + number!] = items
                        //
                        self?.fullPostsStorage.append(CustomNewsTableViewCellData(id: items.id, text: items.text.html2String, publicationDate: items.publicationDate, counter: 0, isViewed: false))
                    }
                    self?.syncButton.customView?.layer.removeAllAnimations()
                    self?.newsTableView.reloadData()
                    self?.from += 20
                    self?.to += 20
                }
            case .error(let description):
                print("Some error happend: \(description)")
            }
        }
    }
    
    func showAlert() {
        DispatchQueue.main.async {
            self.present(self.internetFailAlert, animated: true, completion: nil)
            self.syncButton.customView?.layer.removeAllAnimations()
        }
    }
    
    func noInternetFixer() {
        self.fullPostsStorage[selectedPost].isViewed = false
        self.fullPostsStorage[selectedPost].counter! -= 1
    }
}


extension MainViewController {
    func navbarStyleSetup()
    {
        self.navigationItem.title = "Tinkoff News"
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 0.8479318443)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func tableViewStyleSetup()
    {
        newsTableView.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        newsTableView.separatorColor = UIColor.black
    }
    
    func setRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Проверка обновлений", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        newsTableView.refreshControl = refreshControl
    }
    
    // Настройка работы и + ее плавности refreshController'а
    @objc func refresh(refreshControl: UIRefreshControl) {
        getNewsList(manual_update: true)
        let navBarHeight = (self.navigationController?.navigationBar.frame.size.height)!/2
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        self.newsTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
            self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: navBarWidth!, height: navBarHeight)
        }
    }
    
    func overlayBlurredBackgroundView(){
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.tag = 123
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        view.addSubview(blurredBackgroundView)
    }
    
    func removeBlurredBackgroundView() {
        for v in (view?.subviews)!
        {
            if v.tag == 123
            {
                v.removeFromSuperview()
            }
        }
    }
    
    func refreshContent() {
        DispatchQueue.main.async {
            self.newsTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showModalView" {
                if let viewController = segue.destination as? ModalPostViewController {
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    // не обязательно
                    viewController.listMass = fullPostsStorage
                    //
                    viewController.selectedTitle = fullPostsStorage[selectedPost].text
                    viewController.selectedId = fullPostsStorage[selectedPost].id
                }
            }
        }
    }


}
// Кейс добавления анимации для элемента UIBarButtonItem
extension UIBarButtonItem {
    func rotate(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        self.customView?.layer.add(rotateAnimation, forKey: nil)
        
    }
}
// Исключения для обработки кейса наличия html-alike тайтлов из API
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

