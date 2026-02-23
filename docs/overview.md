# Overview

The aim of this file is to explain the structure and functionality of the project.

## Structure

The project consists of a central view ("the homescreen"), which allows to access all other views of the project ("the (sub-)apps").

Each of these apps should be built as modular as possible. 

The structure of the project is as follows:

```
precice-gui-app
├── App                                         # Items that are central to the project
│   ├── AppNavigationManager.swift                      # Allows to navigate between apps and the homescreen
│   ├── RootView.swift                                  # The view of the homescreen
│   └── preCICEUtilityApp.swift                         # The main file
├── Assets.xcassets
│   └── ...                                         # Logos etc
├── Core                                        # Shared items that are used in multiple apps
│   ├── Buttons             
│   |   ├── CopyButton.swift
|   |   ├── SaveButton.swift
|   |   ├── OpenExternalButton.swift          
│   │   └── HomeButton.swift
|   ├── Models                                      
│   |   └── PreviewData.swift                           # Information about a file being previewed
│   ├── Services                                    # Items that perform a service for multiple apps 
│   │   ├── AppAccentColor.swift                        # Defines colors 
│   │   ├── FileWatcher.swift                           # Handles files being edited externally
│   │   ├── LogFormatter.swift                          # Formats log messages
│   │   ├── NativeTextView.swift                        # Manages the display of text in a textfield 
│   │   ├── ProjectManager.swift                        # Creates / retrieves folders for projects 
│   │   └── ThemeManager.swift                          # Changes theme dark <-> light
│   ├── ViewModels                                  # View models for shared services / operations
│   │   └── FilePreviewViewModel.swift                  # Previewing files (loading, reading, saving)
│   └── Views                                       
│       ├── Settings                                    # The settings
│       │   ├── About                                       # About settings with information about the project 
│       │   │   └── AboutSettingsView.swift
│       │   ├── Appearance                                  # Appearance settings: Light / dark, accent color, app icon
│       │   │   ├── AppearanceMode.swift
│       │   │   ├── AppearanceSettingsView.swift
│       │   │   ├── IconOptionButton.swift
│       │   │   └── ThemeOptionButton.swift
│       │   ├── General                                     # General settings
│       │   │   └── GeneralSettingsView.swift
│       │   └── SettingsView.swift                          # The settings window that incorporates these views
│       └── Sidebar                                     # The sidebar that displays a users projects and files in them
│           ├── Components                                  # Components of the sidebar
│           │   ├── FileNode.swift                              
│           │   ├── FileNodeRow.swift                           # Files are sub-items to the main folders
│           │   ├── ProjectRow.swift                            # Projects are the "main" folders
│           │   ├── ProjectSectionView.swift                    # Handles the view of a folder and its sub items
│           │   └── SidebarItem.swift                           # Enum to differentiate between file and folder
│           ├── FileTreeView.swift                          # Handles display of project file-tree
│           ├── ProjectSidebarView.swift                    # View of the sidebar and its components
│           └── SidebarHeaderView.swift                     # View of the header of the sidebar
├── Modules                                     # Files for specific sub-apps
│   ├── Dashboard                                   # The homescreen
│   │   ├── DashboardView.swift                         # Displays tiles for apps and their thumbnails
│   │   ├── DashboardCard.swift                         # Defines how a tile / card should look like
│   │   └── Thumbnails                                  # Thumbnails for apps
│   │       └── GraphThumbnail.swift
│   ├── SimulationRunner                            # Something secret :)
│   │   └── ...
│   └── case-generate                               # Case Generate
│       ├── Buttons                                     # More complex buttons used in the app 
│       │   ├── AddProjectButton.swift
│       │   ├── CloseSidebarButton.swift
│       │   ├── EditButton.swift
│       │   └── RunButton.swift
│       ├── Models                                      # Models for the app
│       |   ├── InfiniteGrid.swift                          # A background with a dot grid
│       │   ├── App                                         # Models not in the graph
│       │   │   ├── DetachedStatusIcon.swift
│       │   │   ├── GenerationState.swift
│       │   │   ├── PopupAnimation.swift
│       │   │   └── WarningMessage.swift
│       │   └── Graph                                       # Models for the graph
│       │       ├── Dimensionality.swift
│       │       ├── Edge.swift
│       │       ├── EdgeType.swift
│       │       ├── GraphData.swift
│       │       ├── Participant.swift
│       │       └── Patch.swift
│       ├── Services                                    # "Programs" that are used in the app
│       │   ├── CLI
│       │   │   ├── cli
│       │   │   └── info.txt
│       │   ├── CaseGenerateRunner.swift
│       │   └── TopologyGenerator.swift
│       ├── ViewModels                                  # View model of the app (logic for actions in the app)
│       │   ├── GCVM+Actions.swift                          # Deleting and adding elements to the graph
│       │   ├── GCVM+CaseGenerate.swift                     # Call CaseGenerate services
│       │   ├── GCVM+FileIO.swift                           # Loading, saving and other operations with the current project files
│       │   ├── GCVM+Geometry.swift                         # Angles and positions of graph elements
│       │   ├── GCVM+Sidebar.swift                          # Managing projects through the sidebar
│       │   └── GraphCanvasViewModel.swift
│       └── Views
│           ├── Canvas                                      # The space to create the graph in
│           │   ├── CanvasToolbar.swift                         # A toolbar at the bottom of the screen
│           │   ├── CanvasView.swift                            # Display the background, graph, toolbar and sidebar
│           │   ├── GraphElements
│           │   │   ├── Edge
│           │   │   │   ├── DrawQuadPath.swift                          # Function to draw the edge
│           │   │   │   ├── EdgeArrow.swift                             # Place an arrow to indicate direction
│           │   │   │   ├── EdgeHitShape.swift                          # The shape of the edge
│           │   │   │   ├── EdgeLabel.swift                             # A text-label for the edge
│           │   │   │   ├── EdgePulse.swift                             # The drawing of the edge with a glow
│           │   │   │   ├── EdgeSensor.swift                            # The hitbox and interaction with the edge
│           │   │   │   ├── EdgeView.swift                              # Main edge view
│           │   │   │   ├── EdgeViewHelpers.swift                       # Helper to calculate correct bending
│           │   │   │   └── EdgeVisuals.swift                           # Draw the edge
│           │   │   ├── Node
│           │   │   │   ├── NodeDimensionalityBadge.swift               # A badge above the node
│           │   │   │   ├── NodeInterior.swift                          
│           │   │   │   ├── NodeNameTag.swift                           # Text field for the name
│           │   │   │   ├── ParticipantContextMenu.swift                
│           │   │   │   ├── ParticipantView.swift                       # Main node view
│           │   │   │   ├── ParticipantViewHelper.swift
│           │   │   │   └── PatchRing.swift                             # The outside houses the patches
│           │   │   └── Patch
│           │   │       └── PatchView.swift
│           │   ├── HUD
│           │   │   ├── ActivityHUDView.swift                       # Shows the state of the exectuable when running
│           │   │   └── ConsoleLogView.swift                        # Shows details of the run
│           │   └── Layers
│           │       ├── BackgroundLayer.swift                       # The background of the app
│           │       ├── ConnectionLayer.swift                       #
│           │       └── NodeLayer.swift
│           └── Settings                                    # Settings specific to the case-generate app
│               └── CaseGenerateSettingsView.swift
└── ...                                         # More logos
```

Some features are shared between apps. These include:

- The sidebar: The project overview sidebar is central to every app, as it allows to open project folders and access files (see `Views/Sidebar/`) 
- The settings menu: The settings for all apps are available in one window (see `Views/Settings/`). 
The settings "tab" of each app is located in the apps folder.
- A file preview: Files that are double clicked in the sidebar will open in a preview window (see `Views/FilePreview`)
- A grid pattern for the background of apps. Maybe not needed

## Add a new App

To add an app, these four steps need to be followed: 

1. Create a new folder under `Modules/` for it.
2. Create a settings tab for it in its module and include it in the `Core/Views/Settings/SettingsView.swift`
3. Add a thumbnail for it and store it under `Modules/Dashboard/Thumbnails/`
4. Edit the `Modules/Dashboard/DashboardView.swift` to include the new thumbnail
