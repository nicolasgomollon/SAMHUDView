//
//  SAMHUDView.swift
//  SAMHUDView
//
//  Objective-C code Copyright (c) 2009-2014 Sam Soffes. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

class SAMHUDWindowViewController: UIViewController {
	
	var statusBarStyle = UIApplication.sharedApplication().statusBarStyle
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle  {
		return statusBarStyle
	}
	
}

class SAMHUDWindow: UIWindow {
	
	var hidesVignette: Bool = false {
	didSet {
		userInteractionEnabled = !hidesVignette
		setNeedsDisplay()
	}
	}
	
	override init() {
		super.init(frame: UIScreen.mainScreen().bounds)
		initialize()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	private func initialize() {
		backgroundColor = .clearColor()
		windowLevel = UIWindowLevelStatusBar + 1.0
		rootViewController = SAMHUDWindowViewController()
	}
	
	override func drawRect(rect: CGRect) {
		if hidesVignette { return }
		let context = UIGraphicsGetCurrentContext()
		let blackTransparent = UIColor(white: 0.0, alpha: 0.1).CGColor
		let blackHalfAlpha = UIColor(white: 0.0, alpha: 0.5).CGColor
		let colors = [blackTransparent, blackHalfAlpha] as CFArrayRef
		let colorSpace = CGColorGetColorSpace(blackTransparent)
		let gradient = CGGradientCreateWithColors(colorSpace, colors, nil)
		let centerPoint = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0)
		let endRadius = max(bounds.size.width, bounds.size.height) / 2.0
		CGContextDrawRadialGradient(context, gradient, centerPoint, 0.0, centerPoint, endRadius, CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation))
	}
	
}

class SAMHUDView: UIView {
	
	let kIndicatorSize: CGFloat = 40.0
	
	var hudSize = CGSizeMake(172.0, 172.0)
	
	var successful = false
	var completeImage: UIImage? = UIImage(named: "SAMHUDView-Check")
	var failImage: UIImage? = UIImage(named: "SAMHUDView-Cross")
	
	var _textLabel: UILabel?
	var textLabel: UILabel {
		if let textLabel = _textLabel { return textLabel }
		_textLabel = UILabel()
		_textLabel!.font = .boldSystemFontOfSize(14.0)
		_textLabel!.backgroundColor = .clearColor()
		_textLabel!.textColor = .whiteColor()
		_textLabel!.shadowColor = UIColor(white: 0.0, alpha: 0.7)
		_textLabel!.shadowOffset = CGSizeMake(0.0, 1.0)
		_textLabel!.textAlignment = .Center
		_textLabel!.lineBreakMode = .ByTruncatingTail
		return _textLabel!
	}
	
	var _activityIndicator: UIActivityIndicatorView?
	var activityIndicator: UIActivityIndicatorView {
		if let activityIndicator = _activityIndicator { return activityIndicator }
		_activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
		_activityIndicator!.alpha = 0.0
		return _activityIndicator!
	}
	
	var loading: Bool {
	didSet {
		activityIndicator.alpha = loading ? 1.0 : 0.0
		setNeedsDisplay()
	}
	}
	
	var _hudWindow: SAMHUDWindow?
	var hudWindow: SAMHUDWindow {
		if let hudWindow = _hudWindow { return hudWindow }
		_hudWindow = SAMHUDWindow()
		return _hudWindow!
	}
	
	var hidesVignette: Bool {
	get {
		return hudWindow.hidesVignette
	}
	set {
		hudWindow.hidesVignette = newValue
	}
	}
	
	var keyWindow: UIWindow! {
		let application = UIApplication.sharedApplication()
		let delegate = application.delegate
		if let window = delegate?.window {
			return window
		}
		// Unable to get main window from app delegate
		return application.keyWindow
	}
	
	class var sharedHUD: SAMHUDView {
		struct Singleton {
			static let sharedInstance = SAMHUDView()
		}
		return Singleton.sharedInstance
	}
	
