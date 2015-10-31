ocamshell
=========

I want to learn ocaml and this should be a relatively simple project.

# Scope

1. Fork-exec programs from command line in synchronous way. **[IN PROGRESS]**
2. Fork-exec programs in async way (`&`) and monitor / send signals to jobs.
3. Create pipelines (`|`) for sync and async invocation.
4. Support semicolon, double ampersand, and double pipe operators (`;`, `&&`, `||`).
5. Support all stream redirection operators, including into another process (this includes the subshell operator `()`).
6. Support `$()`.

I really should just be using a parser generator, but I don't wanna get into that since I just want to learn ocaml and for the tiny syntax mentioned above I don't really care.

Onwards?!

# License

GPLv3 (like anyone cares).
