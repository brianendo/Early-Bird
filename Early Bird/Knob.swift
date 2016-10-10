//
//  Knob.swift
//  KnobDemo
//
//  Created by Brian Endo on 9/28/16.
//  Copyright © 2016 Mikael Konutgan. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

open class Knob: UIControl {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        createSublayers()
        
        let gr = RotationGestureRecognizer(target: self, action: #selector(Knob.handleRotation(_:)))
        self.addGestureRecognizer(gr)
    }
    
    func handleRotation(_ sender: AnyObject) {
        let gr = sender as! RotationGestureRecognizer
        
        // 1. Mid-point angle
        let midPointAngle = (2.0 * CGFloat(M_PI) + self.startAngle - self.endAngle) / 2.0 + self.endAngle
        
        // 2. Ensure the angle is within a suitable range
        var boundedAngle = gr.rotation
        if boundedAngle > midPointAngle {
            boundedAngle -= 2.0 * CGFloat(M_PI)
        } else if boundedAngle < (midPointAngle - 2.0 * CGFloat(M_PI)) {
            boundedAngle += 2 * CGFloat(M_PI)
        }
        
        // 3. Bound the angle within a suitable range
        boundedAngle = min(self.endAngle, max(self.startAngle, boundedAngle))
        
        // 4. Convert the angle to a value
        let angleRange = endAngle - startAngle
        let valueRange = maximumValue - minimumValue
        let valueForAngle = Float(boundedAngle - startAngle) / Float(angleRange) * valueRange + minimumValue
        
        self.value = valueForAngle
        
        if continuous {
            sendActions(for: .valueChanged)
        } else {
            // Only send an update if the gesture has completed
            if (gr.state == UIGestureRecognizerState.ended) || (gr.state == UIGestureRecognizerState.cancelled) {
                sendActions(for: .valueChanged)
            }
        }
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate var backingValue: Float = 0.0
    
    /** Contains the receiver's current value. */
    open var value: Float {
        get { return backingValue }
        set { setValue(newValue, animated: false) }
    }
    
    /** Sets the receiver's current value, allowing you to animated to change visually. */
    open func setValue(_ value: Float, animated: Bool) {
        if value != self.value {
            // Save the value to the backing value
            // Make sure we limit it to the requested bounds
            self.backingValue = min(self.maximumValue, max(self.minimumValue, value))
            
            // Now let's update the know with the correct angle
            let angleRange = endAngle - startAngle
            let valueRange = CGFloat(maximumValue - minimumValue)
            let angle = CGFloat(value - minimumValue) / valueRange * angleRange + startAngle
            knobRenderer.setPointerAngle(angle, animated: animated)
        }
    }
    
    /** Contains the minimum value of the receiver. */
    open var minimumValue: Float = 0.0
    
    /** Contains the maximum value of the receiver. */
    open var maximumValue: Float = 1.0
    
    /** Contains a Boolean value indicating whether changes in
    the sliders value generate continuos update events. */
    open var continuous = true
    
    fileprivate let knobRenderer = KnobRenderer()
    
    func createSublayers() {
        knobRenderer.update(bounds)
        knobRenderer.strokeColor = tintColor
        knobRenderer.startAngle = CGFloat((-M_PI) / 2) //-CGFloat(M_PI * 11.0 / 8.0)
        knobRenderer.endAngle = CGFloat((3 * M_PI) / 2) //CGFloat(M_PI * 3 / 8.0)
        knobRenderer.pointerAngle = knobRenderer.startAngle
        knobRenderer.lineWidth = 2.0
        knobRenderer.pointerLength = 6.0
        
        layer.addSublayer(knobRenderer.trackLayer)
        layer.addSublayer(knobRenderer.pointerLayer)
    }
    
    /** Specifies the angle of the start of the knob control track. Defaults to -11pi/8 */
    open var startAngle: CGFloat {
        get { return knobRenderer.startAngle }
        set { knobRenderer.startAngle = newValue }
    }
    
    /** Specifies the end angle of the knob control track. Defaults to 3pi/8 */
    open var endAngle: CGFloat {
        get { return knobRenderer.endAngle }
        set { knobRenderer.endAngle = newValue }
    }
    
    /** Specifies the width in points of the knob control track. Defaults to 2.0 */
    open var lineWidth: CGFloat {
        get { return knobRenderer.lineWidth }
        set { knobRenderer.lineWidth = newValue }
    }
    
    open var pointerLength: CGFloat {
        get { return knobRenderer.pointerLength }
        set { knobRenderer.pointerLength = newValue }
    }
    
    open override func tintColorDidChange() {
        knobRenderer.strokeColor = tintColor
    }
}

private class KnobRenderer {
    
