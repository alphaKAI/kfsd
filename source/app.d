import std.stdio;
import kfs.entry, kfs.dir, kfs.file;
import std.typecons;

void shell(KFS_Dir root = new KFS_Dir("/")) {
  import kfs.util;
  import std.string;

  KFSContext ctx = new KFSContext(root);
  string input;

  while (1) {
    writef("%s > ", ctx.cwd.getPwd);
    input = readln.chomp;
    if (input == "exit") {
      writeln("exit!");
      break;
    }

    string[] cmds = input.split;

    final switch (cmds[0]) with (Command) {
    case Mkdir:
      mkdir(ctx, cmds[1]);
      break;
    case Touch:
      touch(ctx, cmds[1]);
      break;
    case Chdir:
      chdir(ctx, cmds[1]);
      break;
    case Ls:
      ls(ctx);
      break;
    case Pwd:
      pwd(ctx);
      break;
    case Tree:
      tree(ctx);
      break;
    case CopyFromHost:
      copyFromHost(ctx, cmds[1], cmds[2]);
      break;
    case Cat:
      cat(ctx, cmds[1]);
      break;
    }
  }
}

void main(string[] args) {
  shell();
}

void test() {
  KFS_Dir root = new KFS_Dir("/");
  KFS_Dir hoge = new KFS_Dir("hoge");
  hoge.append_child(new KFS_File("foo"));
  KFS_Dir bar = new KFS_Dir("bar");
  KFS_Dir baz = new KFS_Dir("baz");
  KFS_File piyo = new KFS_File("piyo");
  baz.append_child(piyo);
  bar.append_child(baz);

  root.append_child(hoge);
  root.append_child(bar);
  string[] queries = ["/", "/hoge", "/hoge/foo", "/bar", "/bar/piyo", "/bar/baz", "/bar/baz/piyo"];
  foreach (query; queries) {
    auto res = root.find(query);
    writef("Query: %s, res: %s ", query, res);
    if (!res.isNull) {
      writeln(res.get.name);
    } else {
      writeln;
    }
  }

  writeln("ls on / : ", root.getCurrentLists);
  writeln("ls on /bar : ", bar.getCurrentLists);

  writeln("tree of / ", root.getTree);
  writeln("pwd of / ", root.getPwd);
  writeln("pwd of /bar/baz/piyo ", piyo.getPwd);
}
