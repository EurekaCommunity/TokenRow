//
//  TokenCell.swift
//  TokenRow
//
//  Created by Mathias Claassen on 9/6/16.
//
//

import Foundation
import Eureka
import CLTokenInputView

// This protocol exists because of a Swift 2 limitation (cannot add generic type constraint parameters into generic declaration)
public protocol TokenCellProtocol {
    var tokenView: CLTokenInputView { get }
}

open class TokenCell<T: TokenSearchable>: Cell<Set<T>>, CLTokenInputViewDelegate, TokenCellProtocol, CellType {

    /// View that contains the tokens of this row
    lazy public var tokenView: CLTokenInputView = { [weak self] in
        guard let me = self else { return CLTokenInputView() }
        let tokenView = CLTokenInputView(frame: me.frame)
        tokenView.translatesAutoresizingMaskIntoConstraints = false
        tokenView.accessoryView = nil
        tokenView.delegate = me
        return tokenView
    }()

    /// Reuse identifier for collection view or table view that shows the options
    public var cellReuseIdentifier: String = "EurekaTokenCellReuseIdentifier"

    /// The options that matched the search string entered by the user
    public var filteredTokens: [T] = []

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled
    }

    open override var canBecomeFirstResponder: Bool {
        return tokenView.canBecomeFirstResponder
    }

    open override func becomeFirstResponder() -> Bool {
        return tokenView.becomeFirstResponder()
    }

    open override func cellResignFirstResponder() -> Bool {
        hideOptions()
        return tokenView.resignFirstResponder()
    }

    var tokenRow: TokenRowProtocol {
        return row as! TokenRowProtocol
    }

    open override func setup() {
        super.setup()
        contentView.addSubview(tokenView)
        setupConstraints()
        selectionStyle = .none
        tokenView.backgroundColor = .clear
    }

    open override func update() {
        // Not calling super on purpose as we do not want to use textlabel nor detailTextLabel
        tokenView.fieldName = row.title
        tokenView.placeholderText = tokenRow.placeholder
    }

    /**
     Constrinats for this cell should be set up here. Custom constraints should be added here in an override
     */
    open func setupConstraints() {
        let views = ["tokenView": tokenView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tokenView]|", options: .alignAllLastBaseline, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tokenView]|", options: .alignAllLastBaseline, metrics: nil, views: views))
    }

    /// Should show the list of options
    func showOptions() {}

    /// Should hide the list of options
    func hideOptions() {}

    /// Should reload the list of options
    open func reloadOptions() {}

    open func tokenInputView(_ aView:CLTokenInputView, didAdd token:CLToken) {
        tokenRow.addToken(token.context!)
    }

    open func tokenInputView(_ aView:CLTokenInputView, didRemove token:CLToken) {
        tokenRow.removeToken(token.context!)
    }

    open func tokenInputView(_ aView: CLTokenInputView, tokenForText text: String) -> CLToken? {
        if filteredTokens.count > 0 {
            let matchingToken = filteredTokens[0]
            let match = CLToken()
            match.displayText = matchingToken.displayString
            match.context = matchingToken.identifier
            return match
        }
        return nil
    }

    open func tokenInputViewDidBeginEditing(_ view: CLTokenInputView) {
        formViewController()?.beginEditing(of: self)
    }

    open func tokenInputViewDidEndEditing(_ view: CLTokenInputView) {
        formViewController()?.endEditing(of: self)
        hideOptions()
    }

    open func tokenInputView(_ view: CLTokenInputView, didChangeHeightTo height: CGFloat) {
        self.height = { height }
        formViewController()?.tableView?.beginUpdates()
        formViewController()?.tableView?.endUpdates()
    }
}
