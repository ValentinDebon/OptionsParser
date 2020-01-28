# OptionsParser

Small Swift DSL to ease command line options parsing. Distributed under BSD-3, see `LICENSE`.

## Example

```swift
import OptionsParser

class Configuration {
	var a = false
	var output : String?
}

let configuration = Configuration()

let arguments = OptionsParser() {
	Option("a")      { configuration.a = true }
	Option("output") { configuration.output = $0 }
	Option("o")      { configuration.output = $0 }
}.parse()

print(arguments)

```

## Swift Package Manager

Just include the following line in your `Package.swift`:

```swift
.package(url: "https://github.com/ValentinDebon/OptionsParser.git", from: "0.0.1"),
```

Note that OptionsParser requires macOS 10.15 minimum to run, you may also need to add the following in `Package.swift`:
```swift
platforms: [ .macOS(.v10_15) ],
```
