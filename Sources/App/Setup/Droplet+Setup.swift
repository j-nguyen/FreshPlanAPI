@_exported import Vapor

// get a public var for us to use
public var droplet: Droplet?

extension Droplet {
	public func setup() throws {
		droplet = self
		// Do any additional droplet setup
		try collection(V1Collection.self)
	}
}
