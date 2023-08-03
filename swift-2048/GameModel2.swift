//
//  GameModel2.swift
//  swift-2048
//
//  Created by Hüseyin Aygan on 27.07.2023.
//  Copyright © 2023 Austin Zheng. All rights reserved.
//
import UIKit
// A protocol that establishes a way for the game model to communicate with its parent view controller.
protocol GameModel2Protocol : class {
  func goalChanged(to g : Int)
  func rmDecreased()
  func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int)
  func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
  func insertTile(at location: (Int, Int), withValue value: Int)
}

// A class representing the game state and game logic for the game. It is owned by a NumberTileGame view controller.
class GameModel2 : NSObject {
  let dimension : Int
  let threshold : Int

  var goal : Int = 89 {
    didSet {
      delegate.goalChanged(to: goal)
    }
  }
    var rm : Int = 130 {
      didSet{
        delegate.rmDecreased()
      }
    }
  var gameboard: SquareGameboard<TileObject>
  unowned let delegate : GameModel2Protocol
  var queue: [MoveCommand]
  var timer: Timer
  var nextGoal = 89
  let maxCommands = 100
  let queueDelay = 0.3

  init(dimension d: Int, threshold t: Int, delegate: GameModel2Protocol) {
    dimension = d
    threshold = t
    self.delegate = delegate
    queue = [MoveCommand]()
    timer = Timer()
    gameboard = SquareGameboard(dimension: d, initialValue: .empty)
    super.init()
  }

  // Reset the game state.
  func reset() {
    nextGoal = 89
    goal = 89
    rm = 131
    gameboard.setAll(to: .empty)
    queue.removeAll(keepingCapacity: true)
    timer.invalidate()
  }

  // Order the game model to perform a move (because the user swiped their finger). The queue enforces a delay of a few
  // milliseconds between each move.
  func queueMove(direction: MoveDirection, onCompletion: @escaping (Bool) -> ()) {
    guard queue.count <= maxCommands else {
      // Queue is wedged. This should actually never happen in practice.
      return
    }

    queue.append(MoveCommand(direction: direction, completion: onCompletion))
    if !timer.isValid {
      // Timer isn't running, so fire the event immediately
      timerFired(timer)
    }
  }

  //------------------------------------------------------------------------------------------------------------------//

  // Inform the game model that the move delay timer fired. Once the timer fires, the game model tries to execute a
  // single move that changes the game state.
  @objc func timerFired(_: Timer) {
    if queue.count == 0 {
      return
    }
    // Go through the queue until a valid command is run or the queue is empty
    var changed = false
    while queue.count > 0 {
      let command = queue[0]
      queue.remove(at: 0)
      changed = performMove(direction: command.direction)
      command.completion(changed)
      if changed {
        // If the command doesn't change anything, we immediately run the next one
        break
      }
    }
    if changed {
      timer = Timer.scheduledTimer(timeInterval: queueDelay,
        target: self,
        selector:
        #selector(GameModel2.timerFired(_:)),
        userInfo: nil,
        repeats: false)
    }
  }

    
  //------------------------------------------------------------------------------------------------------------------//

    
  // Insert a tile with a given value at a position upon the gameboard.
  func insertTile(at location: (Int, Int), value: Int) {
    let (x, y) = location
    if case .empty = gameboard[x, y] {
      gameboard[x, y] = TileObject.tile(value)
      delegate.insertTile(at: location, withValue: value)
    }
  }

  // Insert a tile with a given value at a random open position upon the gameboard.
  func insertTileAtRandomLocation(withValue value: Int) {
    
    let openSpots = gameboardEmptySpots()
    if openSpots.isEmpty {
      // No more open spots; don't even bother
      return
    }
    // Randomly select an open spot, and put a new tile there
    let idx = Int(arc4random_uniform(UInt32(openSpots.count-1)))
    let (x, y) = openSpots[idx]
    insertTile(at: (x, y), value: value)
  }

  // Return a list of tuples describing the coordinates of empty spots remaining on the gameboard.
  func gameboardEmptySpots() -> [(Int, Int)] {
    var buffer : [(Int, Int)] = []
    for i in 0..<dimension {
      for j in 0..<dimension {
        if case .empty = gameboard[i, j] {
          buffer += [(i, j)]
        }
      }
    }
    return buffer
  }

