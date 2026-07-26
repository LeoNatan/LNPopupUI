//
//  PopupBarLayoutObserver.swift
//  LNPopupUI
//
//  Created by Léo Natan on 26/7/26.
//

protocol PopupBarLayoutObserver {
	var identifier: String { get }
	func apply(_ layoutProxy: PopupBarLayoutProxy)
	func transferOwnership(to nextObserver: PopupBarLayoutObserver)
}

class TypedPopupBarLayoutObserver<T: Equatable & Sendable>: PopupBarLayoutObserver {
	let identifier: String
	let transformer: @Sendable (PopupBarLayoutProxy) -> T
	let action: ((T) -> Void)?
	let oldNewAction: ((T?, T) -> Void)?
	
	var previousProxy: PopupBarLayoutProxy?
	var previousTransformedValue: T?
	
	init(identifier: String,
		 transformer: @escaping @Sendable (PopupBarLayoutProxy) -> T,
		 action: @escaping (T) -> Void) {
		self.identifier = identifier
		self.transformer = transformer
		self.action = action
		oldNewAction = nil
	}
	
	init(identifier: String,
		 transformer: @escaping @Sendable (PopupBarLayoutProxy) -> T,
		 oldNewAction: @escaping (T?, T) -> Void) {
		self.identifier = identifier
		self.transformer = transformer
		self.oldNewAction = oldNewAction
		action = nil
	}
	
	func apply(_ layoutProxy: PopupBarLayoutProxy) {
		guard previousProxy != layoutProxy else {
			return
		}
		
		previousProxy = layoutProxy
	
		let newValue = transformer(layoutProxy)
		
		if let previousTransformedValue, previousTransformedValue == newValue {
			return
		}
		
		oldNewAction?(previousTransformedValue, newValue)
		self.previousTransformedValue = newValue
		action?(newValue)
	}
	
	func transferOwnership(to nextObserver: PopupBarLayoutObserver) {
		guard let nextObserver = nextObserver as? TypedPopupBarLayoutObserver<T> else {
			return
		}
		
		nextObserver.previousProxy = previousProxy
		nextObserver.previousTransformedValue = previousTransformedValue
	}
}
