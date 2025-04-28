//
//  ReallySimpleNoteCreateChangeViewController.swift
//  notes-app
//
//  Created by zyan on 2025. 04. 21..

import UIKit

class ReallySimpleNoteCreateChangeViewController : UIViewController, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDoneButton: UIButton!
    @IBOutlet weak var noteDateLabel: UILabel!

    private let noteCreationTimeStamp : Int64 = Date().toSeconds()
    private(set) var changingReallySimpleNote : ReallySimpleNote?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set text view delegate
        noteTextTextView.delegate = self

        // Set text field delegate
        noteTitleTextField.delegate = self

        // Add tap gesture recognizer to dismiss keyboard on outside tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self // Set the delegate to self
        view.addGestureRecognizer(tapGesture)

        // Check if we are in create mode or in change mode and configure UI
        if let changingReallySimpleNote = self.changingReallySimpleNote {
            noteDateLabel.text = ReallySimpleNoteDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
            noteTextTextView.text = changingReallySimpleNote.noteText
            noteTitleTextField.text = changingReallySimpleNote.noteTitle
            noteDoneButton.isEnabled = true
        } else {
            noteDateLabel.text = ReallySimpleNoteDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
        }

        // Initialize text view UI
        noteTextTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        noteTextTextView.layer.borderWidth = 1.0
        noteTextTextView.layer.cornerRadius = 5

        // For back button in navigation bar, change text
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        // Add "Done" button to the keyboard accessory view for the text view
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButtonTextView = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(textViewDoneClicked))
        toolbar.items = [doneButtonTextView]
        noteTextTextView.inputAccessoryView = toolbar
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func textViewDoneClicked() {
        noteTextTextView.resignFirstResponder()
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Check if the touched view is a UIControl (like a button, text field, or text view)
        if touch.view is UIControl {
            return false // Don't recognize the tap if it's on a UIControl
        }
        return true // Recognize the tap if it's outside a UIControl
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        if self.changingReallySimpleNote != nil {
            noteDoneButton.isEnabled = true
        } else {
            if ( noteTitleTextField.text?.isEmpty ?? true ) || ( textView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }

    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
        if self.changingReallySimpleNote != nil {
            // change mode
            noteDoneButton.isEnabled = true
        } else {
            // create mode
            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }

    @IBAction func doneButtonClicked(_ sender: UIButton, forEvent event: UIEvent) {
        // distinguish change mode and create mode
        if self.changingReallySimpleNote != nil {
            // change mode - change the item
            changeItem()
        } else {
            // create mode - create the item
            addItem()
        }
    }

    func setChangingReallySimpleNote(changingReallySimpleNote : ReallySimpleNote) {
        self.changingReallySimpleNote = changingReallySimpleNote
    }

    private func addItem() -> Void {
        let note = ReallySimpleNote(
            noteTitle:     noteTitleTextField.text!,
            noteText:      noteTextTextView.text,
            noteTimeStamp: noteCreationTimeStamp)

        ReallySimpleNoteStorage.storage.addNote(noteToBeAdded: note)

        performSegue(
            withIdentifier: "backToMasterView",
            sender: self)
    }

    private func changeItem() -> Void {
        // get changed note instance
        if let changingReallySimpleNote = self.changingReallySimpleNote {
            // change the note through note storage
            ReallySimpleNoteStorage.storage.changeNote(
                noteToBeChanged: ReallySimpleNote(
                    noteId:        changingReallySimpleNote.noteId,
                    noteTitle:     noteTitleTextField.text!,
                    noteText:      noteTextTextView.text,
                    noteTimeStamp: noteCreationTimeStamp)
            )
            // navigate back to list of notes
            performSegue(
                withIdentifier: "backToMasterView",
                sender: self)
        } else {
            // create alert
            let alert = UIAlertController(
                title: "Unexpected error",
                message: "Cannot change the note, unexpected error occurred. Try again later.",
                preferredStyle: .alert)

            // add OK action
            alert.addAction(UIAlertAction(title: "OK",
                                            style: .default ) { (_) in self.performSegue(
                                                withIdentifier: "backToMasterView",
                                                sender: self)})
            // show alert
            self.present(alert, animated: true)
        }
    }
}
