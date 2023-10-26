


import UIKit

class ViewController: UIViewController {

    let swipeView = SwipeToDeleteView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(swipeView)
        
        swipeView.delegate = self
        swipeView.buttonTitle = "Sil"
        swipeView.backgroundColor = .systemBrown
        
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        swipeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 300).isActive = true
        swipeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        swipeView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        swipeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        let label = UILabel()
        label.text = "Right"
        
        swipeView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.trailingAnchor.constraint(equalTo: swipeView.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: swipeView.bottomAnchor).isActive = true
        
        
        let secondLabel = UILabel()
        secondLabel.text = "ikinci"

        swipeView.addSubview(secondLabel)

        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        secondLabel.leadingAnchor.constraint(equalTo: swipeView.leadingAnchor).isActive = true
        secondLabel.topAnchor.constraint(equalTo: swipeView.topAnchor).isActive = true
        
        
        
       

    }
    
}

extension ViewController: SwipeAction {
    func deleteAction() {
        print("delete at ViewController")
    }
    
    
}

