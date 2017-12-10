@_exported import Vapor

extension Droplet {
	public func setup() throws {
		droplet = self
		// set up models
		setupSeedableModels()
		try setupRoutes()
	}
	
	private func setupSeedableModels() {
		User.database = database
		Verification.database = database
		MeetupType.database = database
		Meetup.database = database
		Invitation.database = database
		Friend.database = database
    FriendRequest.database = database
	}
}
