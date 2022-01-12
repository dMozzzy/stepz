//
//  WorkoutOverviewController.swift
//  TheProject
//
//  Created by Victor Privalov on 13.06.21.
//

import UIKit

class WorkoutOverviewController: UIViewController {
    
    enum ViewType {
        case finish
        case view
    }
    
    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet var roundedViews: [UIView]!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    
    weak var coordinator: WorkoutCoordinator?
    
    var endWorkoutOverviewHandler: (UserWorkout, Bool) -> Void = {_,_  in}
    
    var type: ViewType = .finish {
        didSet { if isViewLoaded { setup(type: type) } }
    }
    
    var workout: UserWorkout? {
        didSet { if isViewLoaded { presentWorkout(workout) } }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundedViews.forEach { view in
            view.layer.cornerRadius = 8
        }
        setup(type: type)
        presentWorkout(workout)
        
        stepsLabel.font = stepsLabel.font.rounded
        caloriesLabel.font = caloriesLabel.font.rounded
        distanceLabel.font = distanceLabel.font.rounded
        speedLabel.font = speedLabel.font.rounded
        timeLabel.font = timeLabel.font.rounded
        weekDayLabel.font = weekDayLabel.font.rounded
        dateTimeLabel.font = dateTimeLabel.font.rounded
        
        weekDayLabel.text = workout?.end?.dayOfWeek()
        dateTimeLabel.text = workout?.end?.dateAndTime()
    }
    
    func setup(type: ViewType) {
        switch type {
        case .finish:
            saveButton.isHidden = false
            discardButton.isHidden = false
        case .view:
            saveButton.isHidden = true
            discardButton.isHidden = true
        }
    }
    
    func presentWorkout(_ workout: UserWorkout?) {
        guard let workout = workout else {
            assertionFailure()
            return
        }
        stepsLabel.text = "\(workout.steps)"
        caloriesLabel.text = String(format: "%.1f", workout.calories)
        distanceLabel.attributedText = formatDistance(workout: workout)
        speedLabel.attributedText = formatSpeed(workout: workout)
        timeLabel.text = workout.formattedTime()
    }
    
    func formatDistance(workout: UserWorkout) -> NSAttributedString {
        let distanceString = String(format: "%.2f km", workout.distance / 1000.0)
        
        let attributedString = NSMutableAttributedString(string: distanceString, attributes: [
            .font: distanceLabel.font.rounded,
            .foregroundColor: UIColor.black,
            .kern: 0.4
        ])
        
        attributedString.addAttributes([
            .font: distanceLabel.font.getRounded(size: 16),
            .foregroundColor: UIColor(red: 156.0 / 255.0, green: 156.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0),
            .kern: 0.18
        ], range: NSString(string: distanceString).range(of: "km"))
        
        return attributedString
    }
    
    func formatSpeed(workout: UserWorkout) -> NSAttributedString {
        let speed = (1.0 / workout.avgPace) / 1000.0 * 60.0 * 60.0
        let distanceString = String(format: "%.1f km/h", speed)
        
        let attributedString = NSMutableAttributedString(string: distanceString, attributes: [
            .font: distanceLabel.font.rounded,
            .foregroundColor: UIColor.black,
            .kern: 0.4
        ])
        
        attributedString.addAttributes([
            .font: distanceLabel.font.getRounded(size: 16),
            .foregroundColor: UIColor(red: 156.0 / 255.0, green: 156.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0),
            .kern: 0.18
        ], range: NSString(string: distanceString).range(of: "km/h"))
        
        return attributedString
    }
    
}


extension WorkoutOverviewController {
    @IBAction func saveAction(_ sender: Any) {
        guard let workout = workout else {
            assertionFailure()
            return
        }
        endWorkoutOverviewHandler(workout, true)
    }
    
    @IBAction func discardAction(_ sender: Any) {
        guard let workout = workout else {
            assertionFailure()
            return
        }
        endWorkoutOverviewHandler(workout, false)
    }
}


private extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
    
    func dateAndTime() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' HH:mm"
        return dateFormatter.string(from: self)
    }
}
