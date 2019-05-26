module kfs.entry;
import kfs.dir, kfs.file;
import std.algorithm, std.string;

enum EntryType {
  tKFS_Dir,
  tKFS_File
}

enum uint S_IFDIR = 40000; /* Directory.  */
enum uint S_IFREG = 100000; /* Regular file.  */

abstract class KFS_Entry {
  @property string name;
  EntryType entry_type();
  @property uint mode;
  @property size_t size;
  @property int nlink;

  KFS_Entry prev;

  this(string name) {
    this.name = name;
  }

  string getPwd() {
    string[] ret;
    KFS_Entry entry = this;

    while (entry !is null) {
      ret ~= entry.name;
      entry = entry.prev;
    }

    ret.reverse;

    string res = ret[0];

    if (ret.length > 1) {
      res ~= ret[1 .. $].join("/");
    }

    return res;
  }
}

KFS_Entry new_entry(string name, EntryType type) {
  final switch (type) with (EntryType) {
  case tKFS_Dir:
    return new KFS_Dir(name);
  case tKFS_File:
    return new KFS_File(name);
  }
}
