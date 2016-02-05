//
//  IO_NavigationControllerWithMenu.swift
//  IO Left Menu
//
//  Created by ilker özcan on 28/08/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//
//

import UIKit
import Foundation

private struct AnimationViewObject {
    
    var view: UIView!
    var defaultFrame: CGRect!
    var openedFrame: CGRect!
}

/// Navigation controller with menu
public class IO_NavigationControllerWithMenu: UINavigationController, IO_LeftMenuViewButtonsDelegate  {
	
	/// Menu open position x value
	public var leftMenuOpenPosX: CGFloat!
	
	/// Is menu view loaded ?
	public var isMenuViewLoaded = false
	
	/// Is menu open ?
	public var leftMenuOpenStatus = false
	
	private var leftMenuSize: CGSize!
	private var leftMenuView: IO_LeftMenuView!
	private var allAnimationViews: [AnimationViewObject]!
	private var leftMenuClosePositionX: CGFloat!
	private var leftMenuRightDirection: Bool!
	
	/// Load menu view
	public func loadLeftMenu(rowCount: Int, rowHeight: CGFloat = 54, directionIsRight: Bool = false, gestureSensitive: CGFloat = 30) {
		
		if(isMenuViewLoaded) {
			return
		}
		
		let leftMenuNibs = NSBundle.mainBundle().loadNibNamed("IO_LeftMenuView", owner: self, options: nil)
        
		if(leftMenuNibs.count > 0) {
			
			for nibObject in leftMenuNibs {
				
				if let restId = nibObject.restorationIdentifier {
					
					if restId == "LeftMenuView" {
						leftMenuView = nibObject as! IO_LeftMenuView
						break
					}
				}
			}
            
            if leftMenuView != nil {
				
				leftMenuView.delegate = self
				leftMenuView.menuDirectionIsRight = directionIsRight
				leftMenuView.gestureSensitive = gestureSensitive
				leftMenuView.rowCount = rowCount
				leftMenuView.rowHeight = rowHeight
				
				self.view.addSubview(leftMenuView)
                leftMenuSize = CGSizeMake((self.view.frame.width * CGFloat(2.0 / 3.0)), UIScreen.mainScreen().bounds.height)
				
				if(directionIsRight) {

					leftMenuClosePositionX = UIScreen.mainScreen().bounds.width
					leftMenuOpenPosX = leftMenuClosePositionX - leftMenuSize.width
					leftMenuView.leftMenuOpenPosX = leftMenuOpenPosX
					leftMenuView.frame = CGRectMake(leftMenuClosePositionX, 0, leftMenuSize.width, leftMenuSize.height)
				}else{
					leftMenuClosePositionX = (-1.0 * leftMenuSize.width)
					leftMenuOpenPosX = 0
					leftMenuView.leftMenuOpenPosX = leftMenuOpenPosX
					leftMenuView.frame = CGRectMake(leftMenuClosePositionX, 0, leftMenuSize.width, leftMenuSize.height)
				}
				
                leftMenuView.layoutIfNeeded()
                leftMenuView.hidden = true
				
				self.leftMenuRightDirection = directionIsRight
            }
        }
        
        isMenuViewLoaded = true
    }
	
