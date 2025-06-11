/// Abstract class representing a generic node in a B+ Tree.
/// Contains a list of keys, a reference to the parent, and a flag indicating if it's a leaf.
abstract class Node {
  List<int> keys;     // Keys stored in the node
  bool isLeaf;        // Indicates whether this node is a leaf node
  Node? parent;       // Reference to the parent node (nullable)

  Node(this.keys, this.parent, this.isLeaf);
}

/// Class representing a leaf node in a B+ Tree.
/// Leaf nodes contain key-value pairs and are linked to the next leaf node.
class LeafNode extends Node {
  List<int> values;       // List of values corresponding to keys
  LeafNode? next;         // Pointer to the next leaf node (for range queries)

  LeafNode(List<int> keys, Node? parent, this.next, this.values)
      : super(keys, parent, true);

  /// Inserts a (key, value) pair into the leaf node in sorted order.
  void insertKeyValue(int key, int value) {
    int i = 0;
    // Find correct index to maintain sorted order of keys
    while (i < keys.length && keys[i] < key) {
      i++;
    }
    keys.insert(i, key);
    values.insert(i, value);
  }
}

/// Class representing an internal node in a B+ Tree.
/// Internal nodes route the search by containing keys and pointers to child nodes.
class InternalNode extends Node {
  List<Node> children;   // Child pointers corresponding to keys

  InternalNode(List<int> keys, Node? parent, this.children)
      : super(keys, parent, false);
}
