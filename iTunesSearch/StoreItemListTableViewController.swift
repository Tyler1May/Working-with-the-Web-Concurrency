
import UIKit

@MainActor
class StoreItemListTableViewController: UITableViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var filterSegmentedControl: UISegmentedControl!
    
    // add item controller property
    
    var items = [StoreItem]()
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchMatchingItems() {
        
        self.items = []
        self.tableView.reloadData()
        
        let searchTerm = searchBar.text ?? ""
        let mediaType = queryOptions[filterSegmentedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            
            // set up query dictionary
            let queryItems = [
                "term": "\(searchTerm)",
                "media": "\(mediaType)",
                "limit": "10"
            ].map { URLQueryItem(name: $0.key, value: $0.value) }
            
            // use the item controller to fetch items
            Task {
                do {
                    let storeItems = try await ItemController.shared.fetchItems(matching: queryItems)
                    DispatchQueue.main.async {
                        self.items = storeItems
                        self.tableView.reloadData()
                    }
                } catch {
                    print("line 46: \(error.localizedDescription)")
                }
            }
            // if successful, use the main queue to set self.items and reload the table view
            // otherwise, print an error to the console
        }
    }
    
    func configure(cell: ItemCell, forItemAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        // set cell.name to the item's name
        cell.name = item.name
        // set cell.artist to the item's artist
        cell.artist = item.artist
        // set cell.artworkImage to nil
        cell.artworkImage = nil
        // initialize a network task to fetch the item's artwork keeping track of the task
        // in imageLoadTasks so they can be cancelled if the cell will not be shown after
        // the task completes.
        //
        // if successful, set the cell.artworkImage using the returned image
        
        if let url = URL(string: item.artworkURL) {
            imageLoadTasks[indexPath] = Task {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                        return
                    }
                    cell.artworkImage = UIImage(data: data)
                } catch {
                    print("failed to load image: \(error.localizedDescription)")
                }
                imageLoadTasks[indexPath] = nil
            }
        }
    }
    
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemCell
        configure(cell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // cancel the image fetching task if we no longer need it
        imageLoadTasks[indexPath]?.cancel()
    }
}

extension StoreItemListTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchMatchingItems()
        searchBar.resignFirstResponder()
    }
}

