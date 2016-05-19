//
// CustomProgressView.swift
// MIT License
//
// Copyright (c) 2016 Spazstik Software, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

@IBDesignable
class CustomProgressView: UIView {
    
    
    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            if progress < 0.0 {
                progress = 0.0
            }
            
            updateLayerProgress()
        }
    }
    
    @IBInspectable var color: UIColor? {
        didSet {
            arcLayer.strokeColor = color?.CGColor
            endLayer.fillColor = color?.CGColor
            startLayer.fillColor = color?.CGColor
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            arcLayer.lineWidth = lineWidth
            endLayer.path = endCapPath().CGPath
            startLayer.path = endCapPath().CGPath
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 10 {
        didSet {
            endLayer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSizeZero {
        didSet {
            endLayer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            endLayer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowColor: UIColor? {
        didSet {
            endLayer.shadowColor = shadowColor?.CGColor
        }
    }
    
    @IBInspectable var rotationDuration: Float = 0.5
    
    
    
    
    private let arcLayer = CAShapeLayer()
    private let endLayer = CAShapeLayer()
    private let startLayer = CAShapeLayer()
    
    private var oldAngle: CGFloat = 0
    private var oldProgress: CGFloat = 0
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Make sure the initial value is 0
        arcLayer.strokeEnd = 0.0
        
        setupShapeLayers()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Make sure the initial value is 0
        arcLayer.strokeEnd = 0.0
        
        setupShapeLayers()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = circleFrame()
        reframeLayers(rect)
    }

    
    /// A private method that is called to perform the actual steps in updating
    /// the progress indicators.
    private func updateLayerProgress() {
        var fromStroke: CGFloat
        var toStroke: CGFloat
        var fromAngle: CGFloat
        var toAngle: CGFloat
        
        fromStroke = arcLayer.strokeEnd

        if progress > 1.0 {
            toStroke = 1.0
            arcLayer.strokeEnd = 1.0
        } else {
            toStroke = progress
            arcLayer.strokeEnd = progress
        }

        fromAngle = oldAngle

        let delta: CGFloat = CGFloat(M_PI * 2.0) * progress - oldAngle
        let rotate = CATransform3DRotate(endLayer.transform, delta, 0, 0, 1)
        toAngle = oldAngle + delta

        
        endLayer.transform = rotate

        endLayer.addAnimation(endCapAnimation(fromAngle, toAngle: toAngle), forKey: "transform.rotation.z")
        arcLayer.addAnimation(circleAnimation(fromStroke, toStroke: toStroke, fromAngle: fromAngle, toAngle: toAngle), forKey: "strokeEnd")
        
        oldAngle = toAngle
    }
    
    
    /// A utility used to setup the shapeLayers on initialization.   Each layer
    /// is initialized with the correct properties and loaded into view's
    /// CALayer hierarchy.
    private func setupShapeLayers() {
        let frame = circleFrame()

        setupShapeLayer(startLayer, frame: frame)

        setupShapeLayer(arcLayer, frame: frame)
        arcLayer.lineWidth = lineWidth

        setupShapeLayer(endLayer, frame: frame)
        endLayer.shadowColor = UIColor.blackColor().CGColor
        endLayer.shadowRadius = lineWidth
        endLayer.shadowOpacity = 0.6
        endLayer.shadowOffset = CGSizeMake(lineWidth, 0)
    }


    /// A utility method used to perform redundant setup steps for a CAShapeLayer.
    /// This method also adds the shape layer to the views layer.
    ///
    /// - parameter shapeLayer: A CAShapeLayer to initialize and add into the
    /// view's CALayer hiearchy
    /// - parameter frame: A CGRect that is the new frame to use
    private func setupShapeLayer(shapeLayer: CAShapeLayer, frame: CGRect) {
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = color?.CGColor

        layer.addSublayer(shapeLayer)
    }

    
    /// A utility called to update the CAShapeLayers when the view is laying
    /// out it's subviews.  Each layers frame property is updated and then
    /// a new CGPath is loaded into the layer.
    ///
    /// parameter frame: A CGRect that is the new frame to use for the views
    private func reframeLayers(frame: CGRect) {
        reframeLayer(startLayer, frame: frame)
        startLayer.path = endCapPath().CGPath

        reframeLayer(arcLayer, frame: frame)
        arcLayer.path = circlePath().CGPath

        reframeLayer(endLayer, frame: frame)
        endLayer.path = endCapPath().CGPath
    }

    
    /// A utility method used to properly update the frame for CAShapeLayer.
    private func reframeLayer(layer: CAShapeLayer, frame: CGRect) {
        layer.bounds = CGRect(origin: CGPointZero, size: frame.size)
        layer.position = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
    }

    
    /// A utility method that returns the frame to use for the shape layers that
    /// do all the work.  The frame is square with a width/height equal to
    /// one half the smallest dimension.
    ///
    /// - returns: A CGRect to use as the frame for a shape layer
    private func circleFrame() -> CGRect {
        let radius = min(bounds.width / 2, bounds.height / 2)
        let frame = CGRect(origin: CGPointMake(bounds.width / 2, bounds.height / 2), size: CGSizeZero)

        return CGRectInset(frame, -radius, -radius)
    }

    
    /// A utility method that returns the radius to use for the circle.  It
    /// assumes that the circle is being drawn with a stroke (no fill).  The
    /// circle is assumed to fill the entire views rect in the smallest
    /// direction.
    ///
    /// - returns: The radius to use.
    private func circleRadius() -> CGFloat {
        let rect = circleFrame()

        return min(rect.width, rect.height) / 2.0 - lineWidth
    }

    
    /// A utility method that returns the center of the circle.  This assumes
    /// that the view is square.
    ///
    /// - resturns: A CGPoint to use as the center point of the circle
    private func circleCenter() -> CGPoint {
        let radius = circleRadius() + lineWidth
        return CGPointMake(radius, radius)
    }


    /// A method for generating a UIBezierPath for the arc layer
    ///
    /// - returns: A UIBezierPath that is a arc that uses the current
    /// radius, and lineWidth.
    private func circlePath() -> UIBezierPath {
        let topAngle: CGFloat = CGFloat(-M_PI_2)
        let endAngle: CGFloat = CGFloat(2 * M_PI - M_PI_2)
        let path = UIBezierPath(arcCenter: circleCenter(), radius: circleRadius(), startAngle: topAngle, endAngle: endAngle, clockwise: true)
        
        return path
    }

    
    /// A method for generating a UIBezierPath for a end cap layer
    ///
    /// - returns: A UIBezierPath that is a end cap that uses the current
    /// radius, and lineWidth.
    private func endCapPath() -> UIBezierPath {
        let c = circleCenter()
        let capCenter = CGPointMake(c.x, c.y - circleRadius())

        var rect = CGRect(origin: capCenter, size: CGSizeZero)
        rect = CGRectInset(rect, -lineWidth / 2, -lineWidth / 2)
        
        return UIBezierPath(ovalInRect: rect)
    }
}




extension CustomProgressView {
    
    private func circleAnimation(fromStroke: CGFloat, toStroke: CGFloat, fromAngle: CGFloat, toAngle: CGFloat) -> CABasicAnimation {
        let ba = CABasicAnimation(keyPath: "strokeEnd")
        ba.fromValue = fromStroke
        ba.toValue = toStroke
        ba.duration = arcRotationDuration(fromStroke, toStroke: toStroke)
        ba.beginTime = arcBeginTime(fromStroke, toStroke: toStroke, fromAngle: fromAngle, toAngle: toAngle)
        ba.cumulative = false
        ba.removedOnCompletion = true
        ba.fillMode = kCAFillModeBackwards
        
        return ba
    }
    
    private func endCapAnimation(fromAngle: CGFloat, toAngle: CGFloat) -> CABasicAnimation {
        let ba = CABasicAnimation(keyPath: "transform.rotation.z")
        ba.fromValue = fromAngle
        ba.toValue = toAngle
        ba.duration = angleRotationDuration(fromAngle, toAngle: toAngle)
        ba.cumulative = false
        ba.removedOnCompletion = true
        ba.fillMode = kCAFillModeBackwards
        
        return ba
    }
    
    private func angleRotationDuration(fromAngle: CGFloat, toAngle: CGFloat) -> CFTimeInterval {
        let deltaAngle = abs(toAngle - fromAngle)
        let numberRotations = deltaAngle / CGFloat(2 * M_PI)
        let time = CGFloat(rotationDuration) * numberRotations
        
        return CFTimeInterval(time)
    }
    
    private func arcRotationDuration(fromStroke: CGFloat, toStroke: CGFloat) -> CFTimeInterval {
        let delta = abs(toStroke - fromStroke)
        let time = CGFloat(rotationDuration) * delta
        
        return CFTimeInterval(time)
    }
    
    private func arcBeginTime(fromStroke: CGFloat, toStroke: CGFloat, fromAngle: CGFloat, toAngle: CGFloat) -> CFTimeInterval {
        let delta = toStroke - fromStroke
        let time = CGFloat(rotationDuration) * abs(delta)
        
        // Positive delta means we are rotating clockwise so we
        // need to start right away
        if delta > 0.0 {
            return 0
        }
        
        // Rotating counter-clockwise, so we want to delay until
        // the end cap unwraps to the last loop
        let delay = angleRotationDuration(fromAngle, toAngle: toAngle) - CFTimeInterval(time)
        
        return CACurrentMediaTime() + delay
    }
    
}



