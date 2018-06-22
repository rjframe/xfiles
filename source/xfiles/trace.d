module xfiles.trace;

void trace(T...)(T args, string func = __FUNCTION__) {
    import std.stdio : writeln;
    debug writeln("*trace: ", func, "- ", args);
}
