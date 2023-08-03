//
//  NumberTileGame2.swift
//  swift-2048
//
//  Created by Hüseyin Aygan on 27.07.2023.
//  Copyright © 2023 Austin Zheng. All rights reserved.
//

import UIKit

// A view controller representing the swift-Fib2048 game. It serves mostly to tie a GameModel and a GameboardView
// together. Data flow works as follows: user input reaches the view controller and is forwarded to the model. Move
// orders calculated by the model are returned to the view controller and forwarded to the gameboard view, which
// performs any animations to update its state.
class NumberTileGame2ViewController : UIViewController, GameModel2Protocol,RemainingMoveViewProtocol {    
  // How many tiles in both directions the gameboard contains
  var dimension: Int
  // The value of the winning tile
  var threshold: Int
  var board: GameboardView?
  var model: GameModel2?
  var gW: GoalViewProtocol?
  var remainingMoveView : RemainingMoveView?

  // Width of the gameboard
  let boardWidth: CGFloat = 330.0
  // How much padding to place between the tiles
  let thinPadding: CGFloat = 4.5
  let thickPadding: CGFloat = 9.0

  // Amount of space to place between the different component views (gameboard, score view, etc)
  let viewPadding: CGFloat = 20.0

  // Amount that the vertical alignment of the component views should differ from if they were centered
  let verticalViewOffset: CGFloat = 0.0

  init(dimension d: Int, threshold t: Int) {
    dimension = d > 2 ? d : 2
    threshold = t > 8 ? t : 8
    super.init(nibName: nil, bundle: nil)
    model = GameModel2(dimension: dimension, threshold: threshold, delegate: self)
    view.backgroundColor = UIColor.white
    navigationItem.title = "Gradient View"

    // Create a new gradient layer
    let gradientLayer = CAGradientLayer()
    // Set the colors and locations for the gradient layer
    gradientLayer.colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
    gradientLayer.locations = [0.0, 1.0]

    // Set the start and end points for the gradient layer
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

    // Set the frame to the layer
    gradientLayer.frame = view.frame

    // Add the gradient layer as a sublayer to the background view
    view.layer.insertSublayer(gradientLayer, at: 0)
    setupSwipeControls()
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  func setupSwipeControls() {
    let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGame2ViewController.upCommand(_:)))
    upSwipe.numberOfTouchesRequired = 1
    upSwipe.direction = UISwipeGestureRecognizerDirection.up
    view.addGestureRecognizer(upSwipe)

