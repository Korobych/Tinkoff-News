//
//  Extentions.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 29.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation
import UIKit

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
// исключение для int переменных в виде количества миллисекунд -> их преобразования в читаемую дату
extension Int{
    func makeMilisecToDate(timeInMillisec: Int) -> String
    {
        let timeInterval = Date(timeIntervalSince1970: (TimeInterval(timeInMillisec / 1000)))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter.string(from: timeInterval)
    }
}
