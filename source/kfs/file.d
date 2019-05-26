module kfs.file;
import kfs.entry;

class KFS_File : KFS_Entry {
  ubyte[] buf;

  this(string name) {
    super(name);

    this.mode = S_IFREG | 444;
    this.nlink = 1;
    this.size = 0;
    this.buf = null;
  }

  override EntryType entry_type() {
    return EntryType.tKFS_File;
  }

  void write(ubyte[] buf) {
    this.size = buf.length;
    this.buf = buf.dup;
  }

  ubyte[] read() {
    return this.buf;
  }
}
