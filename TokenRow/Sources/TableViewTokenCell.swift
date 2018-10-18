//
//  TableViewTokenCell.swift
//  TokenRow
//
//  Created by Mathias Claassen on 9/6/16.
//
//

import Foundation
import UIKit
import CLTokenInputView

/**
 *  Protocol that the UITableViewCells that show options in a TokenRow have to conform to
 */
public protocol EurekaTokenTableViewCell {
    associatedtype T: TokenSearchable

    func setupForToken(_ token: T)
}

/// Cell that is used in a TokenTableRow. shows a UITableView with options. Generic parameters are: Value of Row and Type of the Cell to be shown in the UITableView that shows the options
open class TableTokenCell<T, TableViewCell: UITableViewCell>: TokenCell<T>, UITableViewDelegate, UITableViewDataSource where TableViewCell: EurekaTokenTableViewCell, TableViewCell.T == T {

    /// callback that can be used to cuustomize the appearance of the UICollectionViewCell in the inputAccessoryView
    public var customizeTableViewCell: ((T, TableViewCell) -> Void)?

    /// UICollectionView that acts as inputAccessoryView.
    public var tableView: UITableView?

    /// Maximum number of options to be shown as candidates
    public var numberOfOptions: Int = 5

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func setup() {
        super.setup()
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView?.autoresizingMask = .flexibleHeight
        tableView?.isHidden = true
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.white
        tableView?.register(TableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    open override func showOptions() {
        if let controller = formViewController() {
            if tableView?.superview == nil {
                controller.view.addSubview(tableView!)
            }
            let frame = controller.tableView?.convert(self.frame, to: controller.view) ?? self.frame
            tableView?.frame = CGRect(x: 0, y: frame.origin.y + frame.height, width: contentView.frame.width, height: 44 * CGFloat(numberOfOptions))
            tableView?.isHidden = false
        }
    }

    override open func hideOptions() {
        tableView?.isHidden = true
    }

    override open func reloadOptions() {
        tableView?.reloadData()
    }

    @objc open func tokenInputView(_ aView: CLTokenInputView, didChangeText text: String?) {
        if let text = text , !text.isEmpty {
            if let newTokens = (row as! _TokenRow<T, TableTokenCell<T, TableViewCell>>).getTokensForString(text) {
                filteredTokens = newTokens
            }
            showOptions()
        }
        else {
            filteredTokens = []
            hideOptions()
        }
        reloadOptions()
    }

    //MARK: UITableViewDelegate and Datasource
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTokens.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TableViewCell
        if filteredTokens.count > (indexPath as NSIndexPath).row {
            let token = filteredTokens[(indexPath as NSIndexPath).row]
            cell.setupForToken(token)
            customizeTableViewCell?(token, cell)
        }
        return cell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filteredTokens.count > (indexPath as NSIndexPath).row {
            let token = filteredTokens[(indexPath as NSIndexPath).row]
            (row as! _TokenRow<T, TableTokenCell>).addToken(token)
            _ = cellResignFirstResponder()
        }
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
