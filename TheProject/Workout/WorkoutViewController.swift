//
//  WorkoutViewController.swift
//  TheProject
//
//  Created by Victor Privalov on 26.03.21.
//

import UIKit

extension WorkoutViewController {
    enum State {
        case stoped
        case running
    }
}

class WorkoutViewController: UIViewController {
    @IBOutlet weak var countdownBlur: UIVisualEffectView!

    @IBOutlet weak var countdownZeroCenter: NSLayoutConstraint!
    @IBOutlet weak var countdownOneCenter: NSLayoutConstraint!
    @IBOutlet weak var countdownTwoCenter: NSLayoutConstraint!
    @IBOutlet weak var countdownThreeCenter: NSLayoutConstraint!
    
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var twoLabel: UILabel!
    @IBOutlet weak var threeLabel: UILabel!
    
    @IBOutlet weak var pauseLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    weak var coordinator: WorkoutCoordinator?
    var workout = UserWorkout()
    
    var timer: Timer?
    
    var currentInterval: UserWorkout.Interval? {
        workout.intervals.last
    }
    
    var state = State.stoped
    func setState(_ state: State, animated: Bool = true) {
        
        var animation = { }
        
        switch state {
        case .stoped:
            animation = {
                self.pauseLabel.alpha = 1.0
                self.startButton.alpha = 1.0
                self.stopButton.alpha = 1.0
                self.pauseButton.alpha = 0.0
            }
        case .running:
            animation = {
                self.pauseLabel.alpha = 0.0
                self.startButton.alpha = 0.0
                self.stopButton.alpha = 0.0
                self.pauseButton.alpha = 1.0
            }
        }
        self.state = state
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.beginFromCurrentState, .curveEaseOut],
                       animations: animation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        coordinator?.serviceLocator.appState.stateListeners["workout"] = { [weak self] state in
            if state == .background {
                print("Saving workout:\(self != nil)")
                self?.pause()
                self?.coordinator?.properties.currentWorkout = self?.workout
                self?.coordinator?.properties.synchronize()
            }
            if state == .foreground {
                self?.coordinator?.properties.currentWorkout = nil
                self?.coordinator?.properties.synchronize()
                self?.currentInterval?.end = Date()
                self?.updateCurrentInterval()
                self?.start()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.serviceLocator.appState.stateListeners["workout"] = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseLabel.font = pauseLabel.font.rounded
        stepsLabel.font = stepsLabel.font.rounded
        caloriesLabel.font = caloriesLabel.font.rounded
        distanceLabel.font = distanceLabel.font.rounded
        timerLabel.font = timerLabel.font.rounded
        
        oneLabel.font = oneLabel.font.rounded
        twoLabel.font = twoLabel.font.rounded
        threeLabel.font = threeLabel.font.rounded
        
        countdownZeroCenter.constant = -view.bounds.size.height
        countdownOneCenter.constant = -view.bounds.size.height
        countdownTwoCenter.constant = -view.bounds.size.height
        countdownThreeCenter.constant = -view.bounds.size.height
        
        view.bringSubviewToFront(countdownBlur)
        countdownBlur.isHidden = false
        
        setState(state)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startCountdown {
            self.start()
        }
    }
    
    func update() {
        guard isViewLoaded else {
            return
        }
        stepsLabel.text = "\(workout.steps)"
        caloriesLabel.text = String(format: "%.1f", workout.calories)
        timerLabel.text = workout.formattedTime()
        distanceLabel.attributedText = formattedDistance(workout: workout)
        currentInterval?.end = Date()
    }
    
    func updateCurrentInterval() {
        guard let interval = currentInterval else {
            assertionFailure()
            return
        }
        coordinator?.pedometer.queryData(start: interval.start, end: interval.end, completion: {[weak self] data in
            if let data = data {
                interval.update(data)
                self?.update()
            }
        })
    }
    
    func startCountdown(completion: @escaping () -> Void) {
        
        guard coordinator?.timer == true else {
            self.countdownBlur.alpha = 0
            completion()
            return
        }
        
        UIView.animate(withDuration: 3.0, delay: 0, options: [.beginFromCurrentState]) {
            self.countdownBlur.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
                self.countdownBlur.alpha = 0
            }
            completion()
        }
        
        let damping: CGFloat = 0.7
        let velocity: CGFloat = 0.9
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.beginFromCurrentState, .curveEaseOut]) {
            self.countdownThreeCenter.constant = 0
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 0.45, options: [.beginFromCurrentState, .curveEaseIn]) {
            self.threeLabel.alpha = 0.0
            self.threeLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
        
        
        UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.beginFromCurrentState, .curveEaseOut]) {
            self.countdownTwoCenter.constant = 0
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 1.45, options: [.beginFromCurrentState, .curveEaseIn]) {
            self.twoLabel.alpha = 0.0
            self.twoLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
        
        
        UIView.animate(withDuration: 0.5, delay: 2, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.beginFromCurrentState, .curveEaseOut]) {
            self.countdownOneCenter.constant = 0
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 2.45, options: [.beginFromCurrentState, .curveEaseIn]) {
            self.oneLabel.alpha = 0.0
            self.oneLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
    }
}

// MARK: - Workout control
extension WorkoutViewController {
    func start() {
        guard let coordinator = coordinator else {
            assertionFailure("No Coordinator")
            return
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] timer in
                self?.update()
        })
        
        let startDate = coordinator.pedometer.startUpdates(handler: { [weak self] data in
            guard let data = data else { return }
            self?.currentInterval?.update(data)
            self?.update()
        })
        let interval = UserWorkout.Interval(start: startDate)
        workout.intervals.append(interval)
        setState(.running)
    }
    
    func stop() {
        guard state == .stoped else {
            assertionFailure("Should be stopped already")
            return
        }
        coordinator?.endWorkout(workout)
    }
    
    func pause() {
        timer?.invalidate()
        coordinator?.pedometer.stop()
        currentInterval?.end = Date()
        setState(.stoped)
    }
    
    func formattedDistance(workout: UserWorkout) -> NSAttributedString {
        var distance = workout.distance
        var metric = " m"
        var format = "%.0f"
        if distance >= 1000 {
            distance /= 1000
            metric = "km"
            format = "%.1f"
        }
        
        let distanceString = String(format: "\(format)\(metric)", distance)
        
        let attributedString = NSMutableAttributedString(string: distanceString, attributes: [
            .font: distanceLabel.font.rounded,
            .foregroundColor: UIColor.black,
            .kern: 0.4
        ])
        
        attributedString.addAttributes([
            .font: distanceLabel.font.getRounded(size: 20),
            .foregroundColor: UIColor(red: 156.0 / 255.0, green: 156.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0),
            .kern: 0.18
        ], range: NSString(string: distanceString).range(of: metric))
        
        return attributedString
    }
}

// MARK: - IBActions
extension WorkoutViewController {
    @IBAction func startAction(_ sender: Any) {
        start()
    }
    @IBAction func stopAction(_ sender: Any) {
        stop()
    }
    @IBAction func mapAction(_ sender: Any) {
    }
    @IBAction func pauseAction(_ sender: Any) {
        pause()
    }
}