	init(title: String?, loading: Bool) {
		self.loading = loading
		
		super.init(frame: CGRectZero)
		backgroundColor = .clearColor()
		
		activityIndicator.startAnimating()
		addSubview(activityIndicator)
		
		if let title = title {
			textLabel.text = title
		} else {
			textLabel.text = NSLocalizedString("Loading…", comment: "")
		}
		addSubview(textLabel)
		
		setTransformForCurrentOrientation(false)
	}
	
	convenience init(title: String?) {
		self.init(title: title, loading: true)
	}
	
	convenience override init() {
		self.init(title: nil, loading: true)
	}
	
	required init(coder aDecoder: NSCoder) {
		loading = true
		super.init(coder: aDecoder)
	}
	
	func show(#title: String?) {
		show(title: title, loading: true)
	}
	
	func show(#title: String?, loading: Bool) {
		if let title = title {
			textLabel.text = title
		} else {
			textLabel.text = NSLocalizedString("Loading…", comment: "")
		}
		self.loading = loading
		show()
	}
	
	func show() {
		let viewController = hudWindow.rootViewController as SAMHUDWindowViewController
		viewController.statusBarStyle = UIApplication.sharedApplication().statusBarStyle
		
		hudWindow.alpha = 0.0
		alpha = 0.0
		hudWindow.addSubview(self)
		hudWindow.makeKeyAndVisible()
		
		UIView.beginAnimations("SAMHUDViewFadeInWindow", context: nil)
		hudWindow.alpha = 1.0
		UIView.commitAnimations()
		
		let windowSize = hudWindow.frame.size
		var contentFrame = CGRectMake(round((windowSize.width - hudSize.width) / 2.0), round((windowSize.height - hudSize.height) / 2.0) + 10.0, hudSize.width, hudSize.height)
		
		let offset: CGFloat = 20.0
		if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
			contentFrame.origin.y += offset
		} else {
			contentFrame.origin.x += offset
		}
		frame = contentFrame
		
		UIView.beginAnimations("SAMHUDViewFadeInContentAlpha", context: nil)
		UIView.setAnimationDelay(0.1)
		UIView.setAnimationDuration(0.3)
		alpha = 1.0
		UIView.commitAnimations()
		
		UIView.beginAnimations("SAMHUDViewFadeInContentFrame", context: nil)
		UIView.setAnimationDelay(0.1)
		UIView.setAnimationDuration(0.3)
		frame = contentFrame
		UIView.commitAnimations()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
	}
	
	func complete() {
		complete(title: nil)
	}
	
	func complete(#title: String?) {
		successful = true
		loading = false
		if let title = title {
			textLabel.text = title
		}
		
		let delayInSeconds = 1.0
		let delta = Int64(delayInSeconds * Double(NSEC_PER_SEC))
		let popTime = dispatch_time(DISPATCH_TIME_NOW, delta)
		
		dispatch_after(popTime, dispatch_get_main_queue()) {
			self.dismiss()
		}
	}
	
	func fail() {
		fail(title: nil)
	}
	
	func fail(#title: String?) {
		successful = false
		loading = false
		if let title = title {
			textLabel.text = title
		}
		
		let delayInSeconds = 1.0
		let delta = Int64(delayInSeconds * Double(NSEC_PER_SEC))
		let popTime = dispatch_time(DISPATCH_TIME_NOW, delta)
		
		dispatch_after(popTime, dispatch_get_main_queue()) {
			self.dismiss()
		}
	}
	
	func dismiss() {
		dismiss(animated: true)
	}
	
	func dismiss(#animated: Bool) {
		if superview == nil { return }
		
		UIView.beginAnimations("SAMHUDViewFadeOutContentFrame", context: nil)
		UIView.setAnimationDuration(0.2)
		var contentFrame = frame
		let offset: CGFloat = 20.0
		if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
			contentFrame.origin.y += offset
		} else {
			contentFrame.origin.x += offset
		}
		frame = contentFrame
		UIView.commitAnimations()
		
		UIView.beginAnimations("SAMHUDViewFadeOutContentAlpha", context: nil)
		UIView.setAnimationDelay(0.1)
		UIView.setAnimationDuration(0.2)
		alpha = 0.0
		UIView.commitAnimations()
		
		UIView.beginAnimations("SAMHUDViewFadeOutWindow", context: nil)
		hudWindow.alpha = 0.0
		UIView.commitAnimations()
		
		if animated {
			let delayInSeconds = 0.3
			let delta = Int64(delayInSeconds * Double(NSEC_PER_SEC))
			let popTime = dispatch_time(DISPATCH_TIME_NOW, delta)
			
			dispatch_after(popTime, dispatch_get_main_queue()) {
				self.removeWindow()
			}
		} else {
			removeWindow()
		}
	}
	
}

