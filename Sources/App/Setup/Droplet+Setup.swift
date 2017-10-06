@_exported import Vapor

extension Droplet {
	public func setup() throws {
		// Do any additional droplet setup
		try collection(V1Collection.self)
	}
}
