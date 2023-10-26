
// ViewController olarak hazır. YEDEK
import UIKit

class ViewController2: UIViewController {

    @IBOutlet weak var row: UIView!
    var rowTempCenter = CGPoint()
    var rowOriginalCenter = CGPoint()

    let redView = UIView()
    var redViewTempCenter = CGPoint()
    var redViewOriginalCenter = CGPoint()

    let deleteButton = UIButton()
    var deleteBtnOrgX = CGFloat()

    var minX = CGFloat()

    enum Direction {
        case left
        case right
    }

    var direction: Direction = .right
    var isStopedAtSecondLevel = false
    var didResetPositions = true

    override func viewDidLoad() {
        super.viewDidLoad()
        redView.addSubview(deleteButton)
        deleteButton.setTitle("Sil", for: .normal)
        deleteButton.titleLabel?.textAlignment = .left
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: redView.topAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: redView.bottomAnchor).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: redView.leadingAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: view.frame.width * 0.2).isActive = true

        view.addSubview(redView)

        redView.translatesAutoresizingMaskIntoConstraints = false

        redView.topAnchor.constraint(equalTo: row.topAnchor).isActive = true
        redView.bottomAnchor.constraint(equalTo: row.bottomAnchor).isActive = true
        redView.leadingAnchor.constraint(equalTo: row.trailingAnchor).isActive = true

        redView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true

        redView.backgroundColor = .systemRed

        // Do any additional setup after loading the view.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        row.addGestureRecognizer(panGestureRecognizer)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resetPosition))
        row.addGestureRecognizer(tapGesture)
        row.isUserInteractionEnabled = true

        let panGestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        redView.addGestureRecognizer(panGestureRecognizer2)


        let label = UILabel()
        label.text = "En sağdayım"

        row.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: row.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: row.trailingAnchor).isActive = true

    }

    override func viewDidAppear(_ animated: Bool) {
        redViewTempCenter = redView.center
        rowTempCenter = row.center
        deleteBtnOrgX = deleteButton.frame.origin.x
        redViewOriginalCenter = redViewTempCenter
        rowOriginalCenter = rowTempCenter
    }

    @objc func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let firstLevel = view.frame.width * 0.9
        let secondLevel = view.frame.width * 0.8
        let thirdLevel = view.frame.width * 0.3
        var xOffset = translation.x
        //Set direction
        direction = xOffset.isLess(than: 0) ? .left : .right

        switch sender.state {
        case .began: //When Swiping start
            minX = abs(row.frame.minX)

            if redView.frame.origin.x == secondLevel {
                isStopedAtSecondLevel = true
                didResetPositions = false
            }

        case .changed: //Swiping

            if xOffset > minX {
                xOffset = minX
            }

            redView.center.x = redViewTempCenter.x + xOffset
            row.center.x = rowTempCenter.x + xOffset

            if redView.frame.minX < thirdLevel {
                //Delete button goes to left
                UIView.animate(withDuration: 0.3) {[self] in
                    deleteButton.frame.origin.x = 0
                }

            } else if abs(xOffset) > view.frame.width - secondLevel, isStopedAtSecondLevel == false {
                //Delete Button appears and stay right
                deleteButton.frame.origin.x = abs(xOffset) - (row.frame.width - secondLevel)

            } else if isStopedAtSecondLevel, direction == .left {
                // If already swipe left to a bit and delete button is still
                deleteButton.frame.origin.x = abs(xOffset)
                row.frame.origin.x = redView.frame.minX - row.frame.width
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
                        row.frame.origin.x = secondLevel - row.frame.width
                    })

                } else if redView.frame.minX < thirdLevel {
                    //Swipe very left to delete
                    deleteAction()
                    resetPosition()

                } else {
                    //When swipe between thirdLevel and secondLevel, animate to secondLevel
                    UIView.animate(withDuration: 0.3, animations: { [self] in
                        redView.frame.origin.x = secondLevel
                        row.frame.origin.x = secondLevel - row.frame.width
                        deleteButton.frame.origin.x = 0
                        isStopedAtSecondLevel = true

                    })
                }
            case .right:
                resetPosition()
            }
            redViewTempCenter = redView.center
            rowTempCenter = row.center

        default:  break
        }
    }


    @objc func resetPosition() {

        UIView.animate(withDuration: 0.3, animations: { [self] in
            row.center = rowOriginalCenter
            redView.center = redViewOriginalCenter
            redView.frame.origin.x = row.frame.maxX
            redViewTempCenter = redViewOriginalCenter
            deleteButton.frame.origin.x = deleteBtnOrgX
            rowTempCenter = row.center

        }) { [self] _ in
            didResetPositions = true
            isStopedAtSecondLevel = false
        }

    }

    @objc func deleteAction() {
        print("DELETE")
    }
}

