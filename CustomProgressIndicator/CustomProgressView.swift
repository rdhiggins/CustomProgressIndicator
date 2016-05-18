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
            
            self.circlePathLayer.strokeEnd = progress
        }
    }
    
    @IBInspectable var color: UIColor? {
        didSet {
            circlePathLayer.strokeColor = color?.CGColor

            endCapLayer.strokeColor = color?.CGColor
            endCapLayer.fillColor = color?.CGColor
            maskLayer.strokeColor = color?.CGColor
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            circlePathLayer.lineWidth = lineWidth
            endCapLayer.path = endCapPath().CGPath
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupShapeLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupShapeLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circlePathLayer.frame = circleRect()
        circlePathLayer.path = circlePath().CGPath

        endCapLayer.frame = circleRect()
        endCapLayer.path = endCapPath().CGPath
    }

    private func setupShapeLayer() {
        let rect = circleRect()
        circlePathLayer.frame = rect
        circlePathLayer.lineWidth = lineWidth
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = color?.CGColor
        circlePathLayer.lineCap = kCALineCapRound
        layer.addSublayer(circlePathLayer)

        endCapLayer.frame = rect
        endCapLayer.lineWidth = lineWidth
        endCapLayer.fillColor = color?.CGColor
        endCapLayer.strokeColor = color?.CGColor
        endCapLayer.path = endCapPath().CGPath

        endCapLayer.shadowColor = UIColor.blackColor().CGColor
        endCapLayer.shadowRadius = 20.0
        endCapLayer.shadowOpacity = 1.0
        endCapLayer.transform = CATransform3DRotate(endCapLayer.transform, CGFloat(M_PI_2), 0.0, 0.0, 1.0)
        layer.addSublayer(endCapLayer)

    }
    
    
    private func circleRect() -> CGRect {
        let radius = min(bounds.width / 2, bounds.height / 2)

        let frame = CGRect(origin: self.center, size: CGSizeZero)

        return CGRectInset(frame, -radius, -radius)
    }

    private func circleRadius() -> CGFloat {
        let rect = circleRect()

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
        let center = circleCenter()
        let topCenter = CGPointMake(center.x, center.y - circleRadius())

        var rect = CGRect(origin: topCenter, size: CGSizeZero)
        rect = CGRectInset(rect, -lineWidth / 2, -lineWidth / 2)

        return UIBezierPath(ovalInRect: rect)
    }
}


private class CustomShapeLayer: CAShapeLayer {
    
    private override func actionForKey(event: String) -> CAAction? {
        if event == "strokeEnd" {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name:  kCAMediaTimingFunctionEaseInEaseOut)
            
            return animation
        } else {
            return super.actionForKey(event)
        }
    }
}
