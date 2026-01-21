//
//  jargonDefinationViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class jargonDefinationViewController: UIViewController {
    var jargonWord: String!
    var selectedJargon: String?
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var pageNumberLabel: UILabel!
    private var currentIndex = 0
    private var pages: [JargonPage] = []
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var glassView: UIView!
    @IBOutlet weak var jargonDefination: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        view.backgroundColor = AppTheme.shared.dominantColor.withAlphaComponent(0.1)
        jargonWord = selectedWord.word
        title = selectedWord.word
        
        setupGlassEffect()
        pages = allPages.filter { $0.jargonWord == jargonWord }

            guard !pages.isEmpty else {
                print("❌ No pages found for:", jargonWord ?? "")
                return
            }

                currentIndex = 0
                applyPage(index: currentIndex)

    }
    
    private func setupGlassEffect() {

     
        glassView.subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }

       
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)

        blurView.frame = glassView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]


        blurView.isUserInteractionEnabled = false

    
        glassView.insertSubview(blurView, at: 0)

 
        glassView.layer.cornerRadius = 22
        glassView.layer.masksToBounds = true
        glassView.layer.borderWidth = 1
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
    }
    private func applyPage(index: Int) {
        guard index >= 0 && index < pages.count else {
            print("Index out of range:", index)
            return
        }

        headingLabel.text = pages[index].title
        jargonDefination.text = pages[index].content
        pageNumberLabel.text = ("\(currentIndex+1)/2")
        actionButton.isHidden = index != pages.count - 1

    }
    
    @IBAction func forwardTapped(_ sender: UIButton) {
        guard currentIndex < pages.count - 1 else { return }
        animateChange(direction: 1)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        guard currentIndex > 0 else { return }
        animateChange(direction: -1)
        
    }
    
    @IBAction func quitTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Quit Lesson",
            message: "Do you re",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.dismiss(animated: true)
        })

        present(alert, animated: true)
        
    }
    
    private func animateChange(direction: CGFloat) {
        let card = glassView!
        let width = card.frame.width

        UIView.animate(withDuration: 0.25, animations: {
            card.transform = CGAffineTransform(translationX: -direction * width, y: 0)
            card.alpha = 0
        }) { _ in
            self.currentIndex += Int(direction)
            self.applyPage(index: self.currentIndex)

            card.transform = CGAffineTransform(translationX: direction * width, y: 0)

            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.6,
                options: [.curveEaseOut],
                animations: {
                    card.transform = .identity
                    card.alpha = 1
                }
            )
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuiz",
           let vc = segue.destination as? jargonQuizViewController {

            vc.jargonWord = jargonWord
        }
    }
}