  //------------------------------------------------------------------------------------------------------------------//
  func tileBelowHasSameValue(location: (Int, Int), value: Int) -> Bool {
    let (x, y) = location
    guard y != dimension - 1 else {
      return false
    }
    if case let .tile(v) = gameboard[x, y+1] {
        switch value {
        case 1:
           return ( v == 1 || v == 2)
        case 2:
            return ( v == 1 || v == 3)
        case 3:
            return ( v == 2 || v == 5)
        case 5:
            return ( v == 3 || v == 8)
        case 8:
            return ( v == 5 || v == 13)
        case 13:
            return ( v == 8 || v == 21)
        case 21:
            return ( v == 13 || v == 34)
        case 34:
            return ( v == 21 || v == 55)
        case 55:
            return ( v == 34 || v == 89)
        case 89:
            return ( v == 55 || v == 144)
        case 144:
            return ( v == 89 || v == 233)
        case 233:
            return ( v == 144 || v == 377)
        case 377:
            return ( v == 233 || v == 610)
        case 610:
            return v==377
        default:
            return false
        }
    }
    return false
  }
   
  func tileToRightHasSameValue(location: (Int, Int), value: Int) -> Bool {
    let (x, y) = location
    guard x != dimension - 1 else {
      return false
    }
    if case let .tile(v) = gameboard[x+1, y] {
        switch value {
        case 1:
           return ( v == 1 || v == 2)
        case 2:
            return ( v == 1 || v == 3)
        case 3:
            return ( v == 2 || v == 5)
        case 5:
            return ( v == 3 || v == 8)
        case 8:
            return ( v == 5 || v == 13)
        case 13:
            return ( v == 8 || v == 21)
        case 21:
            return ( v == 13 || v == 34)
        case 34:
            return ( v == 21 || v == 55)
        case 55:
            return ( v == 34 || v == 89)
        case 89:
            return ( v == 55 || v == 144)
        case 144:
            return ( v == 89 || v == 233)
        case 233:
            return ( v == 144 || v == 377)
        case 377:
            return ( v == 233 || v == 610)
        case 610:
            return v==377
        default:
            return false
        }
        
    }
    return false
  }

    func userHasLost(num2:Int) -> Bool {
//    guard gameboardEmptySpots().isEmpty else {
//      // Player can't lose before filling up the board
//      return false
//    }
      
    // Run through all the tiles and check for possible moves
    for i in 0..<dimension {
      for j in 0..<dimension {
        switch gameboard[i, j] {
        case .empty:
//          assert(false, "Gameboard reported itself as full, but we still found an empty tile. This is a logic error.")
            if num2 > 0{
                return false
            }
        case let .tile(v):
          if (tileBelowHasSameValue(location: (i, j), value: v) ||
              tileToRightHasSameValue(location: (i, j), value: v) ) && num2 > 0
          {
            return false
          }
        }
      }
    }
    return true
  }

    func userHasWon(num1 : Int) -> (Bool, (Int, Int)?) {
    for i in 0..<dimension {
      for j in 0..<dimension {
        // Look for a tile with the winning score or greater
          if case let .tile(v) = gameboard[i, j], v >= threshold && num1>0 { // user win condition
          return (true, (i, j))
        }
      }
    }
    return (false, nil)
  }
    func userHasReached()-> Int{
        var temp = Int()
        temp = 1
        for i in 0..<dimension {
          for j in 0..<dimension {
            // Look for a tile with the higher value than temp
            if case let .tile(v) = gameboard[i, j], v >= temp { // new highest condition
                temp=v // reassigning the temp value to highest tile
            }
          }
        }
        return temp // returning the highest value that user has reached
    }
    

  //------------------------------------------------------------------------------------------------------------------//

