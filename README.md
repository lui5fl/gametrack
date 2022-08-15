# Gametrack
Gametrack is an iPhone app for tracking your progress in videogames. I've started this project with the sole purpose of learning SwiftUI: this means the app may never get finished.

## Screenshots
![screenshots](https://github.com/lui5fl/gametrack/blob/master/Screenshots.png)

## Before building the app
Follow the next steps to successfully build and run the app:

1. Go to the IGDB API Docs and do what the [Account Creation](https://api-docs.igdb.com/#account-creation) and [Authentication](https://api-docs.igdb.com/#authentication) sections say. Take note of your Client ID and your Access Token: ideally you'd input your Client Secret inside the app so it can automatically request a new Access Token every time it expires, but this hasn't been implemented yet
2. Open ```Gametrack.xcworkspace```
3. Create a ```Key.plist``` file in the root of the project and add two rows, "clientId" and "accessToken", whose values will respectively be your Client ID and your Access Token (to no one's surprise!)
4. You're all set!

## Dependencies (pods)
- [GRDB](https://cocoapods.org/pods/GRDB.swift): toolkit for SQLite databases
- [IGDB-SWIFT-API](https://github.com/husnjak/IGDB-API-SWIFT): wrapper for the [IGDB API](https://api.igdb.com)

## Shoutouts
- [Alfian Losari](https://twitter.com/alfianlosari) for making a great tutorial which I followed when I first started working on the app: [*Building SwiftUI Video Game DB App using IGDB Remote API*](https://medium.com/swift2go/building-swiftui-video-game-db-app-using-igdb-remote-api-alfian-losari-eb155a8ae3d0)
- [Joe Kimberlin-Wyer](https://twitter.com/joekw) for developing [GameTrack](https://apps.apple.com/us/app/gametrack/id1136800740?mt=8), a great app for managing your videogame collection which I encourage you to use instead of mine. I actually found out about his app through [a MacStories post](https://www.macstories.net/reviews/gametrack-review-an-elegant-way-to-discover-track-and-share-videogames) that popped up on my Twitter feed a few days after I started developing my own app!

## License
Released under AGPL-3.0 license. See [LICENSE](https://github.com/lui5fl/gametrack/blob/master/LICENSE) for details.
