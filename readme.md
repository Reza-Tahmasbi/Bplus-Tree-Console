# B+ Tree Console Application

## Overview
This is a Dart-based console application implementing a B+ tree data structure. It allows users to insert values (with auto-generated keys), search for keys, find key ranges, remove keys, add random values, and reset the tree. The console interface features colorized output and visualizes the tree structure after each operation, showing internal nodes as `[key1, key2, ...]`, leaf nodes as `[(key:value), ...]`, with level and row numbers, and tags the root node.

## Features
- **Insert Values**: Insert integer values, with keys auto-generated sequentially (1, 2, ...).
- **Search**: Find a value by its key.
- **Range Query**: Retrieve key-value pairs within a key range.
- **Remove**: Delete a key-value pair by key.
- **Random Insertion**: Add a random value (1 to 100).
- **Reset**: Clear the tree and reset key generation.
- **Visualization**: Displays the tree structure with:
  - Level and row numbers (e.g., "Level 1, Row 1 (Root):").
  - Internal nodes: `[key1, key2, ...]`.
  - Leaf nodes: `[(key1:value1), (key2:value2), ...]`.
- **Colorized Output**:
  - Blue: Menus and prompts.
  - Green: Success messages.
  - Red: Error messages.
  - Yellow: Tree nodes.
  - Cyan: Level/row labels.

## Prerequisites
- **Dart SDK**: Version 3.0.0 or higher. Install from [dart.dev](https://dart.dev/get-dart).
- **Terminal**: A terminal supporting ANSI colors (e.g., PowerShell, Windows Terminal, or VS Code integrated terminal).
- **Operating System**: Instructions are for Windows, but the project is cross-platform.

## Project Structure
```
bplus_tree_project/
├── bin/
│   └── main.dart           # Console interface
├── lib/
│   ├── bplus_tree.dart     # B+ tree implementation
│   └── models/
│       └── node.dart       # Node classes (Node, LeafNode, InternalNode)
├── pubspec.yaml            # Project configuration
```

## Setup
1. **Clone or Create the Project**:
   - Create a directory `bplus_tree_project` and place the following files:
     - `pubspec.yaml`
     - `lib/bplus_tree.dart`
     - `lib/models/node.dart`
     - `bin/main.dart`
   - Ensure the files match the provided versions (see source or repository).

2. **Verify Dart SDK**:
   - Run:
     ```powershell
     dart --version
     ```
   - Ensure the version is 3.0.0 or higher. If not, update via the Dart website.

3. **Resolve Dependencies**:
   - Navigate to the project directory:
     ```powershell
     cd path\to\bplus_tree_project
     ```
   - Fetch dependencies:
     ```powershell
     dart pub get
     ```
   - If errors occur, clear the cache:
     ```powershell
     del pubspec.lock
     rmdir /s /q .dart_tool
     dart pub get
     ```

## How to Run
1. **Navigate to Project Directory**:
   ```powershell
   cd path\to\bplus_tree_project
   ```

2. **Run the Application**:
   ```powershell
   dart run bin/main.dart
   ```

3. **Interact with the Console**:
   - Enter the maximum number of keys per node (e.g., `3`).
   - Use the menu to:
     - Insert a value (auto-generates a key).
     - Search for a value by key (keys shown in tree output).
     - Find key-value pairs in a key range.
     - Remove a key-value pair by key.
     - Add a random value.
     - Reset the tree.
     - Exit.
   - After each operation, the tree structure is displayed with level/row numbers and root tag.

## Example Usage
```
Welcome to the B+ Tree Console Application! [Blue]
Enter the maximum number of keys per node: [Blue]
3
Initial tree: [Blue]
Level 1, Row 1 (Root): [Cyan]
  [] [Yellow]

=== B+ Tree Menu === [Blue]
1. Insert a value
2. Search for a key
3. Find range of keys
4. Remove a key
5. Add a random value
6. Reset tree
7. Exit
Enter your choice (1-7): [Blue]
1
Enter value (integer): [Blue]
100
Inserted value 100. Tree structure: [Green]
Level 1, Row 1 (Root): [Cyan]
  [(1:100)] [Yellow]
```

## Notes
- **Keys**: The tree auto-generates sequential keys (1, 2, ...) for inserted values. Check the tree output to find keys for search/remove/range operations.
- **Colors**: Requires a terminal supporting ANSI colors (e.g., PowerShell, Windows Terminal). If colors don’t display, try a different terminal.
- **Debugging**: If the tree structure looks incorrect, note the input sequence and output for troubleshooting.

## License
This project is for educational purposes and provided as-is. Feel free to modify and extend it as needed.