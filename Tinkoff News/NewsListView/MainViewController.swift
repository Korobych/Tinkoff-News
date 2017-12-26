//
//  ViewController.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var newsTableView: UITableView!
    
    var from: Int = 0
    var to: Int = 20
    var newsListStorage: [Int:NewsListModel?] = [:]
    var fullPostsStorage: [CustomNewsTableViewCellData] = []
    var postStorage: SinglePostModel? = nil
    let requestSender: RequestSenderProtocol = RequestSender()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbarStyleSetup()
        tableViewStyleSetup()
        self.newsTableView.delegate = self
        self.newsTableView.dataSource = self
        getNewsList()
        
    }
    
    
    @IBAction func syncButtonTapped(_ sender: Any) {
//        logic dedicated for manual sync the news
//        plus animation of rotation and bouncing is required
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! CustomNewsTableViewCell
        if let post = newsListStorage[indexPath.row] {
            fullPostsStorage.append(CustomNewsTableViewCellData(id: post?.id, text: post?.text, publicationDate: post?.publicationDate, counter: 0, isViewed: false))
            cell.setupCell(title: post?.text, counter: 0, isViewed: false)
        }
        
        if indexPath.row == newsListStorage.count - 1{
            // realisation of pagination
            getNewsList()
        }
        return cell
        
    }
    
    func getNewsList() {
        if newsListStorage.count == 0 {
            self.from = 0
            self.to = 20
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
                    }
                    self?.newsTableView.reloadData()
                    self?.from += 20
                    self?.to += 20
                }
            case .error(let description):
                print("Some error happend: \(description)")
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

}

