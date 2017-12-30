import FluentProvider
import PostgreSQLProvider
import SendGridProvider

extension Config {
	public func setup() throws {
		// allow fuzzy conversions for these types
		// (add your own types here)
		Node.fuzzy = [Row.self, JSON.self, Node.self]

		try setupProviders()
		try setupPreparations()
		setupConfigurable()
	}
	
	private func setupConfigurable() {
		addConfigurable(command: SeedCommand.init, name: "seed")
    addConfigurable(command: DropCommand.init, name: "drop")
	}
	
	/// Configure providers
	private func setupProviders() throws {
		try addProvider(FluentProvider.Provider.self)
		try addProvider(PostgreSQLProvider.Provider.self)
    try addProvider(SendGridProvider.Provider.self)
	}
	
	/// Add all models that should have their
	/// schemas prepared before the app boots
	private func setupPreparations() throws {
		preparations.append(User.self)
		preparations.append(Verification.self)
		preparations.append(MeetupType.self)
		preparations.append(Meetup.self)
		preparations.append(Invitation.self)
		preparations.append(FriendRequest.self)
    preparations.append(Friend.self)
    preparations.append(NotificationManager.self)
    preparations.append(UpdateMigration.self)
	}
}
