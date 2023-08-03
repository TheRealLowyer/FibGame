//
//  ScoreViewController.swift
//  swift-2048
//
//  Created by Hüseyin Aygan on 26.07.2023.
//  Copyright © 2023 Austin Zheng. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController{
    @IBOutlet weak var challangeButton: UIButton!
    
    @IBOutlet weak var normalButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func startGameButtonTapped(_ sender : UIButton) {
      let game = NumberTileGameViewController(dimension: 4, threshold: 987)
        game.modalPresentationStyle = .fullScreen
        game.modalTransitionStyle = .flipHorizontal
        self.present(game, animated: true, completion: nil)
    }
    @IBAction func challangeButtonTapped(_ sender: Any) {
        let game2 = NumberTileGame2ViewController(dimension: 4, threshold: 987)
          game2.modalPresentationStyle = .fullScreen
          game2.modalTransitionStyle = .flipHorizontal
          self.present(game2, animated: true, completion: nil)
        
    }
}


