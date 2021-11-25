import UIKit
import Then

class CustomTabBar: UIView {
    var itemTapped: ((_ tab: Int) -> Void)?
    var activeItem: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(menuItems: [TabItem], frame: CGRect) {
        self.init(frame: frame)
        addCustomLayer()
        // Khởi tạo tab bar item
        for index in 0 ..< menuItems.count {
            let itemWidth = frame.width / CGFloat(menuItems.count)
            let offsetX = itemWidth * CGFloat(index)
            
            var itemView = UIView()
            if menuItems[index] != .add {
                itemView = createTabItem(item: menuItems[index])
            } else {
                itemView = createAddTab(item: menuItems[index])
            }
            
            itemView.do {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.clipsToBounds = true
                $0.tag = index
                addSubview($0)
            }

            if menuItems[index] != .add {
                NSLayoutConstraint.activate([
                    itemView.topAnchor.constraint(equalTo: topAnchor, constant: 32)])
            } else {
                NSLayoutConstraint.activate([
                    itemView.topAnchor.constraint(equalTo: topAnchor)])
            }
            
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalTo: heightAnchor),
                itemView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
                itemView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offsetX)
            ])
        }
        activateTab(0) //Set mặc định ở vị trí 0
        setNeedsLayout()
        layoutIfNeeded()
    }
//MARK: - Tabbar Item
    private func createTabItem(item: TabItem) -> UIView {
        let tabBarItem = UIView().then {
            $0.tintColor = .systemGray
        }
        
        let itemImageView = UIImageView().then {
            $0.image = item.image
            $0.contentMode = .scaleAspectFit
        }
        
        [tabBarItem, itemImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
        }
        
        tabBarItem.addSubview(itemImageView)
        
        // Auto layout cho item title và item icon
        NSLayoutConstraint.activate([
            itemImageView.heightAnchor.constraint(equalToConstant: 30),
            itemImageView.widthAnchor.constraint(equalTo: itemImageView.heightAnchor, multiplier: 1),
            itemImageView.centerXAnchor.constraint(equalTo: tabBarItem.centerXAnchor),
            itemImageView.topAnchor.constraint(equalTo: tabBarItem.topAnchor, constant: 12),
        ])
        
        // Handle tap event
        tabBarItem.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(handleTap(_:))))
        return tabBarItem
    }
//MARK: - Custom Add Item
    private func createAddTab(item: TabItem) -> UIView {
        let addItem = UIView()
        
        let innerCircle = UIView().then {
            $0.layer.cornerRadius = 27
            $0.backgroundColor = AppConstraints.Color.yellow
        }
        
        let outerCircle = UIView().then {
            $0.layer.cornerRadius = 34
            $0.backgroundColor = AppConstraints.Color.outerCircleAddItem
        }
        
        let itemImageView = UIImageView().then {
            $0.image = item.image
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .white
            
        }
        
        [addItem, innerCircle, outerCircle, itemImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
        }
        
        addItem.do {
            $0.addSubview(outerCircle)
            $0.addSubview(innerCircle)
            $0.addSubview(itemImageView)
        }
        
        NSLayoutConstraint.activate([
            itemImageView.heightAnchor.constraint(equalToConstant: 30),
            itemImageView.widthAnchor.constraint(equalTo: itemImageView.heightAnchor, multiplier: 1),
            itemImageView.centerXAnchor.constraint(equalTo: addItem.centerXAnchor),
            itemImageView.topAnchor.constraint(equalTo: addItem.topAnchor, constant: 28),
            innerCircle.heightAnchor.constraint(equalToConstant: 54),
            innerCircle.widthAnchor.constraint(equalTo: innerCircle.heightAnchor, multiplier: 1),
            innerCircle.centerXAnchor.constraint(equalTo: itemImageView.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: itemImageView.centerYAnchor),
            outerCircle.heightAnchor.constraint(equalToConstant: 68),
            outerCircle.widthAnchor.constraint(equalTo: outerCircle.heightAnchor, multiplier: 1),
            outerCircle.centerXAnchor.constraint(equalTo: innerCircle.centerXAnchor),
            outerCircle.centerYAnchor.constraint(equalTo: innerCircle.centerYAnchor)
        ])
        
        addItem.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                            action: #selector(handleTap(_:))))
        return addItem
    }
//MARK: - Tabbar Tap
    @objc private func handleTap(_ sender: UIGestureRecognizer) {
        if let indexItem = sender.view?.tag {
            switchTab(beforeTab: activeItem, nextTab: indexItem)
        }
    }
    
    private func switchTab(beforeTab: Int, nextTab: Int) {
        deactivateTab(beforeTab)
        activateTab(nextTab)
    }
    
    private func activateTab(_ tab: Int) {
        let activeTab = subviews[tab]
        activeTab.tintColor = AppConstraints.Color.yellow
        itemTapped?(tab)
        activeItem = tab
    }
    
    private func deactivateTab(_ tab: Int) {
        let inactiveTab = subviews[tab]
        inactiveTab.tintColor = AppConstraints.Color.tabbarUnselectedTint
    }
    
//MARK: - Add Layer
    private func addCustomLayer() {
        let shapeLayer = CAShapeLayer().then {
            $0.path = createPath()
            $0.strokeColor = UIColor.lightGray.cgColor
            $0.fillColor = AppConstraints.Color.tabbarBackground?.cgColor
            $0.lineWidth = 0.5
            $0.shadowOffset = CGSize(width:0, height:0)
            $0.shadowRadius = 10
            $0.shadowColor = UIColor.lightGray.cgColor
            $0.shadowOpacity = 0.2
        }
        layer.addSublayer(shapeLayer)
    }
    
    private func createPath() -> CGPath {
        let widthPoint: CGFloat = frame.width / 4
        let centerWidth = frame.width / 2
        
        let path = UIBezierPath().then {
            $0.move(to: CGPoint(x: 0, y: 32))
            $0.addLine(to: CGPoint(x: (centerWidth - widthPoint ), y: 32))
            $0.addCurve(to: CGPoint(x: centerWidth, y: 0),
                        controlPoint1: CGPoint(x: centerWidth - 20, y: 30),
                        controlPoint2: CGPoint(x: centerWidth - 32, y: 0))
            $0.addCurve(to: CGPoint(x: (centerWidth + widthPoint ), y: 32),
                        controlPoint1: CGPoint(x: centerWidth + 32, y: 0),
                        controlPoint2: CGPoint(x: (centerWidth + 20), y: 30))
            $0.addLine(to: CGPoint(x: frame.width, y: 32))
            $0.addLine(to: CGPoint(x: frame.width, y: frame.height))
            $0.addLine(to: CGPoint(x: 0, y: frame.height))
            $0.close()
        }
        return path.cgPath
    }
}
