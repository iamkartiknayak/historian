# Historian - A Clipboard Manager For Linux

**Historian** is a clipboard manager designed for Linux, built with Flutter. It provides an intuitive user interface and powerful features to manage clipboard history efficiently.

## Installation

#### Clone the repository using the following command:

```bash
git clone https://github.com/iamkartiknayak/Flutter_Historian.git
```

#### Rename the project directory before running flutter commands

```bash
mv Flutter_Historian historian
```

#### Navigate to the project directory:

```bash
cd historian
```

```bash
flutter pub get
```

#### Run the application:

```bash
flutter run
```

## Features Working on
- [ ] **Native Text Clipboard Listener**: Replace dart clipboard listener with `wl-clipboard-rs` & `x11-clipboard`. [`BUG`: Dart clipboard listener doesn't work in wayland unless app is focused right after copy].
- [ ] **Image support**: Support for images.
- [ ] **Code Highlighting**: Supports syntax highlighting for code snippets.
- [ ] **GIF**: Support for GIF, Search & copy GIF to clipboard to be pasted in supported docx.
- [ ] **Filters**: Dynamic filters appear at the top based on copied content types, such as text, images, code or GIFs.

## Features Developed
### 1. Clipboard Tab

- [X] **Clipboard History**: Displays a list of items copied to the clipboard.
- [X] **Quick Copy**: Clicking on an item instantly copies it to the clipboard.
- [X] **Pin/Unpin Items**: Pin important items to prevent them from being cleared.
- [X] **Delete & Undo**: Remove items with the option to undo.
- [X] **Clear Clipboard**: Remove all unpinned items.
- [X] **Web Search**: Copied links will be auto detected & can be launched directly.

- [X] **Keyboard Shortcuts**:
  - `arrow-up /-down`: Navigate through clipboard items. Selected item is highlighted.
  - `Ctrl+C`: Copies the currently selected item to the clipboard.
  - `Ctrl+D`: Deletes the currently selected item.
  - ~~`Ctrl+S`: Saves the currently selected image item~~.
  - `Ctrl+P`: Toggles the pin status of the selected item.
  - `Ctrl+U`: Undoes the last delete action, restoring the most recently deleted item.
  - `Ctrl+L`: Clear all unpinned items in clipboard.

### 2. Emoji Tab

- [X] **Category Tabbar**: Browse emojis by category, with options for search and recents.
- [X] **Searchbar**: Search for the required emoji using the searchbar at the top.
- [X] **Quick Copy**: Clicking on an emoji copies it to the clipboard.
- [X] **Keyboard Shortcut**:
  - `Ctrl+S`: Toggles the visibility of the searchbar.

### 3. Emoticon Tab

- [X] **Searchbar**: Search for the required emoticon using the searchbar at the top.
- [X] **Quick Copy**: Clicking on an emoticon copies it to the clipboard.
- [X] **Keyboard Shortcut**:
  - `Ctrl+S`: Toggles the visibility of the searchbar.

## Settings

Access the settings page through the settings button, offering various customization and control options:

- **Clipboard Settings**:

  - [X] Enable or disable clipboard monitoring (pause & resume).
  - [X] Adjust clipboard size (5-30) for optimized memory usage.

- **Emojis & Emoticons**:

  - [X] Clear recents in Emoji & Emoticon
  - [X] Emoji Skin Tone

- **Personalization Settings**:
  - [X] Customize the app theme color.
  - [X] Modify border radius for UI components.
  - [X] Enable accent colors on the app background with custom values for a personalized experience.

All configurations are saved and automatically loaded on the next app launch.

## App Tray

Historian app continue running in the bg while showing a tray icon for quick access and controls:

- [X] **Show/Hide Window**: Easily toggle the app window visibility.
- [X] **Pause/Resume Clipboard**: Enable or disable clipboard monitoring directly from the tray.
- [X] **Status Indicator**: The tray icon changes to indicate whether clipboard is listening or paused.

## Screenshots
<img src="./screenshots/0.png" alt="Example Image" width="250">&nbsp;&nbsp;&nbsp;
<img src="./screenshots/1.png" alt="Example Image" width="250">&nbsp;&nbsp;&nbsp;
<img src="./screenshots/2.png" alt="Example Image" width="250">&nbsp;&nbsp;&nbsp;
<img src="./screenshots/3.png" alt="Example Image" width="250"><br><br>


### License

This project is licensed under the GPL3 License.

### Acknowledgements

The development of this app was made possible by the Flutter community's extensive resources. Special thanks to all those who contribute to the Flutter framework and its ecosystem.

Stay healthy and enjoy using the Historian app!
