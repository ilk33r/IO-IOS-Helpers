//
//  IO_LeftMenuView.swift
//  IO Left Menu
//
//  Created by ilker özcan on 28/08/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//
//

import UIKit

public protocol IO_LeftMenuViewButtonsDelegate {

	func IO_LeftMenu(clickeMenudButton sender: UIButton!)
	func IO_LeftMenu(setMenuPosition currentFrameXDiff: CGFloat)
	func IO_LeftMenuToggle()
}

/// Left menu UIView
public class IO_LeftMenuView: UIView, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
	
	/// Table view
	@IBOutlet public weak var menuTableView: UITableView!
	
	internal var rowCount: NSNumber!
	internal var rowHeight: NSNumber!
	internal var gestureSensitive: NSNumber!
	internal var leftMenuOpenPosX: CGFloat!
	internal var rightDirection: Bool!
	internal var openPosX: CGFloat!
	
	/// Delegate
	public var delegate: IO_LeftMenuViewButtonsDelegate!
	
	private var swipeStartCoords: CGPoint = CGPointMake(0, 0)
	private var menuIsClosing = false
	private var currentNib: [AnyObject]!
	
	/// Drawing code
	override public func drawRect(rect: CGRect) {
		// Drawing code
		
		menuTableView.tableFooterView			= UIView(frame: CGRectZero)
		menuTableView.tableFooterView?.hidden	= true
		
		super.drawRect(rect)
	}
	
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

	public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		
		return true
	}
	
	public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		return true
	}

	public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return false
	}
	
	public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return false
	}
	
	@available(iOS 9.0, *)
	public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceivePress press: UIPress) -> Bool {
		
		return true
	}
	
	override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
		
		return true
	}
	
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 1
	}
	
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.rowCount.integerValue
	}

	public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		return CGFloat(self.rowHeight.floatValue)
	}
	
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cellId = "leftMenuBtn-\(indexPath.row + 1)"
		let currentButtonAction: Selector = "btnLeftMenuTapped"
		
		var tableViewCell: UITableViewCell!	= tableView.dequeueReusableCellWithIdentifier(cellId)
		
		if tableViewCell == nil {
			
			if(currentNib == nil) {
				
				currentNib	= NSBundle.mainBundle().loadNibNamed("IO_LeftMenuView", owner: nil, options: nil)
			}
			
			for object in currentNib {
				
				if let restId = object.restorationIdentifier {
					
					if restId == cellId {
						tableViewCell		= object as! UITableViewCell
						tableView.registerClass(object.classForCoder, forCellReuseIdentifier: cellId)
						
						if let leftMenuViewCell	= tableViewCell as? IO_LeftMenuTableViewCell
						{
							leftMenuViewCell.cellButton.addTarget(self, action: currentButtonAction, forControlEvents: UIControlEvents.TouchUpInside)
						}
						
					}
				}
			}
		}
		
		
		return tableViewCell
	}
	
	internal func btnLeftMenuTapped(sender: UIButton!) {
		
		if(delegate != nil) {
			
			delegate.IO_LeftMenu(clickeMenudButton: sender)
		}
	}
	
	@IBAction public func handlePan(sender: UIPanGestureRecognizer!) {
		
		if(menuIsClosing) {
			return
		}
		
		let coords		= sender.locationInView(sender.view)
		
		if(sender.state == UIGestureRecognizerState.Began) {
			
			swipeStartCoords		= coords
		}else if(sender.state == UIGestureRecognizerState.Changed) {
			
			let destinationX		= coords.x - swipeStartCoords.x
			let _sensitive			= CGFloat(self.gestureSensitive.floatValue)
			
			if(rightDirection!) {
				
				if((destinationX > 10.0) && ( destinationX > (1.0 * _sensitive) )) {
					
					if(destinationX + leftMenuOpenPosX < self.frame.origin.x) {
						
						if(delegate != nil) {
							
							self.delegate.IO_LeftMenu(setMenuPosition: destinationX)
						}
					}
				}else if(destinationX > (1.0 * _sensitive)) {
					
					menuIsClosing		= true
					
					if(delegate != nil) {
						delegate.IO_LeftMenuToggle()
					}
					
					let dispatchTime		= dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
					dispatch_after(dispatchTime, dispatch_get_main_queue(), { () -> Void in
						
						self.menuIsClosing			= false
					})
				}
				
			}else{
				if((destinationX < -10.0) && ( destinationX > (-1.0 * _sensitive) )) {
				
					if(destinationX + leftMenuOpenPosX < self.frame.origin.x) {
					
						if(delegate != nil) {
						
							self.delegate.IO_LeftMenu(setMenuPosition: destinationX)
						}
					}
				}else if(destinationX <= (-1.0 * _sensitive)) {
				
					menuIsClosing		= true
				
					if(delegate != nil) {
						delegate.IO_LeftMenuToggle()
					}
				
					let dispatchTime		= dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
					dispatch_after(dispatchTime, dispatch_get_main_queue(), { () -> Void in
					
						self.menuIsClosing			= false
					})
				}
			}
		}else if(sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Ended) {
			
			if(menuIsClosing) {
				return
			}else{
				let leftMenuOpenFrame = CGRectMake(leftMenuOpenPosX, 0, self.frame.size.width, self.frame.size.height)
				
				UIView.animateWithDuration(NSTimeInterval(0.6), animations: { () -> Void in
					
					self.frame = leftMenuOpenFrame
				})
			}
		}
	}
}
