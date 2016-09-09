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

    func setupForToken(token: T)
}

/// Cell that is used in a TokenTableRow. shows a UITableView with options. Generic parameters are: Value of Row and Type of the Cell to be shown in the UITableView that shows the options
public class TableTokenCell<T: TokenSearchable, TableViewCell: UITableViewCell where TableViewCell: EurekaTokenTableViewCell, TableViewCell.T == T>: TokenCell<T>, UITableViewDelegate, UITableViewDataSource {

    /// callback that can be used to cuustomize the appearance of the UICollectionViewCell in the inputAccessoryView
    public var customizeTableViewCell: ((T, TableViewCell) -> Void)?

    /// UICollectionView that acts as inputAccessoryView.
    public var tableView: UITableView?

    /// Maximum number of options to be shown as candidates
    public var numberOfOptions: Int = 5

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func setup() {
        super.setup()
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView?.autoresizingMask = .FlexibleHeight
        tableView?.hidden = true
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.whiteColor()
        tableView?.registerClass(TableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    public override func showOptions() {
        if let controller = formViewController() {
            if tableView?.superview == nil {
                controller.view.addSubview(tableView!)
            }
            let frame = controller.tableView?.convertRect(self.frame, toView: controller.view) ?? self.frame
            tableView?.frame = CGRectMake(0, frame.origin.y + frame.height, contentView.frame.width, 44 * CGFloat(numberOfOptions))
            tableView?.hidden = false
        }
    }

    override public func hideOptions() {
        tableView?.hidden = true
    }

    override public func reloadOptions() {
        tableView?.reloadData()
    }

    public func tokenInputView(aView: CLTokenInputView, didChangeText text: String?) {
        if let text = text where !text.isEmpty {
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
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTokens.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! TableViewCell
        if filteredTokens.count > indexPath.row {
            let token = filteredTokens[indexPath.row]
            cell.setupForToken(token)
            customizeTableViewCell?(token, cell)
        }
        return cell
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if filteredTokens.count > indexPath.row {
            let token = filteredTokens[indexPath.row]
            (row as! _TokenRow<T, TableTokenCell>).addToken(token)
            cellResignFirstResponder()
        }
    }

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}