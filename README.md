# Banimark Test

The test and showcase app for the **Banimark Flutter SDK** (`banimark_flutter`).
Every way to put the Banimark chat in an app, each screen with a **Code** button
(top right) that shows the exact snippet to copy.

It points at the live desk on **https://banimark.com** by default.

## Run it

```bash
cd ~/Documents/android_flutter_app/banimark_test
flutter pub get
flutter run                 # picks a connected phone / emulator
flutter run -d macos        # or on this Mac
```

Web (`-d chrome`) is not a target: a browser blocks the app's calls to another
site (CORS), and the website has its own widget anyway.

The SDK comes from this Mac (`path: ../../android_app/banimark_flutter` in
`pubspec.yaml`), so a change to the SDK shows up here on the next hot restart.
Customers use `banimark_flutter: ^0.2.0` from pub.dev instead.

## What's inside

| Screen | Shows |
|---|---|
| **Server** (the card on top) | Which desk (Laravel or standalone), who the app is (guest, name/email, signed token), "bubble on every screen", and **Save & check**: is the desk reachable, activated, and which newer features it speaks |
| Full screen | `BanimarkChat` as a page - its own header, or inside your AppBar |
| Bottom sheet | The usual "Support" button that slides the chat up |
| Floating bubble | `BanimarkLauncher`: start corner, size, the ×, comes-back time, unread polling, your own bubble - then a shop screen to try it on |
| In a tab | A Support tab with an unread badge; one conversation across tabs |
| Theme playground | Light/dark/your app's colours, accent, corners, spacing, every text, header/emoji/files/guest form - live, and the Code button writes the matching code |
| Custom message bubbles | `bubbleBuilder` - messenger-style bubbles with names and times |
| Your own chat UI | `BanimarkController` only: build any UI on top |
| Who is chatting | Guest vs known visitor vs signed-in user (token), each with its own conversation |
| Events and links | `onStaffMessage` and `onOpenLink`, with a live event log |
| Conversation tools | Send from code, mark read, forget on logout, delete the conversation |

## Testing tips

- **Unread count / badge:** open a chat, send a message, close it. In the
  desk's inbox (banimark.com/banimark/admin) take the conversation over and
  reply - the bubble or tab shows the count. Set "Check while closed every" to
  10 s on the Floating bubble screen so you do not wait.
- **The ×:** pick "1 minute (to test)" for "Comes back after".
- **Start over:** Server -> "Forget everything on this device".
- Features that need the desk on **0.30.10+** (unread polling setting, the
  "comes back after" setting, deleting a conversation): the Server check says
  whether banimark.com has them yet.

## Tests

```bash
flutter analyze
flutter test      # opens every demo on a phone-sized screen, and both bubble set-ups
```
