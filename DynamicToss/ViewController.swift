//
//  ViewController.swift
//  DynamicToss
//
//  Created by Rickey Hrabowskie on 5/2/17.
//  Copyright © 2017 Rickey Hrabowskie. All rights reserved.
//

import UIKit

let ThrowingThreshold: CGFloat = 1000
let ThrowingVelocityPadding: CGFloat = 35

class ViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var redSquare: UIView!
  @IBOutlet weak var blueSquare: UIView!

  fileprivate var originalBounds = CGRect.zero
  fileprivate var originalCenter = CGPoint.zero

  fileprivate var animator: UIDynamicAnimator!
  fileprivate var attachmentBehavior: UIAttachmentBehavior!
  fileprivate var pushBehavior: UIPushBehavior!
  fileprivate var itemBehavior: UIDynamicItemBehavior!

  @IBAction func handleAttachmentGesture(_ sender: UIPanGestureRecognizer) {
    let location = sender.location(in: self.view)
    let boxLocation = sender.location(in: self.imageView)

    switch sender.state {
    case .began:
      print("Your touch start position is \(location)")
      print("Start location in image is \(boxLocation)")

      animator.removeAllBehaviors()

      let centerOffset = UIOffset(horizontal: boxLocation.x - imageView.bounds.midX, vertical: boxLocation.y - imageView.bounds.midY)
      attachmentBehavior = UIAttachmentBehavior(item: imageView, offsetFromCenter: centerOffset, attachedToAnchor: location)

      redSquare.center = attachmentBehavior.anchorPoint
      blueSquare.center = location

      animator.addBehavior(attachmentBehavior)

    case .ended:
      print("Your touch end position is \(location)")
      print("End location in image is \(boxLocation)")

      animator.removeAllBehaviors()

      // 1
      let velocity = sender.velocity(in: view)
      let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))

      if magnitude > ThrowingThreshold {
        // 2
        let pushBehavior = UIPushBehavior(items: [imageView], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: velocity.x / 10, dy: velocity.y / 10)
        pushBehavior.magnitude = magnitude / ThrowingVelocityPadding

        self.pushBehavior = pushBehavior
        animator.addBehavior(pushBehavior)

        // 3
        let angle = Int(arc4random_uniform(20)) - 10

        itemBehavior = UIDynamicItemBehavior(items: [imageView])
        itemBehavior.friction = 0.2
        itemBehavior.allowsRotation = true
        itemBehavior.addAngularVelocity(CGFloat(angle), for: imageView)
        animator.addBehavior(itemBehavior)

        // 4
        let timeOffset = Int64(0.4 * Double(NSEC_PER_SEC))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(timeOffset) / Double(NSEC_PER_SEC)) {
          self.resetDemo()
        }
      } else {
        resetDemo()
      }

    default:
      attachmentBehavior.anchorPoint = sender.location(in: view)
      redSquare.center = attachmentBehavior.anchorPoint

      break
    }
  }

  func resetDemo() {
    animator.removeAllBehaviors()

    UIView.animate(withDuration: 0.45, animations: {
      self.imageView.bounds = self.originalBounds
      self.imageView.center = self.originalCenter
      self.imageView.transform = CGAffineTransform.identity
    }) 
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    animator = UIDynamicAnimator(referenceView: view)
    originalBounds = imageView.bounds
    originalCenter = imageView.center
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

