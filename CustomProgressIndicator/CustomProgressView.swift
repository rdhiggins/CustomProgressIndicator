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
            } else if progress > 1.0 {
                progress = 1.0
            }
            
            updateLayerProgress()
        }
    }
    
    @IBInspectable var color: UIColor? {
        didSet {
            circlePathLayer.strokeColor = color?.CGColor

            endCapLayer.strokeColor = color?.CGColor
            endCapLayer.fillColor = color?.CGColor
            startCapLayer.strokeColor = color?.CGColor
            startCapLayer.fillColor = color?.CGColor
            maskLayer.strokeColor = color?.CGColor
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
            circlePathLayer.shadowRadius = shadowRadius
        }
    }
        
    private let circlePathLayer = CustomShapeLayer()
    private let endCapLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    private let startCapLayer = CAShapeLayer()
    
    private var oldAngle: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupShapeLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupShapeLayers()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
//        setupShapeLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = circleFrame()
        reframeLayers(rect)
    }

    private func updateLayerProgress() {
        circlePathLayer.strokeEnd = progress
        

        let angle: CGFloat = CGFloat(M_PI * 2.0) * progress
        
        let rotate = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        endCapLayer.transform = rotate
    }
        
    private func setupShapeLayers() {
        let frame = circleFrame()
        
        setupStartCapLayer(frame)
        setupCircleLayer(frame)
        setupEndCapLayer(frame)
        
        reframeLayers(frame)
    }
    
    private func setupCircleLayer(frame: CGRect) {
        setupShapeLayer(circlePathLayer, frame: frame)
//        circlePathLayer.lineCap = kCALineCapRound
        
        layer.addSublayer(circlePathLayer)
    }
    
    private func setupStartCapLayer(frame: CGRect) {
        setupShapeLayer(startCapLayer, frame: frame)
        
        layer.addSublayer(startCapLayer)
    }
    
    private func setupEndCapLayer(frame: CGRect) {
        setupShapeLayer(endCapLayer, frame: frame)
        
        endCapLayer.shadowColor = UIColor.blackColor().CGColor
        endCapLayer.shadowRadius = 20.0
        endCapLayer.shadowOpacity = 1.0
        
        layer.addSublayer(endCapLayer)
    }
    
    private func reframeLayers(frame: CGRect) {
        reframeStartCapLayer(frame)
        reframeCirclePathLayer(frame)
        reframeEndCapLayer(frame)
    }
    
    private func reframeStartCapLayer(frame: CGRect) {
        startCapLayer.bounds = CGRect(origin: CGPointZero, size: frame.size)
        startCapLayer.position = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        
        startCapLayer.path = endCapPath().CGPath
    }
    
    private func reframeCirclePathLayer(frame: CGRect) {
        circlePathLayer.bounds = CGRect(origin: CGPointZero, size: frame.size)
        circlePathLayer.position = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        
        circlePathLayer.path = circlePath().CGPath
    }
    
    private func reframeEndCapLayer(frame: CGRect) {
        endCapLayer.bounds = CGRect(origin: CGPointZero, size: frame.size)
        endCapLayer.position = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        
        endCapLayer.path = endCapPath().CGPath
    }
    
    private func setupShapeLayer(shapeLayer: CAShapeLayer, frame: CGRect) {
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = color?.CGColor
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


private class CustomShapeLayer: CAShapeLayer {
    
    private override func actionForKey(event: String) -> CAAction? {
//        if event == "strokeEnd" {
//            let animation = CABasicAnimation(keyPath: event)
//            animation.duration = 1.0
//            animation.timingFunction = CAMediaTimingFunction(name:  kCAMediaTimingFunctionEaseInEaseOut)
//            
//            return animation
//        } else {
            return super.actionForKey(event)
//        }
    }
}
