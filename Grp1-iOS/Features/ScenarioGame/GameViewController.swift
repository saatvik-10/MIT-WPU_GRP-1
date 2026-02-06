//
//  GameViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var portfolioCard: UIView!
    @IBOutlet weak var scenarioCard: UIView!
    @IBOutlet weak var biasCard: UIView!
    
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var biasLabel: UILabel!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var scenarioTitleLabel: UILabel!
    @IBOutlet weak var scenatioDescriptionLabel: UILabel!
    
    
    @IBOutlet weak var chooseAnOptionLabel: UILabel!
    @IBOutlet weak var choiceButton3: GameChoiceButton!
    @IBOutlet weak var choiceButton2: GameChoiceButton!
    @IBOutlet weak var choiceButton1: GameChoiceButton!
    
    private var lastRenderedNode: DecisionNode?
    private var frozenFinalCapital: Int?
    private var gameEnded = false


    
    // GameViewController
    func finishGame() {
        guard !gameEnded else {return}
        gameEnded = true
        let ending = evaluateEnding()
        let bias = dominantBias()
        if frozenFinalCapital == nil {
            frozenFinalCapital = state.capital
        }
        showEndingScreen(
            ending: ending,
            capital: frozenFinalCapital!,
            biasScore: state.biasScore,
            dominantBias: bias,
            biasExposure: state.biasExposure

        )
    }

    
    
    private var state = GameState(
        capital: 50_000,
        node: .act1,
        biasScore: 50
    )
    private var lastCapital = 50_000
    private var  initialCapital = 50_000
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setupUI()
        // Do any additional setup after loading the view.
        biasCard.backgroundColor = .clear
        portfolioCard.backgroundColor = .clear
        

    }
    
    func hideAllButtons() {
        [choiceButton1, choiceButton2, choiceButton3].forEach {
            $0?.alpha = 0
            $0?.transform = CGAffineTransform(translationX: 0, y: 12)
            $0?.isHidden = false
        }
    }
    
    func revealButtonsSequentially(_ buttons: [(UIButton, String)]) {

        for (index, pair) in buttons.enumerated() {

            let button = pair.0
            let title = pair.1

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.35) {
                
                // Apply glass BEFORE setting title
                button.applyGlass()
                
                UIView.animate(
                    withDuration: 1.5,
                    delay: 0.5,
                    usingSpringWithDamping: 1.2,
                    initialSpringVelocity: 1.4,
                    options: .curveEaseOut
                ) {
                    button.alpha = 1
                    button.transform = .identity
                }

                button.typeTitle(title)
            }
        }
    }

    
    func setupUI() {
        styleCards()
    }
    
    func resetChoices() {
        let buttons = [choiceButton1, choiceButton2, choiceButton3]

        buttons.forEach {
            $0?.isHidden = false
            $0?.isEnabled = true
            $0?.alpha = 1.0
            $0?.setTitle("", for: .normal)
        }
    }
    func styleCards() {
        [portfolioCard, scenarioCard, biasCard].forEach { card in
            guard let card else { return }

            // Rounded corners
            card.layer.cornerRadius = 16
            card.layer.masksToBounds = false

            // Background
            card.backgroundColor = .white

            // Soft shadow (Apple-style)
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.08
            card.layer.shadowOffset = CGSize(width: 0, height: 6)
            card.layer.shadowRadius = 18

            // Performance optimization
            card.layer.shouldRasterize = true
            card.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    func updatePercentageChange() {

        let change = state.capital - initialCapital
        let percentage = Double(change) / Double(initialCapital) * 100

        let formatted = String(format: "%.1f%%", percentage)
        percentageLabel.text = percentage >= 0 ? "+\(formatted)" : formatted

        let positive = percentage >= 0

        styleStatLabel(
            percentageLabel,
            textColor: positive ? .systemGreen : .systemRed,
            bgColor: (positive ? UIColor.systemGreen : UIColor.systemRed).withAlphaComponent(0.15),
            icon: positive ? "arrow.up.right" : "arrow.down.right"
        )
    }

    func applyBias(_ bias: CognitiveBias, weight: Int) {
        state.biasExposure[bias, default: 0] += weight
        state.biasScore += weight
        updateBiasLabel()
    }
    
    
    func updateBiasLabel() {
        
        biasLabel.numberOfLines = 1
        biasLabel.sizeToFit()
        biasLabel.layoutIfNeeded()


        if let bias = dominantBias() {
            biasLabel.text = bias.rawValue.uppercased()

            styleStatLabel(
                biasLabel,
                textColor: .systemOrange,
                bgColor: UIColor.systemOrange.withAlphaComponent(0.15),
                icon: "brain.head.profile"
            )

        } else {
            biasLabel.text = "NEUTRAL"

            styleStatLabel(
                biasLabel,
                textColor: .systemGray,
                bgColor: UIColor.systemGray.withAlphaComponent(0.15),
                icon: "minus.circle"
            )
        }
    }

    
    func dominantBias() -> CognitiveBias? {
        return state.biasExposure
            .max(by: { $0.value < $1.value })?
            .key
    }

    func evaluateEnding() -> EndingType {
        let capital = frozenFinalCapital ?? state.capital
        
        if capital >= 80000{
            return .success
        }

        if capital >= 40000 {
            return .partialFailure
        }

        if capital <= 40000 && capital >= 20000 {
            return .failure
        }

        return .criticalFailure
    }
    
    
    private func render(){
        
        if gameEnded { return }
        
        let nodeChanged = lastRenderedNode != state.node
        lastRenderedNode = state.node
        
        
        
        if lastCapital != state.capital {
                capitalLabel.animateNumber(
                    from: lastCapital,
                    to: state.capital,
                    duration: abs(lastCapital - state.capital) > 20_000 ? 1.0 : 0.6
                )
                lastCapital = state.capital
            } else {
                capitalLabel.text = "₹\(state.capital)"
            }
        
        timerLabel.text = "0.0 yrs"
        
        // Reset
        choiceButton1.isHidden = false
        choiceButton2.isHidden = false
        choiceButton3.isHidden = false
        resetChoices()
        updateBiasLabel()
        updatePercentageChange()
        switch state.node {
            
            // -------- ACT 1 --------
        case .act1:
            scenarioTitleLabel.text = "The Disruptive Spark"
            scenatioDescriptionLabel.typeThenReveal(
                """
                A leaked National Green Mobility Policy sends shockwaves through the market.

                By 2030, 40% of all new vehicle sales must be electric.
                Investors react instantly.
                Legacy automakers without EV infrastructure got hit.
                Bharat Motors opens 12% lower.
                Nothing has changed inside the company —
                but everything has changed around it.

                """
            )
            hideAllButtons()

            revealButtonsSequentially([
                (choiceButton1, "Hold & Hope"),
                (choiceButton2, "Sell 50 % "),
                (choiceButton3, "Pivot")
            ])
            applyBias(.anchoring, weight: 5)
            
            // -------- LOYALIST FOLLOW-UP --------
        case .loyalist_followup:
            scenarioTitleLabel.text = "Comfort in Familiarity"
            if nodeChanged {
                    scenatioDescriptionLabel.typeThenReveal(
                        """
                        Quarterly results beat expectations,
                        but guidance remains cautious.

                        EPS surprises on the upside.
                        Supply chain risks persist.
                        Analyst opinions are divided.
                        """
                    )
                }
            hideAllButtons()
            revealButtonsSequentially([
            (choiceButton1, "Hold & Hope"),
            (choiceButton2,"Double Down",),
            (choiceButton3 , "Pivot")
            ])
            applyBias(.lossAversion, weight: 15)
            applyBias(.statusQuo, weight: 10)
            timerLabel.text = "0.5yr"
        
        case .loyalist_doubleDown:
            scenarioTitleLabel.text = "The Earnings Surprise"
            if nodeChanged {
                    scenatioDescriptionLabel.typeThenReveal(
                        """
                        Revenue beats estimates.
                        EBITDA margins expand.
                        Guidance is raised.

                        You double down on your position.

                        The stock responds positively,
                        but sector uncertainty remains.
                        """
                    )
                }
            hideAllButtons()

            // Disable others FIRST
            choiceButton2.isEnabled = false
            choiceButton2.alpha = 0
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0

            // Reveal only button 1
            revealButtonsSequentially([
                (choiceButton1, "Time Will Tell")
            ])

            applyBias(.sunkCost, weight: 20)
                applyBias(.overconfidence, weight: 15)
            timerLabel.text = "1.0 yr"
        case .loyalist_timeWillTell:
            scenarioTitleLabel.text = "Time Will Tell"
            if nodeChanged {
                    scenatioDescriptionLabel.typeThenReveal(
                        """
                        You decide to wait it out.

                        Years pass.
                        Capital remains stuck.
                        Inflation and opportunity cost compound.

                        The company survives —
                        but your money doesn’t grow.
                        """
                    )
                }
            hideAllButtons()
            revealButtonsSequentially([
                (choiceButton1 , "Stay the course")
            ])
            
            choiceButton2.isEnabled = false
            choiceButton2.alpha = 0
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0
            chooseAnOptionLabel.isHidden = true
            timerLabel.text = "2.0 yrs"
            
        case .loyalist_doubleDown_loss :
            scenarioTitleLabel.text = "You Doubled Down"
            scenatioDescriptionLabel.text = """
            You added more capital to a losing position.
            Now liquidity has dried up.
            
            Buyers have vanished.Your funds are locked in.

            You’re no longer choosing —
            the market is choosing for you.
            """
            capitalLabel.text = "₹25000"
            choiceButton1.isHidden = true
            choiceButton2.isHidden = true
            choiceButton3.isHidden = true
            timerLabel.text = "2.0 yrs"
        
        case .loyalist_exit:
            scenarioTitleLabel.text = "You exit at loss"
            
            hideAllButtons()
            revealButtonsSequentially([
                (choiceButton1 ,"Go all in EV")
            ])
         
            choiceButton2.isEnabled = false
            choiceButton2.alpha = 0
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0
            
                    
            
            // -------- PRAGMATIST FOLLOW-UP --------
        case .pragmatist_followup:
            scenarioTitleLabel.text = "Partial Exit"
            if nodeChanged {
                    scenatioDescriptionLabel.typeThenReveal(
                        """
                        You sell half your position.

                        Risk is reduced,
                        but uncertainty still lingers.

                        Some capital is safe —
                        the rest is still exposed.

                        This is a turning point. What do you do next?
                        """
                    )
                }
            hideAllButtons()
            revealButtonsSequentially([
            (choiceButton1 ,"Hold Remainder"),
            (choiceButton2 , "Complete Exit")
            ])
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0
            
            
        case .pragmatist_stay:
            scenarioTitleLabel.text = "Risk Contained"
            if nodeChanged {
                    scenatioDescriptionLabel.typeThenReveal(
                        """
                        You reduced exposure early.

                        Losses continue,
                        but on a smaller base.

                        Your capital is bruised —
                        not broken.
                        """
                    )
                }
            hideAllButtons()
            revealButtonsSequentially([
                (choiceButton1 , "Accept Outcome ")
            ])
            
            choiceButton2.isEnabled = false
            choiceButton2.alpha = 0
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0
            chooseAnOptionLabel.isHidden = true
            timerLabel.text = "1.0 yr"
        case .ev_pivot:
            scenarioTitleLabel.text = "The Pivot"
            if nodeChanged {
                    scenatioDescriptionLabel.typeThenReveal(
                        """
                        You exit the legacy auto position.
                        But at a cost of loss.
                        
                        Capital is freed,
                        but risk is reintroduced.

                        A fast-growing EV theme emerges —
                        volatile, but promising.
                        """
                    )
                }
            hideAllButtons()
            revealButtonsSequentially([
                (choiceButton1 , "Go all in EV")
            ])
            
            choiceButton2.isEnabled = false
            choiceButton2.alpha = 0
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0
            applyBias(.adaptability, weight: 30)
            applyBias(.lossAversion, weight: -10)
            timerLabel.text = "1.0 yr"
        case .ev_pivot_loss :
            scenarioTitleLabel.text = "Lithium Sector goes down"
            scenatioDescriptionLabel.typeThenReveal(  """
            Geopolitical tensions erupt across key lithium-producing regions.
            Export routes are disrupted.
            Battery manufacturers scramble for inventory.
            
            EV production slows overnight.
            Investor confidence collapses high-growth EV stocks plunge.
            """
            )
            hideAllButtons()
            revealButtonsSequentially([
                (choiceButton1 , "Accept Outcome")
     
            ])
            choiceButton2.isEnabled = true
            choiceButton2.alpha = 0
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0
            timerLabel.text = "2.0 yrs"
            
        case .ev_pivot_profit :
            scenarioTitleLabel.typeThenReveal( "You have stayed on EV")
            scenatioDescriptionLabel.typeThenReveal("The gamble was worth it. As the EV sector skyrockets, demand begins to outpace supply. While your competitors scramble to retrofit old factories, you are already operational—but now you must defend your territory against new tech giants entering the fray. By staying the course, you’ve secured a dominant foothold in the fastest-growing industry on the planet.")
            hideAllButtons()
            revealButtonsSequentially([
                (choiceButton1 , "Stay the course"),
                (choiceButton2 , "Book the profits and exit" )
            ])
            
            
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0
            timerLabel.text = "2.0 yrs"
            
            
        case .pragmatist_exit:
            scenarioTitleLabel.text = "Capital in Hand"
            scenatioDescriptionLabel.typeThenReveal(
                    """
            You’ve exited Legacy Motors completely.

            Selling 50% earlier softened the blow.
            Now your remaining capital is finally free.

            The optimal strategy is to reinvest into a faster-growing sector —
            where disruption creates opportunity, and timing defines returns.
            """
            )
            hideAllButtons()
            revealButtonsSequentially([
                (choiceButton1 , "Go all in EV with increased capital")
            ])
            choiceButton2.isEnabled = false
            choiceButton2.alpha = 0
            choiceButton3.isEnabled = false
            choiceButton3.alpha = 0
        case .pragmatic_loss:
            scenarioTitleLabel.text = ""
            choiceButton1.setTitle("", for: .normal)
            
        case .ev_profit_book:
            scenarioTitleLabel.text = "You booked the profit timely"
            scenatioDescriptionLabel.typeThenReveal("Timings matter in the market")
            choiceButton1.isHidden = true
            choiceButton2.isHidden = true
            choiceButton3.isHidden = true
            chooseAnOptionLabel.isHidden = true
            timerLabel.text = "2.0 yrs"
        }
    }
    
    
    @IBAction func choiceButton1(_ sender: UIButton) {
        switch state.node {

        case .act1:
            // Hold initially (emotional attachment)
            state.capital -= 8000
            state.biasScore -= 10
            state.node = .loyalist_followup

            

        case .loyalist_followup:
            // Hold & Hope
            state.capital -= 15000
            state.biasScore -= 20
            state.node = .loyalist_timeWillTell
            

        case .loyalist_doubleDown:
            state.capital -= 10000
            state.biasScore -= 15
            state.node = .loyalist_timeWillTell


        case .loyalist_timeWillTell:
            state.capital -= 15000
            state.biasScore -= 25
            state.node = .loyalist_doubleDown_loss
            finishGame()
            return


        case .pragmatist_followup:
            // Hold remainder cautiously
            state.capital -= 5000
            state.biasScore -= 10
            state.node = .pragmatist_stay


        case .pragmatist_stay:
            state.biasScore -= 10
            finishGame()
            return
            
        case .pragmatist_exit:
            
            state.capital += 10000
            state.node = .ev_pivot


        case .ev_pivot:
            state.capital += 40000
            state.biasScore += 15
            state.node = .ev_pivot_profit
            

        case .ev_pivot_profit:
            state.capital -= 20000
            state.biasScore -= 25
            state.node = .ev_pivot_loss
            
            
        case .ev_pivot_loss:
                finishGame()
                return
        default:
            break
        }

        render()
    }

    
    @IBAction func choiceButton2(_ sender: UIButton) {
        switch state.node {
        case .act1:
            state.capital -= 25000
            applyBias(.adaptability, weight: 15)
            state.biasScore -= 15
            state.node = .pragmatist_followup

        
            
            case .loyalist_doubleDown:
                // Time tells you the truth
                state.capital -= 10000
                state.node = .loyalist_timeWillTell
        case .loyalist_followup:
                state.capital += 25000
                state.biasScore -= 20
                state.node = .loyalist_doubleDown
            
            
           

            case .pragmatist_followup:
                // Hold remainder   // SMALLER loss than loyalist
                state.biasScore -= 10
            state.node = .pragmatist_exit
        case .ev_pivot_loss:
            state.capital -= 20000
                state.biasScore -= 30
                state.node = .ev_profit_book
        case .ev_pivot_profit :
                finishGame()
                return
            
            
        case .pragmatist_exit:
            state.node = .ev_pivot
            
       
          
            default:
                break
            }
        render()
    }
    
    @IBAction func choiceButton3(_ sender: UIButton) {
        switch state.node {

        case .act1:
            // Hold initially (emotional attachment)
            state.capital -= 8000
            state.biasScore += 30
            state.node = .ev_pivot

            case .loyalist_followup:
                // Late pivot
                state.capital -= 4000
            state.biasScore -= 30
                state.node = .ev_pivot
            
            case .ev_pivot:
            state.capital -= 10000
            state.node = .ev_pivot_loss
            
            

            default:
                break
            }
        render()
    }
    
    func showEndingScreen(
        ending: EndingType,
        capital: Int,
        biasScore: Int,
        dominantBias : CognitiveBias?,
        biasExposure : [CognitiveBias : Int]
    ) {
        let storyboard = UIStoryboard(name: "Scenario", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "EndingViewController"
        ) as! EndingViewController

        vc.endingType = ending
        vc.finalCapital = capital
        vc.biasScore = biasScore
        vc.dominantBias = dominantBias
        vc.biasExposure = biasExposure
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func applyGlassEffect(to button: UIButton) {

        // Remove old glass layers (important when re-rendering)
        button.subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }

        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blur)

        blurView.frame = button.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true

        button.insertSubview(blurView, at: 0)

        // Rounded button
        button.layer.cornerRadius = 16
        button.clipsToBounds = true

        // Glass border
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        // Title styling
        
        

        // Soft glow
        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
    }


}


