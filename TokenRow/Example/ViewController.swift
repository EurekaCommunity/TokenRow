//
//  ViewController.swift
//  Example
//
//  Copyright © 2016 Xmartlabs SRL. All rights reserved.
//

import UIKit
import Eureka
import TokenRow
import CLTokenInputView
import Alamofire
import AlamofireImage

class ViewController: FormViewController {

    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section()
            <<< TokenAccessoryRow<String>() {
                $0.placeholder = "Choose from collection view"
                $0.options = ["Peter Schmeichel", "David de Gea", "Oliver Kahn", "Fabien Barthez", "Tim Howard", "Gianluigi Buffon"]
            }
            +++ Section()
            <<< TokenTableRow<String>() {
                $0.placeholder = "Choose from table"
                $0.options = ["Peter Schmeichel", "David de Gea", "Oliver Kahn", "Fabien Barthez", "Tim Howard", "Gianluigi Buffon"]
            }

            +++ Section("Customized Collection View")
            <<< TokenAccessoryRow<String>() {
                $0.title = "A title:"
                $0.options = ["Peter Schmeichel", "David de Gea", "Oliver Kahn", "Fabien Barthez", "Tim Howard", "Gianluigi Buffon"]
            }.cellSetup({ (cell, row) in
                (cell.collectionViewLayout  as? UICollectionViewFlowLayout)?.sectionInset = .zero
                (cell.collectionViewLayout  as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 40
                cell.customizeCollectionViewCell = { _, cvcell in
                    cvcell.label.textColor = UIColor.red
                    cvcell.layer.borderColor = UIColor.red.cgColor
                    cvcell.layer.borderWidth = 1
                    cvcell.layer.cornerRadius = 4
                }
            })

            //Let's implement a row that asychronously fetches results from Github User search API
            +++ Section("Loading tokens asynchronously")
            <<< TokenTableRow<User>() { row in
                row.placeholder = "Enter Github user name"
                row.getTokensForString = { [weak self, row] string in
                    guard let me = self else { return nil }
                    if me.timer != nil {
                        me.invalidateTimer()
                    }
                    me.timer = Timer.scheduledTimer(timeInterval: 0.5, target: me, selector: #selector(ViewController.timerFired(_:)), userInfo: ["text": string, "row": row], repeats: false)

                    return []
                }
        }.cellSetup({ (cell, row) in
            cell.customizeTableViewCell = { (user: User, cell: TRTableViewCell<User>) -> Void in
                if let avatar = user.avatar, let url = URL(string: avatar) {
                    cell.imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "profile_empty"))
                }
            }
        })
    }

    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc func timerFired(_ timer: Timer) {
        if let dict = (timer.userInfo as? Dictionary<String, AnyObject>),
            let text = dict["text"] as? String,
            let row = dict["row"] as? TokenTableRow<User> {

            Alamofire.SessionManager.default.request("https://api.github.com/search/users?q=\(text)&per_page=5")
                .responseCollection(completionHandler: { (response: DataResponse<[User]>) in
                    switch response.result {
                    case let .success(value):
                        row.cell.filteredTokens = value
                        row.cell.reloadOptions()
                    case let .failure(error):
                        print(error)
                    }
                })
        }
    }


}