    var strokeColor: UIColor {
        get {
            return UIColor(cgColor: trackLayer.strokeColor!)
        }
        
        set(strokeColor) {
            trackLayer.strokeColor = strokeColor.cgColor
            pointerLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    
    var lineWidth: CGFloat = 1.0 {
        didSet { update() }
    }
    
    let trackLayer = CAShapeLayer()
    var startAngle: CGFloat = 0.0 {
        didSet { update() }
    }
    var endAngle: CGFloat = 0.0 {
        didSet { update() }
    }
    
    let pointerLayer = CAShapeLayer()
    var backingPointerAngle: CGFloat = 0.0
    
    var pointerAngle: CGFloat {
        get { return backingPointerAngle }
        set { setPointerAngle(newValue, animated: false) }
    }
    
    func setPointerAngle(_ pointerAngle: CGFloat, animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        pointerLayer.transform = CATransform3DMakeRotation(pointerAngle, 0, 0, 1.0)
        
        CATransaction.commit()
        
        if animated {
            let midAngle = (max(pointerAngle, self.pointerAngle) - min(pointerAngle, self.pointerAngle) ) / 2.0 + min(pointerAngle, self.pointerAngle)
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.duration = 0.25
            
            animation.values = [self.pointerAngle, midAngle, pointerAngle]
            animation.keyTimes = [0.0, 0.5, 1.0]
            animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            pointerLayer.add(animation, forKey: nil)
        }
        
        self.backingPointerAngle = pointerAngle
    }
    
    var pointerLength: CGFloat = 0.0 {
        didSet { update() }
    }
    
    init() {
        trackLayer.fillColor = UIColor.clear.cgColor
        pointerLayer.fillColor = UIColor.clear.cgColor
    }
    
    func updateTrackLayerPath() {
        let arcCenter = CGPoint(x: trackLayer.bounds.width / 2.0, y: trackLayer.bounds.height / 2.0)
        let offset = max(pointerLength, trackLayer.lineWidth / 2.0)
        let radius = min(trackLayer.bounds.height, trackLayer.bounds.width) / 2.0 - offset
        trackLayer.path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
    }
    
    func updatePointerLayerPath() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: pointerLayer.bounds.width - pointerLength - pointerLayer.lineWidth / 2.0, y: pointerLayer.bounds.height / 2.0))
        path.addLine(to: CGPoint(x: pointerLayer.bounds.width, y: pointerLayer.bounds.height / 2.0))
        pointerLayer.path = path.cgPath
    }
    
    func update() {
        trackLayer.lineWidth = lineWidth
        pointerLayer.lineWidth = lineWidth
        
        updateTrackLayerPath()
        updatePointerLayerPath()
    }
    
    func update(_ bounds: CGRect) {
        let position = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        
        trackLayer.bounds = bounds
        trackLayer.position = position
        
        pointerLayer.bounds = bounds
        pointerLayer.position = position
        
        update()
    }
}

private class RotationGestureRecognizer: UIPanGestureRecognizer {
    var rotation: CGFloat = 0.0
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        
        minimumNumberOfTouches = 1
        maximumNumberOfTouches = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        updateRotationWithTouches(touches)
    }
    
    fileprivate override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        updateRotationWithTouches(touches)
    }
    
    
    func updateRotationWithTouches(_ touches: Set<NSObject>) {
        if let touch = touches[touches.startIndex] as? UITouch {
            self.rotation = rotationForLocation(touch.location(in: self.view))
        }
    }
    
    func rotationForLocation(_ location: CGPoint) -> CGFloat {
        let offset = CGPoint(x: location.x - view!.bounds.midX, y: location.y - view!.bounds.midY)
        return atan2(offset.y, offset.x)
    }
}




