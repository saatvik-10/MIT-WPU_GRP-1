//
//  QuizViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class QuizViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var questionLabel: UILabel!

    @IBOutlet weak var optionButton1: UIButton!
    @IBOutlet weak var optionButton2: UIButton!
    @IBOutlet weak var optionButton3: UIButton!
    @IBOutlet weak var optionButton4: UIButton!

    var quizQuestions: [QuizQuestion] = []
    private var currentQuestionIndex = 0
        override func viewDidLoad() {
            super.viewDidLoad()

            guard let articleId = QuizContext.shared.selectedArticleId else { return }

                quizQuestions = QuizStore.shared.quizForArticle(articleId: articleId)

                renderCurrentQuestion()        }
    
    func renderCurrentQuestion() {

        guard !quizQuestions.isEmpty else {
            questionLabel.text = "No quiz available"
            return
        }

        let question = quizQuestions[currentQuestionIndex]

        questionLabel.text = question.question

        let buttons = [
            optionButton1,
            optionButton2,
            optionButton3,
            optionButton4
        ]

        for (index, button) in buttons.enumerated() {
            button?.setTitle(question.options[index], for: .normal)
            button?.tag = index
            button?.isEnabled = true
            button?.backgroundColor = .systemGray6
        }
        updateProgress()
    }
    
    
    func updateProgress() {
        let progress = Float(currentQuestionIndex + 1) / Float(quizQuestions.count)
        progressView.setProgress(progress, animated: true)
    }
    @IBAction func optionTapped(_ sender: UIButton) {

        let selectedIndex = sender.tag
        let question = quizQuestions[currentQuestionIndex]

        if selectedIndex == question.correctIndex {
            sender.backgroundColor = .systemGreen
        } else {
            sender.backgroundColor = .systemRed
        }

        // Disable all buttons after selection
        optionButton1.isEnabled = false
        optionButton2.isEnabled = false
        optionButton3.isEnabled = false
        optionButton4.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.goToNextQuestion()
        }
    }
    
    func goToNextQuestion() {

        if currentQuestionIndex + 1 < quizQuestions.count {
            currentQuestionIndex += 1
            renderCurrentQuestion()
        } else {
            showQuizCompleted()
        }
    }
    
    func showQuizCompleted() {
        progressView.setProgress(1.0, animated: true)
        questionLabel.text = "Quiz Completed 🎉"

        optionButton1.isHidden = true
        optionButton2.isHidden = true
        optionButton3.isHidden = true
        optionButton4.isHidden = true
    }
}
