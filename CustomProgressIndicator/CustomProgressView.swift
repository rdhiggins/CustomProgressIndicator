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
            circlePathLayer.strokeColor = color?.CGColor
            endCapLayer.fillColor = color?.CGColor
            startCapLayer.fillColor = color?.CGColor
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            circlePathLayer.lineWidth = lineWidth
            endCapLayer.path = endCapPath().CGPath
            startCapLayer.path = endCapPath().CGPath
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 10 {
        didSet {
            endCapLayer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSizeZero {
        didSet {
            endCapLayer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            endCapLayer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowColor: UIColor? {
        didSet {
            endCapLayer.shadowColor = shadowColor?.CGColor
        }
    }
    
    @IBInspectable var rotationDuration: Float = 0.5 {
        didSet {
//            endCapLayer.rotationDuration = rotationDuration
//            circlePathLayer.rotationDuration = rotationDuration
        }
    }
        
    private let circlePathLayer = CAShapeLayer()
    private let endCapLayer = CAShapeLayer()
    private let startCapLayer = CAShapeLayer()
    
    private var oldAngle: CGFloat = 0
    private var oldProgress: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        circlePathLayer.strokeEnd = 0.0
        setupShapeLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        circlePathLayer.strokeEnd = 0.0
        setupShapeLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = circleFrame()
        reframeLayers(rect)
    }

    private func updateLayerProgress() {
        var fromStroke: CGFloat
        var toStroke: CGFloat
        var fromAngle: CGFloat
        var toAngle: CGFloat
        
        fromStroke = circlePathLayer.strokeEnd

        if progress > 1.0 {
            toStroke = 1.0
            circlePathLayer.strokeEnd = 1.0
        } else {
            toStroke = progress
            circlePathLayer.strokeEnd = progress
        }

        fromAngle = oldAngle

        let delta: CGFloat = CGFloat(M_PI * 2.0) * progress - oldAngle
        let rotate = CATransform3DRotate(endCapLayer.transform, delta, 0, 0, 1)
        toAngle = oldAngle + delta

        
        endCapLayer.transform = rotate

        endCapLayer.addAnimation(endCapAnimation(fromAngle, toAngle: toAngle), forKey: "transform.rotation.z")
        circlePathLayer.addAnimation(circleAnimation(fromStroke, toStroke: toStroke, fromAngle: fromAngle, toAngle: toAngle), forKey: "strokeEnd")
        
        oldAngle = toAngle
    }
        
    private func setupShapeLayers() {
        let frame = circleFrame()

        setupShapeLayer(startCapLayer, frame: frame)

        setupShapeLayer(circlePathLayer, frame: frame)
        circlePathLayer.lineWidth = lineWidth

        setupShapeLayer(endCapLayer, frame: frame)
        endCapLayer.shadowColor = UIColor.blackColor().CGColor
        endCapLayer.shadowRadius = lineWidth
        endCapLayer.shadowOpacity = 0.6
        endCapLayer.shadowOffset = CGSizeMake(lineWidth, 0)
    }


    private func setupShapeLayer(shapeLayer: CAShapeLayer, frame: CGRect) {
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = color?.CGColor

        layer.addSublayer(shapeLayer)
    }

    private func reframeLayers(frame: CGRect) {
        reframeLayer(startCapLayer, frame: frame)
        startCapLayer.path = endCapPath().CGPath

        reframeLayer(circlePathLayer, frame: frame)
        circlePathLayer.path = circlePath().CGPath

        reframeLayer(endCapLayer, frame: frame)
        endCapLayer.path = endCapPath().CGPath
    }

    private func reframeLayer(layer: CAShapeLayer, frame: CGRect) {
        layer.bounds = CGRect(origin: CGPointZero, size: frame.size)
        layer.position = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
    }
    
    private func circleFrame() -> CGRect {
        let radius = min(bounds.width / 2, bounds.height / 2)
        let frame = CGRect(origin: CGPointMake(bounds.width / 2, bounds.height / 2), size: CGSizeZero)

        return CGRectInset(frame, -radius, -radius)
    }
    
    private func circleRadius() -> CGFloat {
        let rect = circleFrame()

        return min(rect.width, rect.height) / 2.0 - lineWidth
    }

    private func circleCenter() -> CGPoint {
        let radius = circleRadius() + lineWidth
        return CGPointMake(radius, radius)
    }
    
    private func circlePath() -> UIBezierPath {
        let topAngle: CGFloat = CGFloat(-M_PI_2)
        let endAngle: CGFloat = CGFloat(2 * M_PI - M_PI_2)
        let path = UIBezierPath(arcCenter: circleCenter(), radius: circleRadius(), startAngle: topAngle, endAngle: endAngle, clockwise: true)
        
        return path
    }

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