extension UIButton {
    func typeTitle(_ text: String, interval: TimeInterval = 0.035) {
        setTitle("", for: .normal)
        let font = UIFont.preferredFont(forTextStyle: .title3)
        
        var i = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if i < text.count {
                let idx = text.index(text.startIndex, offsetBy: i + 1)
                let currentText = String(text[..<idx])
                
                // Use AttributedText to prevent font discontinuity
                let attributedTitle = NSAttributedString(string: currentText, attributes: [
                    .font: font,
                    .foregroundColor: UIColor.black
                ])
                
                self.setAttributedTitle(attributedTitle, for: .normal)
                i += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
extension UIButton {

    func applyGlass() {

        subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }

        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blur)
        
        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
                // Ensure it adjusts if the user changes system text size
                self.titleLabel?.adjustsFontForContentSizeCategory = true
                
                // Frosty text color
                setTitleColor(.black, for: .normal)

        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        blurView.layer.cornerRadius = 18
        blurView.clipsToBounds = true

        insertSubview(blurView, at: 0)

        layer.cornerRadius = 18
        layer.masksToBounds = false   // 🔑 allows border + shadow

        // Glass border
        layer.borderWidth = 1.2
        layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor

        // Frosty text
        setTitleColor(.black, for: .normal)
        

        // Floating shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }
}
