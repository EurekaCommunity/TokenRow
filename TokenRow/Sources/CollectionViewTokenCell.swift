//
//  CollectionViewTokenCell.swift
//  TokenRow
//
//  Created by Mathias Claassen on 9/6/16.
//
//

import Foundation
import CLTokenInputView

/**
 *  Protocol that the UICollectionViewCells that show options in a TokenRow have to conform to
 */
public protocol EurekaTokenCollectionViewCell {
    associatedtype T: TokenSearchable

    func setupForToken(token: T)
    func sizeThatFits() -> CGSize
}

/**
    Cell that is used in a TokenTableRow. shows a UITableView with options. Generic parameters are: Value of Row and Type of the Cell to be shown in the UITableView that shows the options
 */
public class CollectionTokenCell<T: TokenSearchable, CollectionViewCell: UICollectionViewCell where CollectionViewCell: EurekaTokenCollectionViewCell, CollectionViewCell.T == T>: TokenCell<T>, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// callback that can be used to cuustomize the appearance of the UICollectionViewCell in the inputAccessoryView
    public var customizeCollectionViewCell: ((T, CollectionViewCell) -> Void)?

    /// UICollectionView that acts as inputAccessoryView.
    public lazy var collectionView: UICollectionView? = {
        let collectionView = UICollectionView(frame: CGRectMake(0, 0, self.contentView.frame.width, 50), collectionViewLayout: self.collectionViewLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: self.cellReuseIdentifier)
        return collectionView
    }()

    public var collectionViewLayout: UICollectionViewLayout = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        return layout
    }()

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override var inputAccessoryView: UIView? {
        return self.collectionView
    }

    override public func reloadOptions() {
        collectionView?.reloadData()
    }

    public func tokenInputView(aView: CLTokenInputView, didChangeText text: String?) {
        if let text = text where !text.isEmpty {
            if let newTokens = (row as! _TokenRow<T, CollectionTokenCell<T, CollectionViewCell>>).getTokensForString(text) {
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

    //MARK: UICollectionViewDelegate and Datasource
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTokens.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        if filteredTokens.count > indexPath.row {
            let token = filteredTokens[indexPath.row]
            cell.setupForToken(token)
            customizeCollectionViewCell?(token, cell)
        }
        return cell
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if filteredTokens.count > indexPath.row {
            let token = filteredTokens[indexPath.row]
            (row as! _TokenRow<T, CollectionTokenCell>).addToken(token)
            cellResignFirstResponder()
        }
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cell = CollectionViewCell(frame: CGRectZero)
        if filteredTokens.count > indexPath.row {
            let token = filteredTokens[indexPath.row]
            cell.setupForToken(token)
        }
        return cell.sizeThatFits()
    }

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
}