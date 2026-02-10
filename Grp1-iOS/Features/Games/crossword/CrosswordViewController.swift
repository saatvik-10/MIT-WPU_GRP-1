import UIKit

final class CrosswordViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var keyboardStack: UIStackView!
    private var didSetupRing = false
    
    private var cells: [CrosswordCell] = []
    private var didLoadOnce = false
    private var words: [CrosswordWord] = []
    private var countdownTimer: Timer?
    private var remainingSeconds = 120  // 2 minutes
    private let totalSeconds = 120

    private let gameState = CrosswordGameState()
    
    // FIXED: Use only one set of ring layers
    private let ringLayer = CAShapeLayer()
    private let ringBackgroundLayer = CAShapeLayer()
    
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    
    private let totalCols = 9
    private let totalRows = 9

    private var minX = 0
    private var minY = 0
    private var maxX = 0
    private var maxY = 0
    private var progressScore: Float = 0.0
    private var rewardedWords: Set<Int> = []
    
    private var allPuzzles: [([String], [String: String])] = []
    private var currentPuzzleIndex = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
            setupCollectionView()
            setupKeyboard()
            view.layer.insertSublayer(makeGradient(), at: 0)


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didLoadOnce else { return }
        didLoadOnce = true

        Task {
            await generatePuzzles()
            await loadLevel()
        }
    }
    private func makeGradient() -> CAGradientLayer {
        let g = CAGradientLayer()
        g.colors = [
                UIColor.systemPurple.withAlphaComponent(0.2).cgColor,
                UIColor.systemIndigo.withAlphaComponent(0.2).cgColor
            ]
        g.frame = view.bounds
        return g
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didSetupRing {
                setupRing()
                didSetupRing = true
            }
        gridCollectionView.collectionViewLayout.invalidateLayout()
    }




    private func setupCollectionView() {
        gridCollectionView.dataSource = self
        gridCollectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        gridCollectionView.collectionViewLayout = layout
    }

    //Generate Multiple Crosswords
    @MainActor
    private func generatePuzzles() async {
        allPuzzles = generateUniqueCrosswords(from: financeData, count: 10)
        
        print("Generated \(allPuzzles.count) unique puzzles")
        
        if allPuzzles.isEmpty {
            print("Using fallback puzzles")
//            allPuzzles = createFallbackPuzzles()
        }
        // Shuffling puzzles for variety
        allPuzzles.shuffle()
    }
    
