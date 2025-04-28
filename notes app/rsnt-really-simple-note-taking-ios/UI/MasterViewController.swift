import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    let notesCountLabel = UILabel() // Label to display the note count

    override func viewDidLoad() {
        super.viewDidLoad()

        // Core data initialization (existing code)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            // ... (existing alert code) ...
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        ReallySimpleNoteStorage.storage.setManagedContext(managedObjectContext: managedContext)

        // Setup navigation item
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton

        // Setup the title view with the note count label
        notesCountLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        updateNotesCount() // Initial update of the count
        navigationItem.titleView = notesCountLabel

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateNotesCount() // Update the count when the view appears
    }

    @objc
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "showCreateNoteSegue", sender: self)
    }

    // MARK: - Segues (existing code)

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // ... (existing prepare for segue code) ...
    }

    // MARK: - Table View (existing code)

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReallySimpleNoteStorage.storage.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ReallySimpleNoteUITableViewCell
        if let object = ReallySimpleNoteStorage.storage.readNote(at: indexPath.row) {
            cell.noteTitleLabel!.text = object.noteTitle
            cell.noteTextLabel!.text = object.noteText
            cell.noteDateLabel!.text = ReallySimpleNoteDateHelper.convertDate(date: Date.init(seconds: object.noteTimeStamp))
            // cell.noteImageView?.image = UIImage(data: object.image ?? Data()) // If you have image thumbnails
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ReallySimpleNoteStorage.storage.removeNote(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateNotesCount() // Update count after deletion
        }
    }

    // MARK: - Helper Methods

    func updateNotesCount() {
        let count = ReallySimpleNoteStorage.storage.count()
        notesCountLabel.text = "\(count) Notes"
        notesCountLabel.sizeToFit() // Adjust label size to fit the text
    }
}
