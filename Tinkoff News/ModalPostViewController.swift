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

struct Post {

    var id: Int!
    var title: String?
    var date: String?
    var content: String?
}

class ModalPostViewController: UIViewController{
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        modalView.layer.cornerRadius = 15
        modalView.layer.masksToBounds = true

        webView.isOpaque = false
        //
        loadContent()
    }

    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
        delegate?.refreshContent()
    }
    
    func loadContent() {
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
        webView.loadHTMLString(content, baseURL: nil)
    }
}
