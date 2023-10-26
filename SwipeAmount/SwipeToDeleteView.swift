//
//  SwipeToDeleteView.swift
//  SwipeAmount
//
//  Created by halil dikişli on 25.10.2023.
//

import UIKit

protocol SwipeAction: AnyObject {
    func deleteAction()
}
///Add subviews to row
class SwipeToDeleteView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    weak var delegate: SwipeAction?
    
    var buttonTitle: String {
        get { return "Delete" }
        set { deleteButton.setTitle(newValue, for: .normal)  }
    }
        
    let row = UIView()
    private var rowTempX = CGFloat()
    private var rowFirstX = CGFloat()
        
    private let deleteButton = UIButton()
    private var deleteTempX = CGFloat()
    private var deleteFirstX = CGFloat()
    private var deleteAnimatedToLeft = false
    
    private let redView = UIView()
    
    private var lastXOffSet = CGFloat()
    
    private var minXOfScrollableRow = CGFloat()
    
    private var didStopAtSecondLevel = false
    
    private var changeDirection: ChangeDirection = .leftToRight
    private var direction: Direction = .right
    
    
        
    enum Direction {
        case left
        case right
    }
    
    enum ChangeDirection {
        case leftToRight
        case rightToLeft
    }
    
    override func layoutSubviews() {
        viewSetup()
        anchorSetups()
        
    }
    
    override func didMoveToSuperview() {
        deleteButton.setTitle(buttonTitle, for: .normal)
    }
    override func draw(_ rect: CGRect) {
        setFirstLocations()
        
        addExtraSubviewsToRow()
    }
    
    //Change superview of every additional subview to row
    private func addExtraSubviewsToRow() {
        let lastIndex = subviews.count - 1
        for (index, subview) in subviews.enumerated() {
            
            if index != lastIndex , index != lastIndex - 1 {
                row.addSubview(subview)
            }
        }
    }
    
    
    private func viewSetup() {
        
        self.addSubview(redView)
        self.addSubview(row)
        
        row.backgroundColor = self.backgroundColor
        
        redView.addSubview(deleteButton)
        redView.backgroundColor = .systemRed
       
        recognizerSetups()
        
        
        deleteButton.titleLabel?.textAlignment = .left
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        deleteButton.backgroundColor = redView.backgroundColor
        
    }
    
    private func recognizerSetups() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resetPosition))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        
    }
    
    private func anchorSetups() {
        row.translatesAutoresizingMaskIntoConstraints = false
        row.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        row.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        row.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        row.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        redView.translatesAutoresizingMaskIntoConstraints = false
        redView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        redView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        redView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        redView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: redView.topAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: redView.bottomAnchor).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: redView.trailingAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: self.frame.width * 0.2).isActive = true
    }
    
    
    private func setFirstLocations() {
        rowTempX = row.frame.origin.x
        deleteFirstX = deleteButton.frame.origin.x
        rowFirstX = rowTempX
    }
    
    
    @objc private func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        
        let firstLevel = self.frame.width * 0.9
        let secondLevel = self.frame.width * 0.8
        let thirdLevel = self.frame.width * 0.3
        let fullWidth = self.frame.width
        
        let translation = sender.translation(in: self)
        var xOffset = translation.x
        
        //Set direction
        direction = xOffset.isLess(than: 0) ? .left : .right
    
        
        switch sender.state {
        case .began: //When Swiping start
            
            minXOfScrollableRow = abs(row.frame.minX)
            
            if row.frame.maxX == secondLevel {
                didStopAtSecondLevel = true
            }
            
        case .changed: //Swiping
            
            //Avoid swipe right config
            if xOffset > minXOfScrollableRow {
                xOffset = minXOfScrollableRow
            }
            
            //Scrollview swiping
            row.frame.origin.x = xOffset + rowTempX
            
            //Delete button animation to left
            if row.frame.maxX < thirdLevel, deleteAnimatedToLeft == false {
                deleteAnimatedToLeft = true
                UIView.animate(withDuration: 0.3) { [self] in
                    deleteButton.frame.origin.x = row.frame.maxX
                }
                
            //Delete button follow scrollableRow
            } else if row.frame.maxX < thirdLevel {
                deleteButton.frame.origin.x = row.frame.maxX
            }
            
            //Provide delete button left to right animation
            changeDirection = xOffset > lastXOffSet ? .rightToLeft : .leftToRight
            lastXOffSet = xOffset
            //Delete button swipe right with animation
            if changeDirection == .rightToLeft, row.frame.maxX > thirdLevel {
                deleteAnimatedToLeft = false
                UIView.animate(withDuration: 0.3) { [self] in
                    deleteButton.frame.origin.x = deleteFirstX
                }
            }
            
        case .ended:
            
            switch direction {
            case .left:
                
                //If stoped at second level add second level xOffSet
                var additionalXOffSet = 0.0
                if didStopAtSecondLevel {
                    additionalXOffSet = fullWidth - secondLevel
                }
                //Swipe to all Left
                if abs(xOffset) + additionalXOffSet > fullWidth - thirdLevel {
                    deleteAction()
                    
                //Swipe little bit, Cancel swipe
                } else if abs(xOffset) < fullWidth - firstLevel {
                    resetPosition()
                    
                //Delete button is visible with animation
                } else {
                    UIView.animate(withDuration: 0.3) { [self] in
                        row.frame.origin.x = secondLevel - row.frame.width
                        deleteButton.frame.origin.x = deleteFirstX
                    }
                }
                
            case .right:
                resetPosition()
            }
            
            //Save last positions
            rowTempX = row.frame.origin.x
            deleteTempX = deleteButton.frame.origin.x
            
        default:  break
        }
        
    }
    
    
    @objc private func resetPosition() {
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
            row.frame.origin.x = rowFirstX
            rowTempX = rowFirstX
           
            deleteButton.frame.origin.x = deleteFirstX
            deleteTempX = deleteFirstX
            
            changeDirection = .leftToRight
            lastXOffSet = 0
            
            deleteAnimatedToLeft = false
            
            didStopAtSecondLevel = false
        })
    }
    
    @objc private func deleteAction() {
        print("DELETE")
        resetPosition()
        delegate?.deleteAction()
    }
}
