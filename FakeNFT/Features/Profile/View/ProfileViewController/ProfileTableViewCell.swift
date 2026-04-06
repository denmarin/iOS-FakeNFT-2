import UIKit

final class ProfileTableViewCell: UITableViewCell, ReuseIdentifying{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        textLabel?.font = .bodyBold
        textLabel?.textColor = .ypBlack
        selectionStyle = .none
        
        let chevronImage = UIImage(systemName: "chevron.right")
        let chevronImageView = UIImageView(image: chevronImage)
        
        chevronImageView.tintColor = .ypBlack
        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.preferredSymbolConfiguration = configuration
        
        accessoryView = chevronImageView
    }
    
    func configure(text: String, nftCount: Int){
        textLabel?.text = "\(text) (\(nftCount))"
    }
}
