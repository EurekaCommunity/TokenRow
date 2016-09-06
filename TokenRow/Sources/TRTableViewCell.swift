//
//  TRTableViewCell.swift
//  TokenRow
//
//  Created by Mathias Claassen on 9/6/16.
//
//

import Foundation
import Eureka

/// Default cell for the table of the TokenTableCell
public class TRTableViewCell<Token: TokenSearchable>: UITableViewCell, EurekaTokenTableViewCell {
    public typealias T = Token
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        textLabel?.font = UIFont.systemFontOfSize(16)
        textLabel?.minimumScaleFactor = 0.8
        textLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.textColor = UIColor.blueColor()
        contentView.backgroundColor = UIColor.whiteColor()
    }
    
    public func setupForToken(token: T) {
        textLabel?.text = token.displayString
    }
}
