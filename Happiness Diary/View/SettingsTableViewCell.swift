import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    var model: SettingsTableViewModel? {
        didSet {
            mainView.text = model?.mainText
            subView.text = model?.subText
        }
    }
    
    let mainView: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    let subView: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 0, green: 0, blue: 0, alpha: 0.8)
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        return label
    }()

    private func setupViews() {
        addSubview(mainView)
        addSubview(subView)

        addConstraintsWithFormat(format: "H:|-16-[v0]-64-|", views: mainView)
        addConstraintsWithFormat(format: "H:|-16-[v0]-64-|", views: subView)
        addConstraintsWithFormat(format: "V:|-[v0(21)]-[v1]-|", views: mainView, subView)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
