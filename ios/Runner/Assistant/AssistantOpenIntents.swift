import AppIntents
import Foundation

struct OpenDmsIntent: AppIntent {
  static var title: LocalizedStringResource = "Open Direct Messages"
  static var description = IntentDescription("Open pirichat direct messages.")
  static var openAppWhenRun = true

  func perform() async throws -> some IntentResult {
    await AssistantCommandRunner.open(["type": "openDms"])
    return .result()
  }
}
