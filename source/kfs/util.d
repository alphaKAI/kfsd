module kfs.util;
import kfs.entry, kfs.dir, kfs.file;
import std.stdio;
import std.file;
import std.path;

enum Command : string {
  Mkdir = "mkdir",
  Chdir = "cd",
  Touch = "touch",
  Ls = "ls",
  Pwd = "pwd",
  Tree = "tree",
  CopyFromHost = "copyFromHost",
  Cat = "cat",
  Help = "help",
}

class KFSContext {
  KFS_Dir root;
  KFS_Dir cwd;

  this(KFS_Dir root) {
    this.root = root;
    this.cwd = root;
  }
}

bool mkdir(KFSContext ctx, string name) {
  with (ctx) {
    auto ret = cwd.find_on(name);
    if (ret.isNull) {
      cwd.append_child(new KFS_Dir(name));
      return true;
    }

    return false;
  }
}

bool chdir(KFSContext ctx, string target) {
  with (ctx) {
    if (target == "..") {
      if (cwd.prev !is null) {
        KFS_Entry prev = cwd.prev;
        if (prev.entry_type == EntryType.tKFS_Dir) {
          cwd = cast(KFS_Dir) prev;
          return true;
        }
        return false;
      }
      return false;
    }

    auto ret = cwd.find(target);
    if (ret.isNull) {
      return false;
    }

    KFS_Entry tentry = ret.get;
    if (tentry.entry_type == EntryType.tKFS_Dir) {
      cwd = cast(KFS_Dir) tentry;
      return true;
    }

    return false;
  }
}

bool touch(KFSContext ctx, string name) {
  with (ctx) {
    auto ret = cwd.find_on(name);
    if (ret.isNull) {
      cwd.append_child(new KFS_File(name));
      return true;
    }

    return false;
  }
}

bool ls(KFSContext ctx) {
  foreach (elem; ctx.cwd.getCurrentLists) {
    writeln(elem);
  }

  return true;
}

bool pwd(KFSContext ctx) {
  writeln(ctx.cwd.getPwd);

  return true;
}

bool tree(KFSContext ctx) {
  foreach (elem; ctx.cwd.getTree) {
    writeln(elem);
  }
  return true;
}

bool copyFromHost(KFSContext ctx, string src, string dst) {
  with (ctx) {
    src = getcwd() ~ "/" ~ src;
    if (!exists(src)) {
      return false;
    }
    if (!cwd.find_on(dst).isNull) {
      return false;
    }

    string buf = readText(src);
    KFS_File new_file = new KFS_File(dst);
    new_file.write(cast(ubyte[]) buf);
    cwd.append_child(new_file);
    return true;
  }
}

bool cat(KFSContext ctx, string name) {
  with (ctx) {
    auto ret = cwd.find_on(name);
    if (ret.isNull) {
      return false;
    }
    KFS_Entry entry = ret.get;
    if (entry.entry_type == EntryType.tKFS_Dir) {
      return false;
    }
    KFS_File file = cast(KFS_File) entry;
    string buf = cast(string) file.read();
    writeln(buf);

    return true;
  }
}

bool help(KFSContext ctx) {
  import std.format;

  foreach (cmd; __traits(allMembers, Command)) {
    mixin("string cmd_str = Command.%s;".format(cmd));
    writeln(cmd_str);
  }

  return true;
}