  // Perform all calculations and update state for a single move.
  func performMove(direction: MoveDirection) -> Bool {
    // Prepare the generator closure. This closure differs in behavior depending on the direction of the move. It is
    // used by the method to generate a list of tiles which should be modified. Depending on the direction this list
    // may represent a single row or a single column, in either direction.
    let coordinateGenerator: (Int) -> [(Int, Int)] = { (iteration: Int) -> [(Int, Int)] in
      var buffer = Array<(Int, Int)>(repeating: (0, 0), count: self.dimension)
      for i in 0..<self.dimension {
        switch direction {
        case .up: buffer[i] = (i, iteration)
        case .down: buffer[i] = (self.dimension - i - 1, iteration)
        case .left: buffer[i] = (iteration, i)
        case .right: buffer[i] = (iteration, self.dimension - i - 1)
        }
      }
      return buffer
    }

    var atLeastOneMove = false
    for i in 0..<dimension {
      // Get the list of coords
      let coords = coordinateGenerator(i)

      // Get the corresponding list of tiles
      let tiles = coords.map() { (c: (Int, Int)) -> TileObject in
        let (x, y) = c
        return self.gameboard[x, y]
      }
      switch userHasReached() { // chechking the highest tile
      case 89:
          if nextGoal==89{
              rm=61
              nextGoal=144
          }
        goal = 144
      case 144:
          if nextGoal==144{
              rm=1001
              nextGoal=233
          }
        goal = 233
      case 233:
          if nextGoal==233{
              rm=101
              nextGoal=377
          }
        goal=377
      case 377:
          if nextGoal==377{
              rm=201
              nextGoal=610
          }
        goal = 610
      case 610:
          if nextGoal==610{
              rm=351
              nextGoal=987
          }
        goal = 987
      default:
        goal=89
      }

      // Perform the operation
      let orders = merge(tiles)
      atLeastOneMove = orders.count > 0 ? true : atLeastOneMove

      // Write back the results
      for object in orders {
        switch object {
        case let MoveOrder.singleMoveOrder(s, d, v, wasMerge):
          // Perform a single-tile move
          let (sx, sy) = coords[s]
          let (dx, dy) = coords[d]

          gameboard[sx, sy] = TileObject.empty
          gameboard[dx, dy] = TileObject.tile(v)
          delegate.moveOneTile(from: coords[s], to: coords[d], value: v)
        case let MoveOrder.doubleMoveOrder(s1, s2, d, v):
          // Perform a simultaneous two-tile move
          let (s1x, s1y) = coords[s1]
          let (s2x, s2y) = coords[s2]
          let (dx, dy) = coords[d]
          gameboard[s1x, s1y] = TileObject.empty
          gameboard[s2x, s2y] = TileObject.empty
          gameboard[dx, dy] = TileObject.tile(v)
          delegate.moveTwoTiles(from: (coords[s1], coords[s2]), to: coords[d], value: v)
        }
      }
    }
    return atLeastOneMove
  }

  //------------------------------------------------------------------------------------------------------------------//

  // When computing the effects of a move upon a row of tiles, calculate and return a list of ActionTokens
  //  corresponding to any moves necessary to remove interstital space. For example, |[3][ ][ ][13]| will become
  // |[3][13]|.
  func condense(_ group: [TileObject]) -> [ActionToken] {
    var tokenBuffer = [ActionToken]()
    for (idx, tile) in group.enumerated() {
      // Go through all the tiles in 'group'. When we see a tile 'out of place', create a corresponding ActionToken.
      switch tile {
      case let .tile(value) where tokenBuffer.count == idx:
        tokenBuffer.append(ActionToken.noAction(source: idx, value: value))
      case let .tile(value):
        tokenBuffer.append(ActionToken.move(source: idx, value: value))
      default:
        break
      }
    }
    return tokenBuffer;
  }

  class func quiescentTileStillQuiescent(inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
    // Return whether or not a 'NoAction' token still represents an unmoved tile
    return (inputPosition == outputLength) && (originalPosition == inputPosition)
  }

