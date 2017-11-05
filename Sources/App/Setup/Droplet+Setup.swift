@_exported import Vapor

extension Droplet {
	public func setup() throws {
		droplet = self
		// set up models
		setupSeedableModels()
		// Do any additional droplet setup
		try collection(V1Collection.self)
	}
	
	private func setupRoutes() {
		
	}
	
	private func setupSeedableModels() {
		User.database = database
		Verification.database = database
		MeetupType.database = database
		Meetup.database = database
		Invitation.database = database
		Friend.database = database
	}
}
