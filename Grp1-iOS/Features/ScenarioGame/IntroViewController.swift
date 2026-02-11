//
//  IntroViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var biasLabel: UILabel!
    
    @IBOutlet weak var biasCardLabel: UILabel!
    @IBOutlet weak var capitalCardLabel: UILabel!
    
    @IBOutlet weak var capitalCard: UIView!
    @IBOutlet weak var biasCard: UIView!
    
    @IBOutlet weak var biasModuleCard: UIView!
    @IBOutlet weak var biasCardImageView: UIImageView!
    @IBOutlet weak var biasCardDescriptionLabel: UILabel!
    @IBOutlet weak var biasCardSubtitle: UILabel!
    
    @IBOutlet weak var marketModuleCard: UIView!
    @IBOutlet weak var marketImageView: UIImageView!
    @IBOutlet weak var marketCardLabel: UILabel!
    @IBOutlet weak var marketCardSubtitle: UILabel!
    
    @IBOutlet weak var timeModuleCard: UIView!
    @IBOutlet weak var timerCardImageView: UIImageView!
    @IBOutlet weak var timerCardLabel: UILabel!
    @IBOutlet weak var timerCardSubtitle: UILabel!
    
    @IBOutlet weak var beginnerButton: UIButton!
    private var completed = false
    private var containerGradient: CAGradientLayer?

    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            populateData()
            
            let config = UIImage.SymbolConfiguration(weight: .light)
            iconImageView.image = iconImageView.image?
                .withConfiguration(config)
            
            // Setup hold-to-fill animation for begin button
            beginnerButton.setupHoldToFillAnimation(duration: 1.5)
            beginnerButton.applyGlass()
        }

        // MARK: - Setup
        private func setupUI() {
            view.backgroundColor = .systemGroupedBackground

            styleCard(capitalCard)
            styleCard(biasCard)

            styleModuleCard(biasModuleCard, tint: .systemPurple)
            styleModuleCard(marketModuleCard, tint: .systemRed)
            styleModuleCard(timeModuleCard, tint: .systemOrange)
        }

        // MARK: - Data
        private func populateData() {
            capitalLabel.text = "₹50,000"
            capitalLabel.textColor = .systemGreen
            capitalCardLabel.text = "Total Capital"

            biasLabel.text = "50 / 100"
            biasLabel.textColor = .systemOrange
            biasCardLabel.text = "Decision Quality"
            
            biasCardDescriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            biasCardDescriptionLabel.text = "Logic Analysis"
            marketCardLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            marketCardLabel.text = "Market Awareness"
            timerCardLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            timerCardLabel.text = "Time and Opportunity"
            
            biasCardSubtitle.text = "Detect your hidden instinct"
            timerCardSubtitle.text = "Time your hold, exit, or pivot"
            marketCardSubtitle.text = "Strike at the perfect time."
        }

        // MARK: - Card Styling
        private func styleCard(_ view: UIView) {
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 20

            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.08
            view.layer.shadowOffset = CGSize(width: 0, height: 6)
            view.layer.shadowRadius = 16

            view.layer.masksToBounds = false
        }

        private func styleModuleCard(_ view: UIView, tint: UIColor) {
            view.backgroundColor = tint.withAlphaComponent(0.12)
            view.layer.cornerRadius = 20
        }

        @IBAction func beginButtonPressed(_ sender: UIButton) {
            let gameVC = storyboard?.instantiateViewController(
                withIdentifier: "GameViewController"
            ) as! GameViewController

            gameVC.modalPresentationStyle = .fullScreen
            present(gameVC, animated: true)
        }
    }

    // MARK: - Hold to Fill Animation Extension
// MARK: - Hold to Fill Animation Extension
// MARK: - Hold to Fill Animation Extension
extension UIButton {
    
    func setupHoldToFillAnimation(duration: TimeInterval = 2.0) {
        
        // Remove existing gesture recognizers to avoid duplicates
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleHoldGesture(_:)))
        longPress.minimumPressDuration = 0.0
        addGestureRecognizer(longPress)
        
        // Store duration
        layer.setValue(duration, forKey: "fillDuration")
    }
    
    @objc private func handleHoldGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            animateFillFromLeft(gesture: gesture)
            
        case .ended, .cancelled, .failed:
            resetFill(completed: false)
            
        default:
            break
        }
    }
    
    private func animateFillFromLeft(gesture: UILongPressGestureRecognizer) {
        
        // Remove existing fill layer
        layer.sublayers?.first(where: { $0.name == "fillLayer" })?.removeFromSuperlayer()
        
        // Create fill layer
        let fillLayer = CALayer()
        fillLayer.name = "fillLayer"
        fillLayer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.50).cgColor
        
        // FIXED: Set initial frame starting from left with 0 width
        fillLayer.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
        fillLayer.cornerRadius = layer.cornerRadius
        fillLayer.borderWidth = 1.5
        fillLayer.borderColor = UIColor.systemBlue as! CGColor
        
        // FIXED: Set anchor point to left side so it grows from left to right
        fillLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        fillLayer.position = CGPoint(x: 0, y: bounds.height / 2)
        
        // Insert below content
        if let blurView = subviews.first(where: { $0 is UIVisualEffectView }) {
            layer.insertSublayer(fillLayer, below: blurView.layer)
        } else {
            layer.insertSublayer(fillLayer, at: 0)
        }
        
        // Animate width from 0 to full width
        let duration = layer.value(forKey: "fillDuration") as? TimeInterval ?? 2.0
        
        // FIXED: Animate the width property directly
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = 0
        animation.toValue = bounds.width
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        fillLayer.add(animation, forKey: "widthAnimation")
        
        // FIXED: Update the model layer
        fillLayer.bounds.size.width = bounds.width
        
        // Check for completion
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self, weak gesture] in
            guard let self = self, let gesture = gesture else { return }
            // Check if gesture is still active
            if gesture.state == .changed || gesture.state == .began {
                self.onFillComplete()
            }
        }
    }
    
    private func resetFill(completed: Bool) {
        
        guard let fillLayer = layer.sublayers?.first(where: { $0.name == "fillLayer" }) else { return }
        
        fillLayer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.2) {
            fillLayer.opacity = 0
        } completion: { _ in
            fillLayer.removeFromSuperlayer()
        }
    }
    
    private func onFillComplete() {
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Scale animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        
        // Trigger button action
        sendActions(for: .touchUpInside)
        
        // Reset fill
        resetFill(completed: true)
    }
}
