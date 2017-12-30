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
}

//struct Post{
//
//    var id: Int!
//    var title: String?
//    var date: String?
//    var content: String?
//}

class ModalPostViewController: UIViewController, RequestSenderDelegateProtocol, WKNavigationDelegate, UIScrollViewDelegate{
    
    weak var delegate: ModalViewControllerDelegate?
    var postsStorage: [CustomNewsTableViewCellData] = []
    var selectedId: Int!
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
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        modalView.layer.cornerRadius = 15
        modalView.layer.masksToBounds = true
        activityIndicator.isHidden = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red:0.22, green:0.22, blue:0.22, alpha:1.0)
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
        let config = RequestsFactory.GetNewsFromAPI.SinglePostConfig(id: postsStorage[selectedId].id!)
        requestSender.send(config: config) { [weak self] (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.sync {
                    let interval = data.modificatedTime
                    guard let postId = self?.selectedId
                    else {
                        print("some trouble in id getting")
                        return
                    }
                    let post = self?.postsStorage[postId]
                    post?.publicationDate = interval.makeMilisecToDate(timeInMillisec: interval)
                    post?.content = data.postText
                    self?.showContent()
                }
            case .error(let description):
                print("Some error happend: \(description)")
            }
        }
    }
    
    func showContent(){
        dateLabel.text = postsStorage[selectedId].publicationDate
        titleLabel.text = postsStorage[selectedId].title
        guard let content = postsStorage[selectedId].content else { return }
        let modifiedHtml = htmlPageConstruct(bodyPart: content)
        webView.loadHTMLString(modifiedHtml, baseURL: nil)
        
        self.postsStorage[selectedId].counter! += 1
        self.postsStorage[selectedId].isViewed = true
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    func showAlert() {
        DispatchQueue.main.async {
            self.titleLabel.text = "Ошибка подключения. Нет соединения с интернетом"
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.cancelButtonClicked(self)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                let host = url.host, !host.hasPrefix("www.google.com"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print(url)
                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
            print("not a user click")
            decisionHandler(.allow)
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    func htmlPageConstruct(bodyPart: String) -> String{
        let currentHTML = """
        <head>
        <link href='https://fonts.googleapis.com/css?family=Montserrat:medium' rel='stylesheet'>
        <style>
        body { font-family: 'Montserrat', serif; font-size:35pt; background-color: #383838; color: white; padding: 20pt }
        p { font-family: 'Roboto', sans-serif; font-size: 35pt }
        a { color: yellow }
        </style>
        </head>
        <body>\(bodyPart)</body>
        """
        return currentHTML
    }
}