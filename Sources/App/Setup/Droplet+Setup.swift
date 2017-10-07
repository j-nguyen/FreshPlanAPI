@_exported import Vapor

extension Droplet {
	public func setup() throws {
		droplet = self
		// set up models
		setupSeedableModels()
		// Do any additional droplet setup
		try collection(V1Collection.self)
	}
	
	private func setupSeedableModels() {
		MeetupType.database = database
	}
}