  // When computing the effects of a move upon a row of tiles, calculate and return an updated list of ActionTokens
  // corresponding to any merges that should take place. This method collapses adjacent tiles of equal value, but each
  // tile can take part in at most one collapse per move. For example, |[1][2][13][2][2]| will become |[3][13][2][2]|.
  func collapse(_ group: [ActionToken]) -> [ActionToken] {
      

    var tokenBuffer = [ActionToken]()
    var skipNext = false
    for (idx, token) in group.enumerated() {
      if skipNext {
        // Prior iteration handled a merge. So skip this iteration.
        skipNext = false
        continue
      }
      switch token {
      case .singleCombine:
        assert(false, "Cannot have single combine token in input")
      case .doubleCombine:
        assert(false, "Cannot have double combine token in input")
      case let .noAction(s, v)
        where (idx < group.count-1
               && isFibSum(number1:v,number2:group[idx+1].getValue()) && rm>0
          && GameModel2.quiescentTileStillQuiescent(inputPosition: idx, outputLength: tokenBuffer.count, originalPosition: s)):
        // This tile hasn't moved yet, but matches the next tile. This is a single merge
        // The last tile is *not* eligible for a merge
        let next = group[idx+1]
        let nv = v + group[idx+1].getValue()
        skipNext = true
        tokenBuffer.append(ActionToken.singleCombine(source: next.getSource(), value: nv))
      case let t where (idx < group.count-1 && rm>0 && isFibSum(number1:t.getValue(),number2:group[idx+1].getValue())):
        // This tile has moved, and matches the next tile. This is a double merge
        // (The tile may either have moved prevously, or the tile might have moved as a result of a previous merge)
        // The last tile is *not* eligible for a merge
        let next = group[idx+1]
        let nv = t.getValue() + group[idx+1].getValue()
        skipNext = true
        tokenBuffer.append(ActionToken.doubleCombine(source: t.getSource(), second: next.getSource(), value: nv))
      case let .noAction(s, v) where !GameModel2.quiescentTileStillQuiescent(inputPosition: idx, outputLength: tokenBuffer.count, originalPosition: s):
        // A tile that didn't move before has moved (first cond.), or there was a previous merge (second cond.)
        tokenBuffer.append(ActionToken.move(source: s, value: v))
      case let .noAction(s, v):
        // A tile that didn't move before still hasn't moved
        tokenBuffer.append(ActionToken.noAction(source: s, value: v))
      case let .move(s, v):
        // Propagate a move
        tokenBuffer.append(ActionToken.move(source: s, value: v))
      default:
        // Don't do anything
        break
      }
    }
    return tokenBuffer
  }
    func isFibSum(number1: Int, number2 : Int) ->Bool {
        switch number2 {
        case 1:
           return ( number1 == 1 || number1 == 2)
        case 2:
            return ( number1 == 1 || number1 == 3)
        case 3:
            return ( number1 == 2 || number1 == 5)
        case 5:
            return ( number1 == 3 || number1 == 8)
        case 8:
            return ( number1 == 5 || number1 == 13)
        case 13:
            return ( number1 == 8 || number1 == 21)
        case 21:
            return ( number1 == 13 || number1 == 34)
        case 34:
            return ( number1 == 21 || number1 == 55)
        case 55:
            return ( number1 == 34 || number1 == 89)
        case 89:
            return ( number1 == 55 || number1 == 144)
        case 144:
            return ( number1 == 89 || number1 == 233)
        case 233:
            return ( number1 == 144 || number1 == 377)
        case 377:
            return ( number1 == 233 || number1 == 610)
        case 610:
            return number1==377
        default:
            return false
        }
        
    }
  // When computing the effects of a move upon a row of tiles, take a list of ActionTokens prepared by the condense()
  // and convert() methods and convert them into MoveOrders that can be fed back to the delegate.
  func convert(_ group: [ActionToken]) -> [MoveOrder] {
    var moveBuffer = [MoveOrder]()
    for (idx, t) in group.enumerated() {
      switch t {
      case let .move(s, v):
        moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, value: v, wasMerge: false))
      case let .singleCombine(s, v):
        moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, value: v, wasMerge: true))
      case let .doubleCombine(s1, s2, v):
        moveBuffer.append(MoveOrder.doubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, value: v))
      default:
        // Don't do anything
        break
      }
    }
    return moveBuffer
  }

  // Given an array of TileObjects, perform a collapse and create an array of move orders.
  func merge(_ group: [TileObject]) -> [MoveOrder] {
    // Calculation takes place in three steps:
    // 1. Calculate the moves necessary to produce the same tiles, but without any interstital space.
    // 2. Take the above, and calculate the moves necessary to collapse adjacent tiles of equal value.
    // 3. Take the above, and convert into MoveOrders that provide all necessary information to the delegate.
    return convert(collapse(condense(group)))
  }
}

