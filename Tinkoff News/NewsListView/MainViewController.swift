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
    
    var fullPostsStorage: [CustomNewsTableViewCellData] = []
    var requestSender: RequestSenderProtocol = RequestSender()
    var coreDataStack = CoreDataStack()
    var refreshControl: UIRefreshControl!
    let internetFailAlert = UIAlertController(title: "Оффлайн режим", message: "Отсутствует подключение к сети.", preferredStyle: UIAlertControllerStyle.alert)
    var selectedPost: Int!
    var from: Int = 0
    var to: Int = 20
    var inOfflineMode: Bool = false
    
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
//        <<<bring functionality for smart autoscroll>>>
//        let desiredOffset = CGPoint(x: 0, y: -(self.navigationController?.navigationBar.frame.maxY)!)
//        newsTableView.setContentOffset(desiredOffset, animated: true)
        
        // fixed bug if there is not data at all.
        if fullPostsStorage.count != 0{
            let indexPath = IndexPath(row: 0, section: 0)
            self.newsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fullPostsStorage.count
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
        // background bluring while the module view is presenting
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.overlayBlurredBackgroundView()
        self.selectedPost = indexPath.row
        self.performSegue(withIdentifier: "showModalView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! CustomNewsTableViewCell
        let post = fullPostsStorage[indexPath.row]
        
        cell.setupCell(title: post.title, counter: post.counter! , isViewed: post.isViewed)
        if indexPath.row == fullPostsStorage.count - 1{
            // realisation of pagination
            // offline mode flag checking
            if inOfflineMode == false {
                getNewsList(manual_update: false)
            } else {
                //!!!!!!!!!!!!!!!!!!!
                // upgrade core logic
                print("it's offline mode and there is no more posts over there")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let unreadAction = UIContextualAction(style: .normal, title: "Unread") { (action, view, handler) in
            self.fullPostsStorage[indexPath.row].isViewed = false
            self.newsTableView.reloadRows(at: [indexPath], with: .none)
            
            // saving info about post that user desided to be unread
            guard let news = News.findOrInsertNews(in: self.coreDataStack.saveContext!, with: self.fullPostsStorage[indexPath.row].id!) else {
                print("bug splat")
                return
            }
            news.isViewed = false
            
            self.coreDataStack.saveContext?.perform {
                self.coreDataStack.performSave(context: self.coreDataStack.saveContext!, completionHandler: nil)
            }
            //handler
            handler(true)
            print("Unwatch swipe used")
        }
        unreadAction.backgroundColor = UIColor.blue
        let configuration = UISwipeActionsConfiguration(actions: [unreadAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    
    func getNewsList(manual_update: Bool) {
        syncButton.rotate()
        if fullPostsStorage.count == 0{
            self.from = 0
            self.to = 20
        }
        if manual_update{
            self.fullPostsStorage = []
            self.from = 0
            self.to = 20
            print("Manual update is started")
        }
        let config = RequestsFactory.GetNewsFromAPI.NewsListConfig(from: from, to: to)
        requestSender.send(config: config) { [weak self] (result) in
            switch result {
            case .success(let data):
                // rewrite with perform and read/write functions
                self?.inOfflineMode = false
                guard let saveContext = self?.coreDataStack.saveContext else {
                    fatalError("Core data stack save context is nil!")
                }
                DispatchQueue.main.async {
                    for items in data
                    {
                        let singlePost = CustomNewsTableViewCellData(id: items.id, title: items.text.html2String, content: nil, publicationDate: items.publicationDate, counter: 0, isViewed: false)
                        //
                        guard let news = News.findOrInsertNews(in: saveContext, with: singlePost.id!) else {
                            print("bug splat")
                            return
                        }
                        if news.title == nil{
                            news.title = singlePost.title
                            news.counter = Int16(singlePost.counter!)
                            news.publicationDate = singlePost.publicationDate
                            news.isViewed = singlePost.isViewed
                            
                            self?.fullPostsStorage.append(singlePost)
                        } else{
                            
                            singlePost.counter = Int(news.counter)
                            singlePost.isViewed = news.isViewed
                            
                            self?.fullPostsStorage.append(singlePost)
                        }
                        
                    }
                    
                    self?.coreDataStack.performSave(context: saveContext, completionHandler: nil)
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
            self.syncButton.customView?.layer.removeAllAnimations()
            // no internet handling
            self.coreDataStack.saveContext?.perform {
                guard let news = try? News.findNews(in: self.coreDataStack.saveContext!)
                    else {
                        print("Completion error")
                        return
                }
                if news.count == 0 {
                    // case when core data is empty, generating custom alert
                    let emptyCoreDataAlert = UIAlertController(title: "Отсутствие локальных записей", message: "Для получения данных подключитесь к сети.", preferredStyle: UIAlertControllerStyle.alert)
                    emptyCoreDataAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(emptyCoreDataAlert, animated: true, completion: nil)
                    
                }
                else {
                    self.inOfflineMode = true
                    self.present(self.internetFailAlert, animated: true, completion: nil)
                    print("локальное хранилище не пустое! тут  \(news.count) записей")
                    print("первый элемент с верху \(String(describing: news[0]?.id))")
                    for item in news{
                        guard let intID = item?.id else { return }
                        guard let intCounter = item?.counter else { return }
                        self.fullPostsStorage.append(CustomNewsTableViewCellData(id: Int(intID), title: item?.title, content: item?.content, publicationDate: item?.publicationDate, counter: Int(intCounter), isViewed: (item?.isViewed)!))
                    }
                    DispatchQueue.main.async {
                        self.newsTableView.reloadData()
                    }
                }
            }
        }
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
        let navBarHeight = (self.navigationController?.navigationBar.frame.size.height)!/2.5
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
                    viewController.postsStorage = fullPostsStorage
                    viewController.selectedId = selectedPost
                    viewController.dataStack = coreDataStack
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

