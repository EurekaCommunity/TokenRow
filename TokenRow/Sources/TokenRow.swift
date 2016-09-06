//
//  TokenRow.swift
//  TokenRow
//
//  Created by Mathias Claassen on 9/6/16.
//

import Foundation
import Eureka
import CLTokenInputView


/**
 *  Values of a TokenRow have to conform to this protocol
 */
public protocol TokenSearchable: Hashable {
    var displayString: String { get }
    func contains(token: String) -> Bool
    var identifier: NSObject { get }
}

/// Generic TokenRow. Concrete classes should subclass this one and specify generic parameters
public class _TokenRow<T: TokenSearchable, Cell: BaseCell where Cell: CellType, Cell: TokenCellProtocol, Cell: TypedCellType, Cell.Value == Set<T>> : Row<Set<T>, Cell> {
    public var options: [T] = []
    public var placeholder: String?

    required public init(tag: String?) {
        super.init(tag: tag)
        value = Set()
        displayValueFor = nil
    }
    
    /// Get tokens that match a given search text. Useful when you want to get those tokens asynchronously
    public lazy var getTokensForString: (String) -> [T]? = { [weak self] searchString in
        guard let me = self else { return nil }

        // return options that have not been chosen and that contain the searchString
        return me.options.filter {
                return me.value == nil || !me.value!.contains($0)
            }.filter { $0.contains(searchString) }
    }

    /// remove a token by its identifier
    public func removeToken(tokenIdentifier: NSObject) {
        if let token = value?.filter({ $0.identifier == tokenIdentifier }).first {
            removeToken(token)
        }
    }

    /// remove a token from the list of chosen tokens
    public func removeToken(token: T) {
        value?.remove(token)
        if let cltoken = cell.tokenView.allTokens.filter({ $0.context == token.identifier }).first {
            cell.tokenView.removeToken(cltoken)
        }
    }

    /// add a token to the list of chosen tokens by identifier
    public func addToken(tokenIdentifier: NSObject) {
        if let token = options.filter({$0.identifier == tokenIdentifier}).first {
            addToken(token)
        }
    }

    /// add a token from the list of chosen tokens
    public func addToken(token: T) {
        value?.insert(token)
        cell.tokenView.addToken(CLToken(displayText: token.displayString, context: token.identifier))
    }
}

/// TokenRow that shows its options in the inputAccessoryView
public final class TokenAccessoryRow<T: TokenSearchable>: _TokenRow<T, CollectionTokenCell<T, TRCollectionViewCell<T>>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// TokenRow that shows its options in a table below the cell
public final class TokenTableRow<T: TokenSearchable>: _TokenRow<T, TableTokenCell<T, TRTableViewCell<T>>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


/**
 *  Protocol to access _TokenRow from TokenCell
 */
protocol TokenRowProtocol {
    var placeholder: String? { get }
    func addToken(tokenIdentifier: NSObject)
    func removeToken(tokenIdentifier: NSObject)
}

extension _TokenRow: TokenRowProtocol {}
