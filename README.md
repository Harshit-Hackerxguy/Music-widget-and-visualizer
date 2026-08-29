# Quickshell Music Widget 🎵

A beautiful floating music player for Wayland built with [Quickshell](https://outfoxxed.me/quickshell/). It features an interactive music card that expands when you hover over it, and an aesthetic RGB bar floating downward visualizer that reacts to your computer's audio.

## ✨ Features

- **Expanding Music Card**: 
  - Starts as a small, clean pill shape showing basic play/pause status.
  - Hover over it, and it smoothly expands into a full music player with album art.
  - Automatically shrinks back down when you move your mouse away.
- **Media Controls**: 
  - Works with almost any music player (Spotify, Firefox, mpv, etc.).
  - Shows the song title, artist, and album picture.
  - You can play, pause, and skip tracks right from the widget.
- **Aesthetic RGB Visualizer**: 
  - An aesthetic RGB bar floating downward visualizer that bounces to the beat of your music.
  - Colors smoothly cycle through a beautiful rainbow glow.
  - You can click right through it, so it never blocks you from using your computer.

## 🛠️ Requirements

Make sure you have these installed on your system before you start:

- [Quickshell](https://outfoxxed.me/quickshell/) (and Qt6/QML dependencies)
- [CAVA](https://github.com/karlstav/cava) (This is the program that reads the audio for the visualizer)
- A Wayland compositor (like Hyprland, Sway, or Wayfire)

## 🚀 Installation & Usage

1. Download this code to your computer:
   ```bash
   git clone https://github.com/yourusername/quickshell-music-widget.git
   cd quickshell-music-widget
   ```

2. Run the widget using Quickshell:
   ```bash
   quickshell -c shell.qml (If this is not working, then write complete path of the file)
   // OR
   qs -c ~/home/music-widget/shell.qml
   ```

## 📂 What are these files?

- `shell.qml` - The main file that ties everything together.
- `MusicCard.qml` - The code for the expanding music player.
- `Visualizer.qml` - The code for the glowing RGB audio bars.
- `CavaService.qml` - The background code that connects the audio to the visualizer.
- `cava.conf` - A settings file to make the audio visualizer look perfect.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).
