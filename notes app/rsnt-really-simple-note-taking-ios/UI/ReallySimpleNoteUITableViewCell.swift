//
//  ReallySimpleNoteListCellView.swift
//  notes-app
//
//  Created by zyan on 2025. 04. 21..



import UIKit

class ReallySimpleNoteUITableViewCell : UITableViewCell {
    private(set) var noteTitle : String = ""
    private(set) var noteText  : String = ""
    private(set) var noteDate  : String = ""
 
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteTextLabel: UILabel!
    @IBOutlet weak var noteDateLabel: UILabel!
}
