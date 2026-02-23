# preCICE GUI Prototype

A unified, native macOS graphical user interface for preCICE, the coupling library for partitioned multi-physics simulations.

This application provides a modular workspace to manage projects, design simulation topologies and more! 

## Features

- **Unified dashboard**: A central hub to access all preCICE utility tools from a single window.
- **Visual topology editor**: The power of `precice-case-generate` wrapped in an interactive node based graph editor
  - Drag and drop connections with magnetic snapping and dynamic routing.
  - Generate necessary configuration files directly from your visual graph.
- **Integrated project management**: A built-in sidebar allows you to easily browse project folders, manage files, and preview configurations without leaving the app.

## Requirements

- macOS
- Xcode to build the project

## Getting started

1. Clone the repository
  ```bash
git clone https://github.com/yourusername/precice-gui-prototype.git
cd precice-gui-prototype
```
2. Open the project
Open the folder in Xcode or double click the `precice-gui-prototype.xcodeproj` file
3. Build and run
Select your Mac as the run destination and hit ⌘R (or the Play button) to build and launch the application.
4. Have fun!
Open any app and create a new project from the sidebar :)

## Apps

Currently, only the `precice-case-generate` is supported. 

