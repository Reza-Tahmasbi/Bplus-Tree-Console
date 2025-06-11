abstract class Node {
  List<int> keys;
  bool isLeaf;
  Node? parent;
  Node(this.keys, this.parent, this.isLeaf);
}

class LeafNode extends Node {
  List<int> values;
  LeafNode? next;
  LeafNode(List<int> keys, Node? parent, this.next, this.values)
      : super(keys, parent, true);

  void insertKeyValue(int key, int value) {
    int i = 0;
    while (i < keys.length && keys[i] < key) {
      i++;
    }
    keys.insert(i, key);
    values.insert(i, value);
  }
}

class InternalNode extends Node {
  List<Node> children;

  InternalNode(List<int> keys, Node? parent, this.children)
      : super(keys, parent, false);
}
