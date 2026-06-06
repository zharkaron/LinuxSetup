// Manual test fixture for the Neovim Java checker (issue #112).
//
// How to test:
//   1. Make sure `javac` is installed (Fedora: java-latest-openjdk-devel,
//      Debian/Ubuntu: default-jdk, Arch: jdk-openjdk).
//   2. Open this file in Neovim:  nvim nvim/test/java/LintExample.java
//   3. Diagnostics appear automatically on read/save/insert-leave, or run the
//      manual check with  \l  (<leader>l). Jump between findings with ]l / [l.
//
// Expected: javac -Xlint:all flags the raw-type usage below as WARN
//   diagnostics ([rawtypes] / [unchecked]) on the `new ArrayList()` line.
//   Introduce a syntax error (e.g. delete a semicolon) to see an ERROR.
//
// If `javac` is missing, running \l shows an actionable warning naming the
// package to install instead of failing.

import java.util.ArrayList;
import java.util.List;

public class LintExample {
    public static void main(String[] args) {
        List list = new ArrayList(); // raw type -> [rawtypes]/[unchecked] warnings
        list.add("hello");
        System.out.println(list.get(0));
    }
}
