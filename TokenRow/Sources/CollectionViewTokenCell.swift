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

    func setupForToken(_ token: T)
    func sizeThatFits() -> CGSize
}

/**
    Cell that is used in a TokenTableRow. shows a UITableView with options. Generic parameters are: Value of Row and Type of the Cell to be shown in the UITableView that shows the options
 */
open class CollectionTokenCell<T: TokenSearchable, CollectionViewCell: UICollectionViewCell>: TokenCell<T>, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout where CollectionViewCell: EurekaTokenCollectionViewCell, CollectionViewCell.T == T {

    /// callback that can be used to cuustomize the appearance of the UICollectionViewCell in the inputAccessoryView
    public var customizeCollectionViewCell: ((T, CollectionViewCell) -> Void)?

    /// UICollectionView that acts as inputAccessoryView.
    public lazy var collectionView: UICollectionView? = {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: 50), collectionViewLayout: self.collectionViewLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: self.cellReuseIdentifier)
        return collectionView
    }()

    public var collectionViewLayout: UICollectionViewLayout = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        return layout
    }()

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var inputAccessoryView: UIView? {
        return self.collectionView
    }

    override open func reloadOptions() {
        collectionView?.reloadData()
    }

    open func tokenInputView(_ aView: CLTokenInputView, didChangeText text: String?) {
        if let text = text , !text.isEmpty {
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
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTokens.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CollectionViewCell
        if filteredTokens.count > (indexPath as NSIndexPath).row {
            let token = filteredTokens[(indexPath as NSIndexPath).row]
            cell.setupForToken(token)
            customizeCollectionViewCell?(token, cell)
        }
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if filteredTokens.count > (indexPath as NSIndexPath).row {
            let token = filteredTokens[(indexPath as NSIndexPath).row]
            (row as! _TokenRow<T, CollectionTokenCell>).addToken(token)
            cellResignFirstResponder()
        }
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = CollectionViewCell(frame: CGRect.zero)
        if filteredTokens.count > (indexPath as NSIndexPath).row {
            let token = filteredTokens[(indexPath as NSIndexPath).row]
            cell.setupForToken(token)
        }
        return cell.sizeThatFits()
    }

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
