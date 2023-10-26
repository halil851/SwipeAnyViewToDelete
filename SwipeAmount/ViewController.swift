


import UIKit

class ViewController: UIViewController {

    var swipeView = DenemeView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(swipeView)
        
        let label = UILabel()
        label.text = "Ben de en sağdayım"

        swipeView.scrollableRow.addSubview(label)
        swipeView.backgroundColor = .systemBrown
        
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        swipeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        swipeView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        swipeView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9).isActive = true
        swipeView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.trailingAnchor.constraint(equalTo: swipeView.scrollableRow.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: swipeView.scrollableRow.bottomAnchor).isActive = true

    }
    
}

