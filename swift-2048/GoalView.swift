import UIKit

protocol GoalViewProtocol{
    func goalChanged(to g : Int)
}
class GoalView: UIView , GoalViewProtocol{
    var goal : Int = 89 {
        didSet{
            label.text = "REACH \(goal)"
        }
    }
    let defaultFrame = CGRect( x : 0, y : 0 , width : 200 , height : 55)
    var label: UILabel
    init(backgroundColor bgcolor:UIColor, textColor tcolor: UIColor, font: UIFont, radius r: CGFloat){
        label = UILabel(frame: defaultFrame)
        label.textAlignment = NSTextAlignment.center
        super.init(frame: defaultFrame)
        backgroundColor = bgcolor
        label.textColor = tcolor
        label.font = font
        layer.cornerRadius = r
        self.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func goalChanged (to g : Int){
        goal = g
    }


}
