module kfs.avl;
import std.stdio;
import std.typecons;

string string_rep(string s, size_t n) {
  string ret;
  foreach (_; 0 .. n) {
    ret ~= s;
  }
  return ret;
}

class AVLNode(K, V) {
  public K key;
  public V value;
  private int height, size;
  public AVLNode!(K, V) left;
  public AVLNode!(K, V) right;

  this(K key, V value) {
    this.key = key;
    this.value = value;
    this.height = 1;
    this.size = 1;
  }
}

class AVLTree(K, V) {
  public AVLNode!(K, V) root;

  public Nullable!V find(K key) {
    AVLNode!(K, V) ret = AVLTree!(K, V).find(this.root, key);

    if (ret is null) {
      return typeof(return).init;
    } else {
      return nullable(ret.value);
    }
  }

  public bool exists(K key) {
    return AVLTree!(K, V).find(this.root, key) !is null;
  }

  private static AVLNode!(K, V) find(AVLNode!(K, V) t, K key) {
    if (t is null) {
      return null;
    }
    if (key == t.key) {
      return t;
    } else if (key < t.key) {
      return find(t.left, key);
    } else {
      return find(t.right, key);
    }
  }

  public void insert(K key, V value) {
    this.root = AVLTree!(K, V).insert(root, new AVLNode!(K, V)(key, value));
  }

  private static AVLNode!(K, V) insert(AVLNode!(K, V) t, AVLNode!(K, V) x) {
    if (t is null) {
      return x;
    }

    if (x.key == t.key) {
      t.value = x.value;
    } else if (x.key < t.key) {
      t.left = AVLTree!(K, V).insert(t.left, x);
    } else {
      t.right = AVLTree!(K, V).insert(t.right, x);
    }
    t.size += 1;

    return AVLTree!(K, V).balance(t);
  }

  private static int sz(AVLNode!(K, V) t) {
    return t !is null ? t.size : 0;
  }

  private static int ht(AVLNode!(K, V) t) {
    return t !is null ? t.height : 0;
  }

  enum LR {
    L,
    R
  }

  private static AVLNode!(K, V) get_child_by_LR(AVLNode!(K, V) t, LR lr) {
    final switch (lr) with (LR) {
    case L:
      return t.left;
    case R:
      return t.right;
    }
  }

  private static void set_child_by_LR(AVLNode!(K, V) dst, LR lr, AVLNode!(K, V) src) {
    final switch (lr) with (LR) {
    case L:
      dst.left = src;
      break;
    case R:
      dst.right = src;
      break;
    }
  }

  private static AVLNode!(K, V) rotate(AVLNode!(K, V) t, LR l, LR r) {
    AVLNode!(K, V) s = get_child_by_LR(t, r);
    AVLTree!(K, V).set_child_by_LR(t, r, get_child_by_LR(s, l));
    AVLTree!(K, V).set_child_by_LR(s, l, AVLTree!(K, V).balance(t));

    if (t !is null) {
      t.size = sz(t.left) + sz(t.right) + 1;
    }
    if (s !is null) {
      s.size = sz(s.left) + sz(s.right) + 1;
    }

    return AVLTree!(K, V).balance(s);
  }

  private static T max(T)(T a, T b) {
    return a > b ? a : b;
  }

  private static AVLNode!(K, V) balance(AVLNode!(K, V) t) {
    if (ht(t.right) - ht(t.left) < -1) {
      if (ht(t.left.right) - ht(t.left.left) > 0) {
        t.left = AVLTree!(K, V).rotate(t.left, LR.L, LR.R);
      }
      return AVLTree!(K, V).rotate(t, LR.R, LR.L);
    }

    if (ht(t.left) - ht(t.right) < -1) {
      if (ht(t.right.left) - ht(t.right.right) > 0) {
        t.right = AVLTree!(K, V).rotate(t.right, LR.R, LR.L);
      }
      return AVLTree!(K, V).rotate(t, LR.L, LR.R);
    }

    if (t !is null) {
      t.height = AVLTree!(K, V).max(ht(t.left), ht(t.right)) + 1;
      t.size = sz(t.left) + sz(t.right) + 1;
    }
    return t;
  }

  public static void print_node(AVLNode!(K, V) node, size_t depth = 0) {
    if (node !is null) {
      print_node(node.left, depth + 1);
      writefln("%s <%s:%s>", string_rep("    ", depth), node.key, node.value);
      print_node(node.right, depth + 1);
    }
  }

  public void print_tree() {
    print_node(this.root, 0);
  }

  static void collect_keys(AVLNode!(K, V) node, ref K[] ret) {
    if (node !is null) {
      ret ~= node.key;
      AVLTree!(K, V).collect_keys(node.left, ret);
      AVLTree!(K, V).collect_keys(node.right, ret);
    }
  }

  K[] keys() {
    K[] ret;
    AVLTree!(K, V).collect_keys(this.root, ret);
    return ret;
  }

  static void collect_values(AVLNode!(K, V) node, ref V[] ret) {
    if (node !is null) {
      ret ~= node.value;
      AVLTree!(K, V).collect_values(node.left, ret);
      AVLTree!(K, V).collect_values(node.right, ret);
    }
  }

  V[] values() {
    V[] ret;
    AVLTree!(K, V).collect_values(this.root, ret);
    return ret;
  }

}
