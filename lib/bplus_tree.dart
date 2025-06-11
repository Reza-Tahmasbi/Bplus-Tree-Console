import 'dart:math';

import 'package:main/models/node.dart';

/// A B+ Tree implementation with support for insert, delete, search,
/// and range queries. Auto-generates integer keys for inserted values.
class BPlusTree {
  Node? root;
  final int maxKeys; // Maximum number of keys allowed per node
  int _keyCounter; // Tracks next available key for insertion

  /// Constructs a B+ tree with the given maximum number of keys per node.
  /// Initializes root as a new empty LeafNode.
  BPlusTree(this.maxKeys) : _keyCounter = 1 {
    root = LeafNode([], null, null, []);
  }

  /// Inserts a value into the B+ Tree with an auto-incremented key.
  void insert(int value) {
    int key = _keyCounter++;
    LeafNode leafNode = _findLeaf(key);
    leafNode.insertKeyValue(key, value);

    // If leaf node overflows, split it
    if (leafNode.keys.length > maxKeys) {
      _splitLeaf(leafNode);
    }
  }

  /// Traverses the tree to locate the leaf node where the key should reside.
  LeafNode _findLeaf(int key) {
    Node? current = root;
    while (!current!.isLeaf) {
      InternalNode internal = current as InternalNode;
      int i = 0;
      while (i < internal.keys.length && key >= internal.keys[i]) {
        i++;
      }
      current = internal.children[i];
    }
    return current as LeafNode;
  }

  /// Splits an overflown leaf node into two and promotes the middle key to the parent.
  void _splitLeaf(LeafNode leaf) {
    int mid = (leaf.keys.length / 2).floor();

    // Divide keys and values into left and right halves
    List<int> leftKeys = leaf.keys.sublist(0, mid);
    List<int> leftValues = leaf.values.sublist(0, mid);
    List<int> rightKeys = leaf.keys.sublist(mid);
    List<int> rightValues = leaf.values.sublist(mid);

    // Create the new right node
    LeafNode right = LeafNode(rightKeys, leaf.parent, leaf.next, rightValues);

    // Update current (left) node
    leaf.keys = leftKeys;
    leaf.values = leftValues;
    leaf.next = right;

    int splitKey = right.keys[0];

    // Promote key to parent or create new root
    if (leaf.parent == null) {
      root = InternalNode([splitKey], null, [leaf, right]);
      leaf.parent = root;
      right.parent = root;
    } else {
      InternalNode parent = leaf.parent as InternalNode;
      int i = 0;
      while (i < parent.keys.length && parent.keys[i] < splitKey) {
        i++;
      }
      parent.keys.insert(i, splitKey);
      parent.children.insert(i + 1, right);
      right.parent = parent;

      // Recursively handle parent overflow
      if (parent.keys.length > maxKeys) {
        _splitInternal(parent);
      }
    }
  }

  /// Splits an overflown internal node and promotes the middle key.
  void _splitInternal(InternalNode node) {
    int mid = (node.keys.length / 2).floor();
    int splitKey = node.keys[mid];

    // Divide keys and children
    List<int> leftKeys = node.keys.sublist(0, mid);
    List<int> rightKeys = node.keys.sublist(mid + 1);
    List<Node> leftChildren = node.children.sublist(0, mid + 1);
    List<Node> rightChildren = node.children.sublist(mid + 1);

    InternalNode left = InternalNode(leftKeys, node.parent, leftChildren);
    InternalNode right = InternalNode(rightKeys, node.parent, rightChildren);

    // Update parent pointers
    for (Node child in leftChildren) child.parent = left;
    for (Node child in rightChildren) child.parent = right;

    // Promote the split key
    if (node.parent == null) {
      root = InternalNode([splitKey], null, [left, right]);
      left.parent = root;
      right.parent = root;
    } else {
      InternalNode parent = node.parent as InternalNode;
      int i = 0;
      while (i < parent.keys.length && parent.keys[i] < splitKey) i++;
      parent.keys.insert(i, splitKey);
      parent.children[i] = left;
      parent.children.insert(i + 1, right);
      left.parent = parent;
      right.parent = parent;

      // Recursively handle parent overflow
      if (parent.keys.length > maxKeys) {
        _splitInternal(parent);
      }
    }
  }

  /// Searches for a value by key. Returns null if the key is not found.
  int? search(int key) {
    LeafNode leafNode = _findLeaf(key);
    int index = leafNode.keys.indexOf(key);
    if (index != -1) {
      return leafNode.values[index];
    }
    return null;
  }

