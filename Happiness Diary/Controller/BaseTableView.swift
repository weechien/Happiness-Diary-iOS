import UIKit

class BaseTableViewController: UITableViewController {
    
    let cellId = "tableViewCellId"
    let sectionHeight: CGFloat = 36
    lazy var navTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))

    var array = [TableViewWithHeader]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navTitleLabel.textColor = .white
        
        navTitleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = navTitleLabel
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .rgb(red: 1, green: 188, blue: 213, alpha: 0.5)
        textView.font = .boldSystemFont(ofSize: 15)
        textView.textContainerInset = UIEdgeInsetsMake(8, 10, 8, 0)
        textView.text = array[section].header
        return textView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array[section].row.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = array[indexPath.section].row[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
