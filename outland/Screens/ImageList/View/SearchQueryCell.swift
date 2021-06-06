//
//  SearchQueryCell.swift
//  outland
//
//  Created by Manuel on 06/06/21.
//

import UIKit

class SearchQueryCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!

    func setSearchQuery(_ searchQuery: String) {
        label.text = searchQuery
    }
}
