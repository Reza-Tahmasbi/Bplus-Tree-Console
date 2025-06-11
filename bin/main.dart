import 'dart:io';

import 'package:main/bplus_tree.dart';
import 'package:main/models/node.dart';

// Utility class for ANSI color codes
class ConsoleColor {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String cyan = '\x1B[36m';

  static String colored(String text, String color) => '$color$text$reset';
}

void main() {
  print(ConsoleColor.colored('Welcome to the B+ Tree Console Application!', ConsoleColor.blue));
  print(ConsoleColor.colored('Enter the maximum number of keys per node:', ConsoleColor.blue));
  int? maxKeys = int.tryParse(stdin.readLineSync() ?? '');
  if (maxKeys == null || maxKeys < 1) {
    print(ConsoleColor.colored('Invalid input. Using default maxKeys = 3.', ConsoleColor.red));
    maxKeys = 3;
  }
  final tree = BPlusTree(maxKeys);
  print(ConsoleColor.colored('Initial tree:', ConsoleColor.blue));
  _printTreeWithColor(tree);

  while (true) {
    print(ConsoleColor.colored('\n=== B+ Tree Menu ===', ConsoleColor.blue));
    print(ConsoleColor.colored('1. Insert a value', ConsoleColor.blue));
    print(ConsoleColor.colored('2. Search for a key', ConsoleColor.blue));
    print(ConsoleColor.colored('3. Find range of keys', ConsoleColor.blue));
    print(ConsoleColor.colored('4. Remove a key', ConsoleColor.blue));
    print(ConsoleColor.colored('5. Add a random value', ConsoleColor.blue));
    print(ConsoleColor.colored('6. Reset tree', ConsoleColor.blue));
    print(ConsoleColor.colored('7. Exit', ConsoleColor.blue));
    print(ConsoleColor.colored('Enter your choice (1-7):', ConsoleColor.blue));

    String? choice = stdin.readLineSync();
    switch (choice) {
      case '1':
        print(ConsoleColor.colored('Enter value (integer):', ConsoleColor.blue));
        int? value = int.tryParse(stdin.readLineSync() ?? '');
        if (value != null) {
          tree.insert(value);
          print(ConsoleColor.colored('Inserted value $value. Tree structure:', ConsoleColor.green));
          _printTreeWithColor(tree);
        } else {
          print(ConsoleColor.colored('Invalid input. Please enter a valid integer.', ConsoleColor.red));
        }
        break;

      case '2':
        print(ConsoleColor.colored('Enter key to search (integer):', ConsoleColor.blue));
        int? key = int.tryParse(stdin.readLineSync() ?? '');
        if (key != null) {
          int? result = tree.search(key);
          if (result != null) {
            print(ConsoleColor.colored('Key $key found with value: $result', ConsoleColor.green));
          } else {
            print(ConsoleColor.colored('Key $key not found.', ConsoleColor.red));
          }
          print(ConsoleColor.colored('Current tree structure:', ConsoleColor.blue));
          _printTreeWithColor(tree);
        } else {
          print(ConsoleColor.colored('Invalid input. Please enter a valid integer.', ConsoleColor.red));
        }
        break;

      case '3':
        print(ConsoleColor.colored('Enter start key (integer):', ConsoleColor.blue));
        int? start = int.tryParse(stdin.readLineSync() ?? '');
        print(ConsoleColor.colored('Enter end key (integer):', ConsoleColor.blue));
        int? end = int.tryParse(stdin.readLineSync() ?? '');
        if (start != null && end != null) {
          var range = tree.findRange(start, end);
          if (range.isEmpty) {
            print(ConsoleColor.colored('No keys found in range [$start, $end].', ConsoleColor.red));
          } else {
            print(ConsoleColor.colored('Keys in range [$start, $end]:', ConsoleColor.green));
            for (var entry in range) {
              print(ConsoleColor.colored('Key: ${entry.key}, Value: ${entry.value}', ConsoleColor.green));
            }
          }
          print(ConsoleColor.colored('Current tree structure:', ConsoleColor.blue));
          _printTreeWithColor(tree);
        } else {
          print(ConsoleColor.colored('Invalid input. Please enter valid integers.', ConsoleColor.red));
        }
        break;

      case '4':
        print(ConsoleColor.colored('Enter key to remove (integer):', ConsoleColor.blue));
        int? key = int.tryParse(stdin.readLineSync() ?? '');
        if (key != null) {
          tree.remove(key);
          print(ConsoleColor.colored('Key $key removed (if it existed). Tree structure:', ConsoleColor.green));
          _printTreeWithColor(tree);
        } else {
          print(ConsoleColor.colored('Invalid input. Please enter a valid integer.', ConsoleColor.red));
        }
        break;

      case '5':
        tree.addRandom();
        print(ConsoleColor.colored('Inserted a random value. Tree structure:', ConsoleColor.green));
        _printTreeWithColor(tree);
        break;

      case '6':
        tree.reset();
        print(ConsoleColor.colored('Tree has been reset. Tree structure:', ConsoleColor.green));
        _printTreeWithColor(tree);
        break;

      case '7':
        print(ConsoleColor.colored('Exiting...', ConsoleColor.blue));
        exit(0);

      default:
        print(ConsoleColor.colored('Invalid choice. Please enter a number between 1 and 7.', ConsoleColor.red));
    }
  }
}

// Helper function to print the tree with colored output, row numbers, and root tag
void _printTreeWithColor(BPlusTree tree) {
  if (tree.root == null) {
    print(ConsoleColor.colored('Tree is empty', ConsoleColor.yellow));
    return;
  }

  List<List<Node>> levels = [];
  List<Node> currentLevel = [tree.root!];
  while (currentLevel.isNotEmpty) {
    levels.add(currentLevel);
    List<Node> nextLevel = [];
    for (Node node in currentLevel) {
      if (!node.isLeaf) {
        InternalNode internal = node as InternalNode;
        nextLevel.addAll(internal.children);
      }
    }
    currentLevel = nextLevel;
  }

  for (int i = 0; i < levels.length; i++) {
    int rowNumber = 1;
    for (Node node in levels[i]) {
      String label = i == 0 && rowNumber == 1
          ? 'Level ${i + 1}, Row $rowNumber (Root):'
          : 'Level ${i + 1}, Row $rowNumber:';
      print(ConsoleColor.colored(label, ConsoleColor.cyan));
      if (node.isLeaf) {
        LeafNode leaf = node as LeafNode;
        List<String> pairs = [];
        for (int j = 0; j < leaf.keys.length; j++) {
          pairs.add('(${leaf.keys[j]}:${leaf.values[j]})');
        }
        print(ConsoleColor.colored('  [${pairs.join(', ')}]', ConsoleColor.yellow));
      } else {
        InternalNode internal = node as InternalNode;
        print(ConsoleColor.colored('  [${internal.keys.join(', ')}]', ConsoleColor.yellow));
      }
      rowNumber++;
    }
  }
}