	/// Open or close menu
    public func IO_LeftMenuToggle() {
		
        if(self.leftMenuView == nil) {
            #if DEBUG
                print("Warning: Left menu not implemented !")
            #endif
            return
        }
        
        if leftMenuOpenStatus {
			
            let leftMenuCloseFrame = CGRectMake(leftMenuClosePositionX, 0, leftMenuSize.width, leftMenuSize.height)
            leftMenuOpenStatus = false
            
            UIView.animateWithDuration(NSTimeInterval(0.4), animations: { () -> Void in
                
                for animationViewDict in self.allAnimationViews {
                    
                    animationViewDict.view.frame = animationViewDict.defaultFrame
                }
                
                self.leftMenuView.frame = leftMenuCloseFrame
                
                }, completion: { (isComplete) -> Void in
					
                    if(isComplete) {
                        self.leftMenuView.hidden = true
                        self.view.layoutSubviews()
                        self.allAnimationViews = nil
                    }
            })
            
            
        }else{
            
            allAnimationViews = [AnimationViewObject]()
            
            for animationView in self.getCurrentViews() {
				
				let openedFrameRect: CGRect
				if(leftMenuRightDirection!) {
					let frameXPos = CGFloat(-1 * leftMenuSize.width);
					openedFrameRect = CGRectMake(frameXPos, animationView.frame.origin.y, animationView.frame.width, animationView.frame.height)
				}else{
					openedFrameRect = CGRectMake(leftMenuSize.width, animationView.frame.origin.y, animationView.frame.width, animationView.frame.height)
				}
                let animationViewObject = AnimationViewObject(view: animationView, defaultFrame: animationView.frame, openedFrame: openedFrameRect)
                allAnimationViews.append(animationViewObject)
            }
            
			let leftMenuOpenFrame = CGRectMake(leftMenuOpenPosX, 0, leftMenuSize.width, leftMenuSize.height)
            leftMenuOpenStatus = true
            leftMenuView.hidden = false
            UIView.animateWithDuration(NSTimeInterval(0.4), animations: { () -> Void in
                
                for animationViewDict in self.allAnimationViews {
                    
                    animationViewDict.view.frame = animationViewDict.openedFrame
                }
                self.leftMenuView.frame = leftMenuOpenFrame
                
                }, completion: { (isComplete) -> Void in
                    if(isComplete) {
                        UIApplication.sharedApplication().keyWindow?.bringSubviewToFront(self.leftMenuView)
                        self.view.layoutSubviews()
                    }
            })
        }
    }
	
	/// Force close menu
	public func closeLeftMenuImmediately() {
		
		if(self.leftMenuView == nil) {
			#if DEBUG
				print("Warning: Left menu not implemented !")
			#endif
			return
		}
		
		if leftMenuOpenStatus {
			
			let leftMenuCloseFrame = CGRectMake(leftMenuClosePositionX, 0, leftMenuSize.width, leftMenuSize.height)
			leftMenuOpenStatus = false
			
			UIView.animateWithDuration(NSTimeInterval(0.2), animations: { () -> Void in
				
				for animationViewDict in self.allAnimationViews {
					
					animationViewDict.view.frame = animationViewDict.defaultFrame
				}
				
				self.leftMenuView.frame		= leftMenuCloseFrame
				
				}, completion: { (isComplete) -> Void in
					if(isComplete) {
						self.leftMenuView.hidden = true
						self.view.layoutSubviews()
						self.allAnimationViews = nil
					}
			})
		}
	}
	
	/// Change menu position
	public func IO_LeftMenu(setMenuPosition currentFrameXDiff: CGFloat) {
		
        for animationViewDict in self.allAnimationViews {
			
            animationViewDict.view.frame = CGRectMake(animationViewDict.openedFrame.origin.x + currentFrameXDiff, animationViewDict.openedFrame.origin.y, animationViewDict.openedFrame.width, animationViewDict.openedFrame.height)
        }

		let currentPosX = leftMenuOpenPosX + currentFrameXDiff
        self.leftMenuView.frame = CGRectMake(currentPosX, self.leftMenuView.frame.origin.y, self.leftMenuView.frame.width, self.leftMenuView.frame.height)
    }
	
    private func getCurrentViews() -> [UIView] {
		
        var returnValue = [UIView]()
        
        for currentView in self.view.subviews {
            
            if let restId = (currentView).restorationIdentifier {
                
                if restId == "LeftMenuView" {
                    continue;
                }
            }
            
            returnValue.append(currentView )
        }
        
        return returnValue
    }
	
	/// Button click action
	public func IO_LeftMenu(clickeMenudButton sender: UIButton!) {
		fatalError("Method IO_LeftMenu(clickeMenudButton: )  must override")
	}
}
