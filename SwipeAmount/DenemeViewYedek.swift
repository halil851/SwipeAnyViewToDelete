//
//  DenemeView.swift
//  SwipeAmount
//
//  Created by halil dikişli on 25.10.2023.
//

import UIKit

class DenemeViewYedek: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private let redView = UIView()
    private var redViewTempCenter = CGPoint()
    private var redViewOriginalCenter = CGPoint()
    
    
    let scrollableRow = UIView()
    private var rowTempCenter = CGPoint()
    private var rowOriginalCenter = CGPoint()
    
    
    private let deleteButton = UIButton()
    private var deleteBtnOrgX = CGFloat()
    
    private var minX = CGFloat()
    
    enum Direction {
        case left
        case right
    }
    
    private var direction: Direction = .right
    private var isStopedAtSecondLevel = false
    private var didResetPositions = true
    
    
    override func layoutSubviews() {
        viewDidLoad()
    }
    override func draw(_ rect: CGRect) {
        setFirstLocations()
    }
    
    private func viewDidLoad() {
        
        redView.backgroundColor = .systemRed
        scrollableRow.backgroundColor = self.backgroundColor
        self.backgroundColor = .clear
        
        self.addSubview(scrollableRow)
        self.addSubview(redView)
        redView.addSubview(deleteButton)
                
        recognizerSetups()
        
        anchorSetups()
    }
    
    private func recognizerSetups() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resetPosition))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        
        let panGestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        redView.addGestureRecognizer(panGestureRecognizer2)
    }
    
    private func anchorSetups() {
        scrollableRow.translatesAutoresizingMaskIntoConstraints = false
        scrollableRow.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollableRow.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollableRow.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollableRow.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        redView.translatesAutoresizingMaskIntoConstraints = false
        redView.topAnchor.constraint(equalTo: scrollableRow.topAnchor).isActive = true
        redView.bottomAnchor.constraint(equalTo: scrollableRow.bottomAnchor).isActive = true
        redView.leadingAnchor.constraint(equalTo: scrollableRow.trailingAnchor).isActive = true
        redView.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        
        deleteButton.setTitle("Sil", for: .normal)
        deleteButton.titleLabel?.textAlignment = .left
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: redView.topAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: redView.bottomAnchor).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: redView.leadingAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: self.frame.width * 0.2).isActive = true
    }
    
    
    private func setFirstLocations() {
        redViewTempCenter = redView.center
        rowTempCenter = scrollableRow.center
        deleteBtnOrgX = deleteButton.frame.origin.x
        redViewOriginalCenter = redViewTempCenter
        rowOriginalCenter = rowTempCenter
        
        redView.isHidden = true
    }
    
    
    @objc private func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let firstLevel = scrollableRow.frame.width * 0.9
        let secondLevel = scrollableRow.frame.width * 0.8
        let thirdLevel = scrollableRow.frame.width * 0.3
        var xOffset = translation.x
        redView.isHidden = false
        //Set direction
        direction = xOffset.isLess(than: 0) ? .left : .right
        
        switch sender.state {
        case .began: //When Swiping start
            minX = abs(scrollableRow.frame.minX)
            
            if redView.frame.origin.x == secondLevel {
                isStopedAtSecondLevel = true
                didResetPositions = false
            }
            
        case .changed: //Swiping
            
            if xOffset > minX {
                xOffset = minX
            }
            
            redView.center.x = redViewTempCenter.x + xOffset
            scrollableRow.center.x = rowTempCenter.x + xOffset
            
            if redView.frame.minX < thirdLevel {
                //Delete button goes to left
                UIView.animate(withDuration: 0.3) {[self] in
                    deleteButton.frame.origin.x = 0
                }
                
            } else if abs(xOffset) > scrollableRow.frame.width - secondLevel, isStopedAtSecondLevel == false {
                //Delete Button appears and stay right
                deleteButton.frame.origin.x = abs(xOffset) - (scrollableRow.frame.width - secondLevel)
                
            } else if isStopedAtSecondLevel, direction == .left {
                // If already swipe left to a bit and delete button is still
                deleteButton.frame.origin.x = abs(xOffset)
                scrollableRow.frame.origin.x = redView.frame.minX - scrollableRow.frame.width
            }
            
        case .ended:
            
            switch direction {
            case .left:
                if redView.frame.minX > firstLevel {
                    //Reset Position when left swipe isn't enough to see delete button
                    resetPosition()
                    
                } else if redView.frame.minX > secondLevel {
                    //Delete button can be seen and stay still at right side
                    didResetPositions = true
                    UIView.animate(withDuration: 0.3, animations: { [self] in
                        redView.frame.origin.x = secondLevel
                        scrollableRow.frame.origin.x = secondLevel - scrollableRow.frame.width
                    })
                    
                } else if redView.frame.minX < thirdLevel {
                    //Swipe very left to delete
                    deleteAction()
                    resetPosition()
                    
                } else {
                    //When swipe between thirdLevel and secondLevel, animate to secondLevel
                    UIView.animate(withDuration: 0.3, animations: { [self] in
                        redView.frame.origin.x = secondLevel
                        scrollableRow.frame.origin.x = secondLevel - scrollableRow.frame.width
                        deleteButton.frame.origin.x = 0
                        isStopedAtSecondLevel = true
                        
                    })
                }
            case .right:
                resetPosition()
            }
            redViewTempCenter = redView.center
            rowTempCenter = scrollableRow.center
            
        default:  break
        }
    }
    
    
    @objc private func resetPosition() {
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
            scrollableRow.center = rowOriginalCenter
            redView.center = redViewOriginalCenter
            redView.frame.origin.x = scrollableRow.frame.maxX
            redViewTempCenter = redViewOriginalCenter
            deleteButton.frame.origin.x = deleteBtnOrgX
            rowTempCenter = scrollableRow.center
            
            
        }) { [self] _ in
            didResetPositions = true
            isStopedAtSecondLevel = false
            redView.isHidden = true
        }
        
    }
    
    @objc private func deleteAction() {
        print("DELETE")
    }
    
}