//    private func createFallbackPuzzles() -> [([String], [String: String])] {
//
//        let data = Array(foodData.prefix(15))
//            let words = data.map { $0.name }
//            let clues = Dictionary(uniqueKeysWithValues: data.map { ($0.name, $0.clue) })
//            return [(words, clues)]
//    }
    
    // Load Crossword
    @MainActor
    private func loadLevel() async {
        guard !allPuzzles.isEmpty else {
            print("No puzzles available")
            return
        }
        
        let (inputWords, clues) = allPuzzles[currentPuzzleIndex]
        
        print("Loading puzzle \(currentPuzzleIndex + 1)/\(allPuzzles.count)")
        print("   Words: \(inputWords.joined(separator: ", "))")

        let (board, placedWords) = generateCrossword(words: inputWords)
        guard !placedWords.isEmpty else {
            print("Failed to generate crossword, trying next puzzle...")
            await loadNextPuzzle()
            return
        }

        let occupied = board.enumerated().flatMap { x, col in
            col.enumerated().compactMap { y, char in char != nil ? (x, y) : nil }
        }

        minX = occupied.map { $0.0 }.min()!
        maxX = occupied.map { $0.0 }.max()!
        minY = occupied.map { $0.1 }.min()!
        maxY = occupied.map { $0.1 }.max()!

        let crosswordCols = maxX - minX + 1
        let crosswordRows = maxY - minY + 1

        let offsetX = (9 - crosswordCols) / 2
        let offsetY = (9 - crosswordRows) / 2

        cells = (0..<81).map { index in
            CrosswordCell(
                index: index,
                row: index / 9,
                col: index % 9,
                numbers: [],
                letter: nil,
                correctLetter: nil,
                isBlocked: true,
                isHighlighted: false,
                isCorrectLetter: false,
                isCorrectWord: false,
                isWrongLetter: false,
                isSelected: false
            )
        }

        for w in placedWords {
            for i in 0..<w.string.count {
                let letter = w.string[w.string.index(w.string.startIndex, offsetBy: i)]
                let gx = (w.dir == 0 ? w.x + i : w.x)
                let gy = (w.dir == 0 ? w.y : w.y + i)
                let cx = (gx - minX) + offsetX
                let cy = (gy - minY) + offsetY
                let idx = indexForCell(x: cx, y: cy)
                cells[idx].isBlocked = false
                cells[idx].correctLetter = letter
            }
        }

        words = placedWords.enumerated().map { (i, w) in
            let sx = (w.x - minX) + offsetX
            let sy = (w.y - minY) + offsetY
            let idx = indexForCell(x: sx, y: sy)

            return CrosswordWord(
                number: i + 1,
                answer: w.string,
                clue: clues[w.string] ?? "No clue",
                startIndex: idx,
                direction: w.dir == 0 ? .across : .down
            )
        }

        for word in words {
            cells[word.startIndex].numbers.append(word.number)
        }

        gridCollectionView.reloadData()

        if let first = words.first {
            gameState.selectedWord = first
            gameState.selectedCellIndex = first.startIndex
            gameState.selectedDirection = first.globalDirection
            updateClueLabel()
            highlightSelectedWord()
        }
        startCountdownTimer()
    }
    
    @MainActor
    func loadNextPuzzle() async {

        currentPuzzleIndex = (currentPuzzleIndex + 1) % allPuzzles.count
        await loadLevel()
 
    }
    
    private func isPuzzleComplete() -> Bool {
        for cell in cells where !cell.isBlocked {
            if !isCellCorrect(cell.index) {
                return false
            }
        }
        return true
    }

    // Helpers
    private func indexForCell(x: Int, y: Int) -> Int {
        return y * totalCols + x
    }

    private func updateClueLabel() {
        guard let word = gameState.selectedWord else { return }
        questionLabel.text = "\(word.number). \(word.clue)"
    }
    
    private func findAllWordsForCell(_ cell: CrosswordCell) -> [CrosswordWord] {
        var matchingWords: [CrosswordWord] = []
        
        for word in words {
            var r = cells[word.startIndex].row
            var c = cells[word.startIndex].col
            
            for _ in 0..<word.answer.count {
                if r == cell.row && c == cell.col {
                    matchingWords.append(word)
                    break
                }
                if word.direction == .across { c += 1 }
                else { r += 1 }
            }
        }
        return matchingWords
    }

    // Tap Cell to Select Word
    private func handleGridTap(_ cell: CrosswordCell) {
        let wordsContainingCell = findAllWordsForCell(cell)
        guard !wordsContainingCell.isEmpty else { return }

        // Clear previous selection
        for i in cells.indices {
            cells[i].isSelected = false
        }

        // Select tapped cell
        cells[cell.index].isSelected = true
        gameState.selectedCellIndex = cell.index

        // Direction toggle (only affects clues, NOT cursor)
        if wordsContainingCell.count > 1 {
            let hasAcross = wordsContainingCell.contains { $0.direction == .across }
            let hasDown = wordsContainingCell.contains { $0.direction == .down }

            if hasAcross && hasDown {
                gameState.selectedDirection =
                    (gameState.selectedDirection == .across ? .down : .across)
            }
        }

        // Pick preferred word (for clue display only)
        let preferredWord: CrosswordWord?
        if gameState.selectedDirection == .across {
            preferredWord = wordsContainingCell.first { $0.direction == .across }
                ?? wordsContainingCell.first
        } else {
            preferredWord = wordsContainingCell.first { $0.direction == .down }
                ?? wordsContainingCell.first
        }

        // Update UI
        if let word = preferredWord {
            gameState.selectedWord = word
            gameState.selectedDirection = word.globalDirection
            updateClueLabel()
            highlightSelectedWord()
        }

        gridCollectionView.reloadData()
    }


    private func moveSelectionForward(from index: Int) {
        guard let word = gameState.selectedWord else { return }

        let current = cells[index]
        var row = current.row
        var col = current.col

        if word.direction == .across {
            col += 1
        } else {
            row += 1
        }

        while row < totalRows && col < totalCols {
            let nextIndex = indexForCell(x: col, y: row)

            if !cells[nextIndex].isBlocked {
                // Clearing old selection
                for i in cells.indices {
                    cells[i].isSelected = false
                }

                // Selecting next cell
                cells[nextIndex].isSelected = true
                gameState.selectedCellIndex = nextIndex
                return
            }

            // moving in same direction
            if word.direction == .across {
                col += 1
            } else {
                row += 1
            }
        }
    }

    // Highlight Current Word
    private func highlightSelectedWord() {
        for i in cells.indices {
            cells[i].isHighlighted = false
        }

        guard let word = gameState.selectedWord else { return }

        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col

        for _ in 0..<word.answer.count {
            let idx = indexForCell(x: c, y: r)
            cells[idx].isHighlighted = true

            if word.direction == .across { c += 1 }
            else { r += 1 }
        }
    }

    // Keyboard Setup


    private func playLightHaptic() {
        lightHaptic.prepare()
        lightHaptic.impactOccurred()
    }
    
    // Keyboard Input


    private func insertLetter(_ char: Character) {
        let idx = gameState.selectedCellIndex

        cells[idx].letter = char
        cells[idx].isWrongLetter = false

        if let correct = cells[idx].correctLetter {
            cells[idx].isCorrectLetter = char.uppercased() == correct.uppercased()
        }

        revalidateWords(at: idx)

        if let _ = gameState.selectedWord {
            if isSelectedWordComplete() {
                clearSelection()
                highlightSelectedWord()
                gridCollectionView.reloadData()

                if isPuzzleComplete() {
                    showPuzzleCompleteAlert()
                }
                return
            }
        }

        moveSelectionForward(from: idx)
        highlightSelectedWord()
        gridCollectionView.reloadData()
    }

    private func isSelectedWordComplete() -> Bool {
        guard let word = gameState.selectedWord else { return false }

        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col

        for _ in 0..<word.answer.count {
            let idx = indexForCell(x: c, y: r)
            if cells[idx].letter == nil {
                return false
            }
            if word.direction == .across { c += 1 }
            else { r += 1 }
        }
        return true
    }


    private func isCellCorrect(_ idx: Int) -> Bool {
        guard let letter = cells[idx].letter,
              let correct = cells[idx].correctLetter else {
            return false
        }
        return letter.uppercased() == correct.uppercased()
    }
    
    
    private func deleteLetter() {
        guard let word = gameState.selectedWord else { return }

        let idx = gameState.selectedCellIndex

        // Current cell has a letter
        if cells[idx].letter != nil {
            cells[idx].letter = nil
            cells[idx].isWrongLetter = false
            cells[idx].isCorrectWord = false

            revalidateWords(at: idx)
            highlightSelectedWord()
            gridCollectionView.reloadData()
            return
        }

        // Moving backwards
        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col
        var previousIndex: Int? = nil

        for _ in 0..<word.answer.count {
            let currentIndex = indexForCell(x: c, y: r)
            if currentIndex == idx { break }

            previousIndex = currentIndex

            if word.direction == .across { c += 1 }
            else { r += 1 }
        }

        guard let prev = previousIndex else { return }

        // Update selection
        for i in cells.indices {
            cells[i].isSelected = false
        }

        cells[prev].isSelected = true
        gameState.selectedCellIndex = prev

        // Delete letter
        cells[prev].letter = nil
        cells[prev].isWrongLetter = false
        cells[prev].isCorrectWord = false

        revalidateWords(at: prev)
        highlightSelectedWord()
        gridCollectionView.reloadData()
    }


    private func clearSelection() {
        for i in cells.indices {
            cells[i].isSelected = false
        }
    }
    
    // Check Word Completion
    private func checkWordCompletion(_ word: CrosswordWord) {
        var r = cells[word.startIndex].row
        var c = cells[word.startIndex].col

        var indices: [Int] = []
        var allFilled = true
        var allCorrect = true

        // Collect indices & validate
        for _ in 0..<word.answer.count {
            let idx = indexForCell(x: c, y: r)
            indices.append(idx)

            if let letter = cells[idx].letter {
                if letter.uppercased() != cells[idx].correctLetter?.uppercased() {
                    allCorrect = false
                }
            } else {
                allFilled = false
            }

            if word.direction == .across { c += 1 }
            else { r += 1 }
        }

        guard allFilled else {
            for idx in indices {
                cells[idx].isWrongLetter = false
            }
            return
        }

        if allCorrect {
            for idx in indices {
                cells[idx].isCorrectWord = true
                cells[idx].isWrongLetter = false
            }

            rewardCorrectWord(word)
        }        else {
            for idx in indices {
                cells[idx].isWrongLetter = true
            }
        }
    }

    private func revalidateWords(at cellIndex: Int) {
        let cell = cells[cellIndex]
        let affectedWords = findAllWordsForCell(cell)

        for word in affectedWords {
            checkWordCompletion(word)
        }
    }
    
    // Puzzle Complete Alert
    private func showPuzzleCompleteAlert() {
        let alert = UIAlertController(
            title: "🎉 Puzzle Complete!",
            message: "Congratulations! Would you like to play another puzzle?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Next Puzzle", style: .default) { [weak self] _ in
            Task {
                await self?.loadNextPuzzle()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
        stopTimer()
    }


    // CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
        cell.configure(with: cells[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = cells[indexPath.item]
        if model.isBlocked { return }
        playLightHaptic()
        handleGridTap(model)
    }


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 2
        let totalSpacing = CGFloat(totalCols - 1) * spacing
        let usableWidth = gridCollectionView.bounds.width - totalSpacing
        let cellSide = floor(usableWidth / CGFloat(totalCols))
        return CGSize(width: cellSide, height: cellSide)
    }
    
    private func setupKeyboard() {

        let rows: [[String]] = [
            ["Q","W","E","R","T","Y","U","I","O","P"],
            ["A","S","D","F","G","H","J","K","L"],
            ["⌫","Z","X","C","V","B","N","M","✓"]
        ]

        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.distribution = .fillEqually

            for key in row {
                let button = makeKey(title: key)
                rowStack.addArrangedSubview(button)
            }

            keyboardStack.addArrangedSubview(rowStack)
        }
    }
    private func makeKey(title: String) -> UIButton {
        let button = UIButton(type: .system)

        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

        button.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.systemGray4
            : UIColor.white
        }

        button.layer.cornerRadius = 14
        button.layer.masksToBounds = false

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4

        button.heightAnchor.constraint(equalToConstant: 52).isActive = true

        // ✅ ADD THIS BLOCK HERE
        button.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.08, animations: {
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.08) {
                    button.transform = .identity
                }
            }
        }, for: .touchDown)

        // Existing targets
        if title == "⌫" {
            button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        } else if title == "✓" {
            button.backgroundColor = .systemPurple
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
        }

        return button
    }
    
    @objc private func letterTapped(_ sender: UIButton) {
        guard let letter = sender.titleLabel?.text?.first else { return }
        insertLetter(letter)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    @objc private func submitTapped() {
        // optional: validate whole crossword or move to next word
    }
    @objc private func deleteTapped() {
        deleteLetter()
    }
    private func showPointsPopupFromBottom(
        text: String,
        color: UIColor,
        completion: @escaping () -> Void
    ) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = color
        label.backgroundColor = color.withAlphaComponent(0.18)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true

        let width: CGFloat = 54
        let height: CGFloat = 28

        let startPoint = CGPoint(
            x: view.bounds.midX,
            y: view.bounds.maxY - 140
        )

        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.center = startPoint
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        view.addSubview(label)

        let target = progressBar.convert(
            CGPoint(x: progressBar.bounds.midX, y: progressBar.bounds.midY),
            to: view
        )

        // Rise animation
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.3,
            animations: {
                label.alpha = 1
                label.transform = .identity
                label.center.y -= 120
            }
        )

        // Fly into progress bar
        UIView.animate(
            withDuration: 0.55,
            delay: 0.3,
            options: [.curveEaseInOut],
            animations: {
                label.center = CGPoint(
                    x: target.x,
                    y: target.y - 6
                )
                label.alpha = 0
                label.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            },
            completion: { _ in
                label.removeFromSuperview()
                completion()
            }
        )
    }
    private func incrementProgress(by value: Float) {
        progressScore = min(1.0, progressScore + value)

        UIView.animate(withDuration: 0.35) {
            self.progressBar.setProgress(self.progressScore, animated: true)
            self.updateProgressColor()
        }
    }

    private func updateProgressColor() {
        switch progressScore {
        case 0.7...1.0:
            progressBar.progressTintColor = .systemGreen
        case 0.4..<0.7:
            progressBar.progressTintColor = .systemYellow
        default:
            progressBar.progressTintColor = .systemRed
        }
    }
    private func rewardCorrectWord(_ word: CrosswordWord) {
        // Prevent double rewards
        guard !rewardedWords.contains(word.number) else { return }
        rewardedWords.insert(word.number)

        let points = 10
        let progressIncrement: Float = 0.10

        showPointsPopupFromBottom(
            text: "+$\(points)",
            color: .systemGreen
        ) {
            self.incrementProgress(by: progressIncrement)
        }
    }
    private func startCountdownTimer() {

        countdownTimer?.invalidate()

        remainingSeconds = totalSeconds
        timerLabel.textColor = .label
        updateTimerLabel()
        updateRingProgress(animated: false)

        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }

            self.remainingSeconds -= 1

            if self.remainingSeconds <= 0 {
                self.stopTimer()
                self.onTimeUp()
                return
            }

            self.updateTimerLabel()
            self.updateRingProgress(animated: true)

            // FIXED: Update ringLayer color when time is low
            if self.remainingSeconds <= 10 {
                self.timerLabel.textColor = .systemRed
                self.ringLayer.strokeColor = UIColor.systemRed.cgColor

                UIView.animate(withDuration: 0.15, animations: {
                    self.timerLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }) { _ in
                    self.timerLabel.transform = .identity
                }
            }
        }
    }
    
    private func updateRingProgress(animated: Bool) {

        let progress = CGFloat(remainingSeconds) / CGFloat(totalSeconds)

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = ringLayer.strokeEnd
            animation.toValue = progress
            animation.duration = 1
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            ringLayer.strokeEnd = progress
            ringLayer.add(animation, forKey: "ring")
        } else {
            ringLayer.strokeEnd = progress
        }
    }
    private func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    private func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    private func onTimeUp() {
        timerLabel.text = "00:00"
        timerLabel.textColor = .systemRed

        // Optional haptic
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // Example: show alert
        let alert = UIAlertController(
            title: "⏱ Time's Up!",
            message: "The round has ended.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // FIXED: Simplified setupRing to use ringLayer consistently
    private func setupRing() {
        // Remove old layers if re-layout happens
        ringLayer.removeFromSuperlayer()
        ringBackgroundLayer.removeFromSuperlayer()

        let radius: CGFloat = 50
        let center = CGPoint(
            x: timerLabel.bounds.midX,
            y: timerLabel.bounds.midY
        )

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        // Background ring
        ringBackgroundLayer.path = path.cgPath
        ringBackgroundLayer.strokeColor = UIColor.systemGray4.cgColor
        ringBackgroundLayer.fillColor = UIColor.clear.cgColor
        ringBackgroundLayer.lineWidth = 8

        // Progress ring
        ringLayer.path = path.cgPath
        ringLayer.strokeColor = UIColor.systemGreen.cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 8
        ringLayer.lineCap = .round
        ringLayer.strokeEnd = 1.0

        timerLabel.layer.addSublayer(ringBackgroundLayer)
        timerLabel.layer.addSublayer(ringLayer)
    }
}