  /// Retrieves a list of key-value pairs whose keys fall within [start, end].
  List<MapEntry<int, int>> findRange(int start, int end) {
    List<MapEntry<int, int>> rangeList = [];
    LeafNode? currentNode = _findLeaf(start);

    while (currentNode != null) {
      for (int i = 0; i < currentNode.keys.length; i++) {
        int key = currentNode.keys[i];
        if (key < start) continue;
        if (key > end) return rangeList;
        rangeList.add(MapEntry(key, currentNode.values[i]));
      }
      currentNode = currentNode.next;
    }
    return rangeList;
  }

  /// Resets the B+ tree to its initial state (empty).
  void reset() {
    root = LeafNode([], null, null, []);
    _keyCounter = 1;
  }

  /// Removes a key and its associated value from the tree.
  void remove(int key) {
    LeafNode leafNode = _findLeaf(key);
    int index = leafNode.keys.indexOf(key);
    if (index != -1) {
      leafNode.keys.removeAt(index);
      leafNode.values.removeAt(index);

      // If underflow occurs and node isn't root, handle it
      int minKeys = (maxKeys / 2).ceil();
      if (leafNode.keys.length < minKeys && leafNode != root) {
        _handleUnderflowLeaf(leafNode);
      }
    }
  }

  /// Handles underflow in a leaf node by merging or redistributing.
  void _handleUnderflowLeaf(LeafNode node) {
    if (node == root) {
      if (node.keys.isEmpty) {
        root = LeafNode([], null, null, []);
      }
      return;
    }

    InternalNode parent = node.parent as InternalNode;
    int nodeIndex = parent.children.indexOf(node);

    LeafNode? sibling;
    int separatorIndex = -1;

    // Try to find a right sibling
    if (nodeIndex < parent.children.length - 1) {
      sibling = parent.children[nodeIndex + 1] as LeafNode;
      separatorIndex = nodeIndex;
    }
    // Or a left sibling
    else if (nodeIndex > 0) {
      sibling = parent.children[nodeIndex - 1] as LeafNode;
      separatorIndex = nodeIndex - 1;
      LeafNode temp = node;
      node = sibling;
      sibling = temp;
      nodeIndex = separatorIndex;
    }

    if (sibling == null) return;

    // Merge nodes
    node.keys.addAll(sibling.keys);
    node.values.addAll(sibling.values);
    node.next = sibling.next;

    parent.keys.removeAt(separatorIndex);
    parent.children.removeAt(nodeIndex + 1);

    int minKeys = (maxKeys / 2).ceil();
    if (parent.keys.isEmpty && parent == root) {
      root = node;
      node.parent = null;
    } else if (parent.keys.length < minKeys) {
      _handleUnderflowInternal(parent);
    }
  }

  /// Handles underflow in an internal node by merging or redistributing.
  void _handleUnderflowInternal(InternalNode node) {
    if (node == root) {
      if (node.keys.isEmpty) {
        if (node.children.isNotEmpty) {
          root = node.children[0];
          root!.parent = null;
        } else {
          root = LeafNode([], null, null, []);
        }
      }
      return;
    }

    InternalNode parent = node.parent as InternalNode;
    int nodeIndex = parent.children.indexOf(node);

    InternalNode? sibling;
    int separatorIndex = -1;

    // Try right sibling
    if (nodeIndex < parent.children.length - 1) {
      sibling = parent.children[nodeIndex + 1] as InternalNode;
      separatorIndex = nodeIndex;
    }
    // Or left sibling
    else if (nodeIndex > 0) {
      sibling = parent.children[nodeIndex - 1] as InternalNode;
      separatorIndex = nodeIndex - 1;
      InternalNode temp = node;
      node = sibling;
      sibling = temp;
      nodeIndex = separatorIndex;
    }

    if (sibling == null) return;

    // Merge nodes
    int separatorKey = parent.keys[separatorIndex];
    node.keys.add(separatorKey);
    node.keys.addAll(sibling.keys);
    node.children.addAll(sibling.children);
    for (Node child in sibling.children) {
      child.parent = node;
    }

    parent.keys.removeAt(separatorIndex);
    parent.children.removeAt(nodeIndex + 1);

    int minKeys = (maxKeys / 2).ceil();
    if (parent.keys.isEmpty && parent == root) {
      root = node;
      node.parent = null;
    } else if (parent.keys.length < minKeys) {
      _handleUnderflowInternal(parent);
    }
  }

  /// Inserts a random value between 1 and 100 into the tree.
  void addRandom() {
    Random random = Random();
    int randomValue = random.nextInt(100) + 1;
    insert(randomValue);
  }
}
