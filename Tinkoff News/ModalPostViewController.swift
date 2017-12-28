//
//  ModalPostViewController.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 27.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import UIKit
import WebKit

protocol ModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
    func refreshContent()
    func counterFixer()
}

struct Post {

    var id: Int!
    var title: String?
    var date: String?
    var content: String?
}

class ModalPostViewController: UIViewController, RequestSenderDelegateProtocol{
    
    weak var delegate: ModalViewControllerDelegate?
    var postsMass: [Post] = []
    var listMass: [CustomNewsTableViewCellData] = []
    var modelMass: [SinglePostModel] = []
    var selectedId: Int!
    var selectedTitle: String?
    var requestSender: RequestSenderProtocol = RequestSender()
    
    
    
    @IBOutlet weak var modalView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSender.requestDelegate = self
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        modalView.layer.cornerRadius = 15
        modalView.layer.masksToBounds = true
        activityIndicator.isHidden = false
        webView.isOpaque = false
        //
        loadContent()
    }

    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.delegate?.refreshContent()
            self.delegate?.removeBlurredBackgroundView()
        }
    }
    
    func loadContent() {
        activityIndicator.startAnimating()
        let config = RequestsFactory.GetNewsFromAPI.SinglePostConfig(id: selectedId)
        requestSender.send(config: config) { [weak self] (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.sync {
                    let interval = data.modificatedTime
                    self?.postsMass.append(Post(id: self?.selectedId, title: self?.selectedTitle, date: interval.makeMilisecToDate(timeInMillisec: interval), content: data.postText))
                    self?.showContent()
                }
            case .error(let description):
                print("Some error happend: \(description)")
            }
        }
    }
    
    func showContent(){
        dateLabel.text = postsMass.last?.date
        titleLabel.text = postsMass.last?.title
        guard let content = postsMass.last?.content else {return}
        let modifiedHtml = htmlPageConstruct(bodyPart: content)
        webView.loadHTMLString(modifiedHtml, baseURL: nil)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    func showAlert() {
        DispatchQueue.main.async {
            self.titleLabel.text = "Ошибка подключения. Нет соединения с интернетом"
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            // function to decrease views counter
            self.delegate?.counterFixer()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.cancelButtonClicked(self)
        }
    }
    
    func htmlPageConstruct(bodyPart: String) -> String{
        let currentHTML = """
        <head>
        <link href='https://fonts.googleapis.com/css?family=Roboto' rel='stylesheet'>
        <style>
        @font-face { font-family: 'Metropolis'; src: url('Metropolis-ExtraBold.otf')}
        body { font-family: 'Roboto', sans-serif; font-size:35pt; background-color: #383838; color: white; padding: 40pt }
        h1 { font-family: 'Metropolis', sans-serif; font-size: 36pt; color: black; }
        p { font-family: 'Roboto', sans-serif; font-size: 35pt }
        a { color: red }
        </style>
        </head>
        <body>\(bodyPart)</body>
        """
        return currentHTML
    }
    
    
}
