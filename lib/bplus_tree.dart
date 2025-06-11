import 'dart:math';

import 'package:main/models/node.dart';

class BPlusTree {
  Node? root;
  final int maxKeys;
  int _keyCounter; // Tracks next available key

  BPlusTree(this.maxKeys) : _keyCounter = 1 {
    root = LeafNode([], null, null, []);
  }

  // Insert a value, auto-generating a key
  void insert(int value) {
    int key = _keyCounter++;
    LeafNode leafNode = _findLeaf(key);
    leafNode.insertKeyValue(key, value);
    if (leafNode.keys.length > maxKeys) {
      _splitLeaf(leafNode);
    }
  }

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

  void _splitLeaf(LeafNode leaf) {
    int mid = (leaf.keys.length / 2).floor();
    List<int> leftKeys = leaf.keys.sublist(0, mid);
    List<int> leftValues = leaf.values.sublist(0, mid);
    List<int> rightKeys = leaf.keys.sublist(mid);
    List<int> rightValues = leaf.values.sublist(mid);

    LeafNode right = LeafNode(rightKeys, leaf.parent, leaf.next, rightValues);
    leaf.keys = leftKeys;
    leaf.values = leftValues;
    leaf.next = right;

    int splitKey = right.keys[0];
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
      if (parent.keys.length > maxKeys) {
        _splitInternal(parent);
      }
    }
  }

  void _splitInternal(InternalNode node) {
    int mid = (node.keys.length / 2).floor();
    int splitKey = node.keys[mid];
    List<int> leftKeys = node.keys.sublist(0, mid);
    List<int> rightKeys = node.keys.sublist(mid + 1);
    List<Node> leftChildren = node.children.sublist(0, mid + 1);
    List<Node> rightChildren = node.children.sublist(mid + 1);

    InternalNode left = InternalNode(leftKeys, node.parent, leftChildren);
    InternalNode right = InternalNode(rightKeys, node.parent, rightChildren);

    for (Node child in leftChildren) child.parent = left;
    for (Node child in rightChildren) child.parent = right;

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
      if (parent.keys.length > maxKeys) {
        _splitInternal(parent);
      }
    }
  }

  int? search(int key) {
    LeafNode leafNode = _findLeaf(key);
    int index = leafNode.keys.indexOf(key);
    if (index != -1) {
      return leafNode.values[index];
    }
    return null;
  }

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

  void reset() {
    root = LeafNode([], null, null, []);
    _keyCounter = 1; // Reset key counter
  }

  void remove(int key) {
    LeafNode leafNode = _findLeaf(key);
    int index = leafNode.keys.indexOf(key);
    if (index != -1) {
      leafNode.keys.removeAt(index);
      leafNode.values.removeAt(index);

      int minKeys = (maxKeys / 2).ceil();
      if (leafNode.keys.length < minKeys && leafNode != root) {
        _handleUnderflowLeaf(leafNode);
      }
    }
  }

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
    if (nodeIndex < parent.children.length - 1) {
      sibling = parent.children[nodeIndex + 1] as LeafNode;
      separatorIndex = nodeIndex;
    } else if (nodeIndex > 0) {
      sibling = parent.children[nodeIndex - 1] as LeafNode;
      separatorIndex = nodeIndex - 1;
      LeafNode temp = node;
      node = sibling;
      sibling = temp;
      nodeIndex = separatorIndex;
    }

    if (sibling == null) return;

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
    if (nodeIndex < parent.children.length - 1) {
      sibling = parent.children[nodeIndex + 1] as InternalNode;
      separatorIndex = nodeIndex;
    } else if (nodeIndex > 0) {
      sibling = parent.children[nodeIndex - 1] as InternalNode;
      separatorIndex = nodeIndex - 1;
      InternalNode temp = node;
      node = sibling;
      sibling = temp;
      nodeIndex = separatorIndex;
    }

    if (sibling == null) return;

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

  void addRandom() {
    Random random = Random();
    int randomValue = random.nextInt(100) + 1; // Random value from 1 to 100
    insert(randomValue);
  }
}