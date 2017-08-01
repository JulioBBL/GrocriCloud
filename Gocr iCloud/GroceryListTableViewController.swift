import UIKit

class GroceryListTableViewController: UITableViewController {
    
    // MARK: Constants
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    var items: [GroceryItem] = []
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    // MARK: UIViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        self.handleRefresh()
        
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        user = User(uid: "FakeId", email: "hungry@person.food")
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser
        
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Icloud.sharedInstance.deleteData(item: items[indexPath.row], completion: { (error) in
                if let _ = error {
                    //TODO: display error message
                } else {
                    self.items.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let toggledCompletion = !items[indexPath.row].completed
        
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        items[indexPath.row].completed = toggledCompletion
        Icloud.sharedInstance.updateData(item: items[indexPath.row]) { (error) in
            print("atualizado")
        }
        tableView.reloadData()
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Grocery Item", message: "Add an Item", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alert.textFields![0]
            let groceryItem = GroceryItem(name: textField.text!, addedByUser: self.user.email, completed: false)
            self.items.append(groceryItem)
            Icloud.sharedInstance.saveData(item: groceryItem, completion: {
                //self.handleRefresh()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didPressRefreshButton(_ sender: Any) {
        self.refreshControl?.beginRefreshing()
        self.handleRefresh()
    }
    
    func handleRefresh() {
        let icloud = Icloud.sharedInstance
        icloud.getData(completion: { (groceries) in
            self.items = groceries
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            })
        })
    }
}
