//
//  UITableView+Dequeueing.swift
//  MovieDBiOS
//
//  Created by Lidiomar Machado on 30/05/22.
//

import Foundation
import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
