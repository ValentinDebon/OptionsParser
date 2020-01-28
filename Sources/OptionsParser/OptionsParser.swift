
@_functionBuilder
public struct OptionsBuilder {
	public static func buildBlock(_ options: Option...) -> Set<Option> {
		Set(options)
	}
}

open class OptionsParser : Sequence {
	private let options : Dictionary<String, Option>

	public init(@OptionsBuilder options: () -> Set<Option>) {
		self.options = Dictionary(uniqueKeysWithValues: options().lazy.map { ($0.identifier, $0) })
	}

	public func optionRequiresArgument(option: String) {
		print("option requires argument -- \(option)")
	}

	public func illegalOption(option: String) {
		print("illegal option -- \(option)")
	}

	public func optionUnexpectedArgument(option: String) {
		print("option unexpected argument -- \(option)")
	}

	public final func parse() -> [String] {
		self.parse(from: CommandLine.arguments[1...])
	}

	private final func longOption<I>(_ optionWord: String, iterating iterator: inout I) -> Bool where I : IteratorProtocol, I.Element == String {
		var startIndex = optionWord.index(after: optionWord.startIndex)
		if optionWord[startIndex] == "-" {
			optionWord.formIndex(after: &startIndex)
		}
		let endIndex = optionWord.firstIndex(of: "=") ?? optionWord.endIndex

		let optionName = String(optionWord[startIndex..<endIndex])
		guard optionName.count > 1, let option = self.options[optionName] else {
			return false
		}

		switch option.variety {
		case .specifier(let handle):
			if endIndex != optionWord.endIndex {
				self.optionUnexpectedArgument(option: optionName)
			}
			handle()
		case .argument(let handle):
			if endIndex != optionWord.endIndex {
				handle(String(optionWord[(optionWord.index(after: endIndex))...]))
			} else {
				guard let optionArgument = iterator.next() else {
					self.optionRequiresArgument(option: optionName)
					break
				}

				handle(optionArgument)
			}
		}

		return true
	}

	private final func shortOption<I>(_ optionWord: String, iterating iterator: inout I) where I : IteratorProtocol, I.Element == String {
		var current = optionWord.index(after: optionWord.startIndex)

		while current != optionWord.endIndex {
			let optionName = String(optionWord[current])

			if let option = self.options[optionName] {
				switch option.variety {
				case .specifier(let handle):
					handle()
				case .argument(let handle):
					let nextIndex = optionWord.index(after: current)

					if nextIndex != optionWord.endIndex {
						handle(String(optionWord[nextIndex..<optionWord.endIndex]))
					} else {
						guard let optionArgument = iterator.next() else {
							self.optionRequiresArgument(option: optionName)
							break
						}

						handle(optionArgument)
					}

					current = optionWord.endIndex
					continue
				}
			} else {
				self.illegalOption(option: optionName)
			}

			optionWord.formIndex(after: &current)
		}
	}

	public final func parse<S>(from commandLine: S) -> [String] where S : Sequence, S.Element == String {
		var iterator = commandLine.makeIterator()
		var arguments : [String] = []

		while let optionWord = iterator.next() {
			guard optionWord.first == "-" && optionWord != "-" else {
				arguments.append(optionWord)
				break
			}

			guard optionWord != "--" else {
				break
			}

			if !self.longOption(optionWord, iterating: &iterator) {
				self.shortOption(optionWord, iterating: &iterator)
			}
		}

		while let argument = iterator.next() {
			arguments.append(argument)
		}

		return arguments
	}

	public final func makeIterator() -> some IteratorProtocol {
		self.options.values.makeIterator()
	}
}