// MARK: UIView
extension SAMHUDView {
	
	override func drawRect(rect: CGRect)  {
		let context = UIGraphicsGetCurrentContext()
		
		// Draw rounded rectangle
		CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.5)
		let roundedRect = CGRectMake(0.0, 0.0, hudSize.width, hudSize.height)
		UIBezierPath(roundedRect: roundedRect, cornerRadius: 14.0).fill()
		
		// Image
		if !loading {
			UIColor.whiteColor().set()
			if let image = successful ? completeImage : failImage {
				let imageSize = image.size
				let imageRect = CGRectMake(round((hudSize.width - imageSize.width) / 2.0), round((hudSize.height - imageSize.height) / 2.0), imageSize.width, imageSize.height)
				image.drawInRect(imageRect)
			} else {
				let dingbat = NSString(string: successful ? "✔︎" : "✘")
				
				let dingbatFont = UIFont.systemFontOfSize(70.0)
				let dingbatSize = dingbat.sizeWithAttributes([NSFontAttributeName: dingbatFont])
				let dingbatRect = CGRectMake(round((hudSize.width - dingbatSize.width) / 2.0), round((hudSize.height - dingbatSize.height) / 2.0), dingbatSize.width, dingbatSize.height)
				
				var style = NSMutableParagraphStyle()
				style.alignment = .Center
				style.lineBreakMode = .ByClipping
				
				dingbat.drawInRect(dingbatRect, withAttributes: [NSFontAttributeName: dingbatFont, NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: UIColor.whiteColor()])
			}
		}
	}
	
	override func layoutSubviews() {
		activityIndicator.frame = CGRectMake(round((hudSize.width - kIndicatorSize) / 2.0), round((hudSize.height - kIndicatorSize) / 2.0), kIndicatorSize, kIndicatorSize)
		if textLabel.hidden {
			textLabel.frame = CGRectZero
		} else {
			var style = NSMutableParagraphStyle()
			style.lineBreakMode = textLabel.lineBreakMode
			
			let text = textLabel.text ?? ""
			let textSize = NSString(string: text).boundingRectWithSize(CGSizeMake(bounds.size.width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: textLabel.font, NSParagraphStyleAttributeName: style], context: nil).size
			textLabel.frame = CGRectMake(0.0, round(hudSize.height - textSize.height - 10.0), hudSize.width, textSize.height)
		}
	}
	
}

// MARK: Private
private extension SAMHUDView {
	
	func setTransformForCurrentOrientation(animated: Bool) {
		var rotation: Double
		
		switch UIApplication.sharedApplication().statusBarOrientation {
		case .Portrait:
			rotation = 0.0
		case .LandscapeLeft:
			rotation = -M_PI_2
		case .LandscapeRight:
			rotation = M_PI_2
		case .PortraitUpsideDown:
			rotation = M_PI
		default:
			rotation = 0.0
		}
		
		let rotationTransform = CGAffineTransformMakeRotation(CGFloat(rotation))
		
		if animated {
			UIView.beginAnimations("SAMHUDViewRotationTransform", context: nil)
			UIView.setAnimationDuration(0.3)
		}
		
		transform = rotationTransform
		
		if animated {
			UIView.commitAnimations()
		}
	}
	
	func deviceOrientationChanged(notification: NSNotification) {
		setTransformForCurrentOrientation(true)
		setNeedsDisplay()
	}
	
	func removeWindow() {
		removeFromSuperview()
		hudWindow.resignKeyWindow()
		
		// Return focus to the main window
		keyWindow.makeKeyWindow()
		_hudWindow = nil
		
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
	}
	
}
