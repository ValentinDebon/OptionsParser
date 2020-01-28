
public struct Option : Hashable, CustomStringConvertible {
	enum Variety {
		case specifier(() -> Void)
		case argument((String) -> Void)
	}

	public let identifier : String
	let variety : Variety

	public init(_ identifier: String, _ handler: @escaping () -> Void) {
		self.identifier = identifier
		self.variety = .specifier(handler)
	}

	public init(_ identifier: String, _ handler: @escaping (String) -> Void) {
		self.identifier = identifier
		self.variety = .argument(handler)
	}

	public var hasArgument : Bool {
		switch self.variety {
			case .specifier(_): return false
			case .argument(_): return true
		}
	}

	public var description : String {
		self.hasArgument ? "-\(self.identifier) <argument>" : "-\(self.identifier)"
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.identifier)
	}

	public static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.identifier == rhs.identifier
	}
}