    let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGame2ViewController.downCommand(_:)))
    downSwipe.numberOfTouchesRequired = 1
    downSwipe.direction = UISwipeGestureRecognizerDirection.down
    view.addGestureRecognizer(downSwipe)

    let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGame2ViewController.leftCommand(_:)))
    leftSwipe.numberOfTouchesRequired = 1
    leftSwipe.direction = UISwipeGestureRecognizerDirection.left
    view.addGestureRecognizer(leftSwipe)

    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGame2ViewController.rightCommand(_:)))
    rightSwipe.numberOfTouchesRequired = 1
    rightSwipe.direction = UISwipeGestureRecognizerDirection.right
    view.addGestureRecognizer(rightSwipe)
  }


  // View Controller
  override func viewDidLoad()  {
    super.viewDidLoad()
    setupGame()
  }

  func reset() {
      let game2 = NumberTileGame2ViewController(dimension: 4, threshold: 8)
        game2.modalPresentationStyle = .fullScreen
        game2.modalTransitionStyle = .flipHorizontal
        self.present(game2, animated: true, completion: nil)

  }

  func setupGame() {
    let vcHeight = view.bounds.size.height
    let vcWidth = view.bounds.size.width
    // This nested function provides the x-position for a component view
      func xPositionToCenterView(_ v: UIView , floatp : CGFloat) -> CGFloat {
      let viewWidth = v.bounds.size.width
      let tentativeX = floatp*(vcWidth - viewWidth)
      return tentativeX >= 0 ? tentativeX : 0
    }
    // This nested function provides the y-position for a component view
    func yPositionForViewAtPosition(_ order: Int, views: [UIView]) -> CGFloat {
      assert(views.count > 0)
      assert(order >= 0 && order < views.count)
//      let viewHeight = views[order].bounds.size.height
      let totalHeight = CGFloat(views.count - 1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, { $0 + $1 })
      let viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0

      // Not sure how to slice an array yet
      var acc: CGFloat = 0
      for i in 0..<order {
        acc += viewPadding + views[i].bounds.size.height
      }
      return viewsTop + acc
    }
    let gW = GoalView(backgroundColor: UIColor.systemPink, textColor: UIColor.white, font: UIFont(name: "HelveticaNeue-Bold", size: 22.0) ?? UIFont.systemFont(ofSize: 16.0), radius: 20)
    gW.goal = 89
    let rM = RemainingMoveView(backgroundColor: .systemBlue, textColor: UIColor.white, font:  UIFont(name: "HelveticaNeue-Bold", size: 18.0) ?? UIFont.systemFont(ofSize: 16.0), radius: 20)
    rM.rm = 130
    remainingMoveView=rM

    // Create the gameboard
    let padding: CGFloat = dimension > 5 ? thinPadding : thickPadding
    let v1 = boardWidth - padding*(CGFloat(dimension + 1))
    let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
    let gameboard = GameboardView(dimension: dimension,
      tileWidth: width,
      tilePadding: padding,
      cornerRadius: 6,
      backgroundColor: UIColor.systemYellow,
      foregroundColor: UIColor.darkGray)

    // Set up the frames
    let views = [gW, rM, gameboard]
    var f = gW.frame
    f.origin.x = xPositionToCenterView(gW ,floatp: 1.0) - 5.0
    f.origin.y = yPositionForViewAtPosition(0, views: views)
    gW.frame = f
    var yy = yPositionForViewAtPosition(0, views: views)
    f = rM.frame
    f.origin.x = 5.0
    f.origin.y = yy
    rM.frame = f
    f = gameboard.frame
    f.origin.x = xPositionToCenterView(gameboard ,floatp: 0.5)
    f.origin.y = yPositionForViewAtPosition(1, views: views)
    gameboard.frame = f


    // Add to game state
    view.addSubview(gameboard)
    board = gameboard
    view.addSubview(gW)
    self.gW = gW
    view.addSubview(rM)
    self.remainingMoveView = rM
    assert(model != nil)
    let m = model!
    m.insertTileAtRandomLocation(withValue: 1)
    m.insertTileAtRandomLocation(withValue: 1)
  }

  // Misc
    func followUp() {
    assert(model != nil)
    let m = model!
        let (userWon, _) = m.userHasWon(num1: remainingMoveView?.rm ?? 0)
    if userWon {
        let alertController = UIAlertController(title: "Victory", message: "You Won!", preferredStyle: .alert)

        // Create the actions
        let winAction = UIAlertAction(title: "New Game", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.reset()
        }
         alertController.addAction(winAction)
         // Present the controller
         self.present(alertController, animated: true, completion: nil)
      return
    }

    // Now, insert more tiles
    let randomVal = Int(arc4random_uniform(10))
      m.insertTileAtRandomLocation(withValue: randomVal == 1 ? 2 : 1)

    // At this point, the user may lose
    if m.userHasLost(num2: remainingMoveView?.rm ?? 0) {
      // TODO: .addNewGame Button
      NSLog("You lost...")
           let alertController = UIAlertController(title: "Defeat", message: "You Lost!", preferredStyle: .alert)

           // Create the actions
           let newAction = UIAlertAction(title: "New Game", style: UIAlertActionStyle.default) {
               UIAlertAction in
               self.reset()
           }
            alertController.addAction(newAction)
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
    }
  }

  // Commands
  @objc(up:)
  func upCommand(_ r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.up,
      onCompletion: { (changed: Bool) -> () in
        if changed {
          self.rmDecreased()
          self.followUp()
        }
      })
  }

  @objc(down:)
  func downCommand(_ r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.down,
      onCompletion: { (changed: Bool) -> () in
        if changed {
          self.rmDecreased()
          self.followUp()
        }
      })
  }

  @objc(left:)
  func leftCommand(_ r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.left,
      onCompletion: { (changed: Bool) -> () in
        if changed {
          self.rmDecreased()
          self.followUp()
        }
      })
  }

  @objc(right:)
  func rightCommand(_ r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.right,
      onCompletion: { (changed: Bool) -> () in
        if changed {
          self.rmDecreased()
          self.followUp()
        }
      })
  }

  // Protocol

    func goalChanged(to g2: Int) {
        if gW == nil {
            return
        }
        let g = gW!
        g.goalChanged(to: g2)
    }
  func rmDecreased() {
      if remainingMoveView == nil {
          return
      }
      let rM = remainingMoveView!
      rM.rmDecreased()
  }
  func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.moveOneTile(from: from, to: to, value: value)
  }

  func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.moveTwoTiles(from: from, to: to, value: value)
  }

  func insertTile(at location: (Int, Int), withValue value: Int) {
    assert(board != nil)
    let b = board!
    b.insertTile(at: location, value: value)
  }
}
