//
//  EditableRowDiffableDataSource.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/14/20.
//

import UIKit

final class EditableRowDiffableDataSource<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable>: UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType> {

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
