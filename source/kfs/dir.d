module kfs.dir;
import kfs.entry;
import kfs.avl;
import std.typecons;
import std.string;
import std.stdio;
import std.format;
import std.algorithm;

class KFS_Dir : KFS_Entry {
  AVLTree!(string, KFS_Entry) childs;

  this(string name) {
    super(name);

    this.mode = S_IFDIR | 755;
    this.nlink = 1;
    this.size = 4096;
    this.childs = new AVLTree!(string, KFS_Entry);
  }

  override EntryType entry_type() {
    return EntryType.tKFS_Dir;
  }

  void append_child(KFS_Entry entry) {
    childs.insert(entry.name, entry);
    entry.prev = this;
  }

  Nullable!KFS_Entry find_on(string name) {
    return this.childs.find(name);
  }

  Nullable!KFS_Entry find(string path) {
    if (path == "/") {
      if (this.name == "/") {
        return nullable(cast(KFS_Entry) this);
      } else {
        return typeof(return).init;
      }
    }

    if (path.length > 1 && path[0] == '/') {
      path = path[1 .. $];
    }

    string[] paths = path.split("/");
    Nullable!KFS_Entry tentry = nullable(this);

    foreach (i, tpath; paths) {
      if (tentry.isNull) {
        return typeof(return).init;
      }

      KFS_Entry entry = tentry.get;

      // pathの終端の場合，探すのをここでうちきる．
      if (i + 1 == paths.length) {
        if (entry.entry_type == EntryType.tKFS_File) {
          if (tpath == entry.name) {
            return tentry;
          } else {
            return typeof(return).init;
          }
        } else {
          return (cast(KFS_Dir) entry).find_on(tpath);
        }
      } else {
        // 途中にあったのがファイルの場合，目的のものはない(それ以上ほれないため)
        if (entry.entry_type == EntryType.tKFS_File) {
          return typeof(return).init;
        } else {
          tentry = (cast(KFS_Dir) entry).find_on(tpath);
        }
      }
    }

    return typeof(return).init;
  }

  string[] getCurrentLists() {
    return [".", ".."] ~ childs.keys;
  }

  string[] getTree() {
    string[] ret;

    void trav_f(AVLNode!(string, KFS_Entry) node, string prefix, ref string[] ret) {
      if (node is null) {
        return;
      }

      string new_prefix = "%s%s".format(prefix, node.key);
      ret ~= new_prefix;

      if (node.value.entry_type == EntryType.tKFS_Dir) {
        KFS_Dir dir = cast(KFS_Dir) node.value;
        trav_f(dir.childs.root, new_prefix ~ "/", ret);
      }

      trav_f(node.left, prefix ~ (prefix == "/" ? "" : "/"), ret);
      trav_f(node.right, prefix ~ (prefix == "/" ? "" : "/"), ret);
    }

    ret ~= this.name;
    trav_f(this.childs.root, this.name, ret);

    ret.sort!"a<b";
    return ret;
  }
}
