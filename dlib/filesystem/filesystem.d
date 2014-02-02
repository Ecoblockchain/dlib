/*
Copyright (c) 2014 Martin Cejp
Copyright (c) 2014 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dlib.filesystem.filesystem;

public import dlib.core.stream;

import std.datetime;
import std.range;

alias FileSize = StreamSize;

/// Holds general information about a file or directory.
struct FileStat {
    ///
    bool isFile, isDirectory;
    /// valid if isFile is true
    FileSize sizeInBytes;
    ///
    SysTime creationTimestamp, modificationTimestamp;
}

struct DirEntry {
    ///
    string name;
    ///
    bool isFile, isDirectory;
}

/// A directory in the file system.
interface Directory {
    ///
    void close();
    
    /// Get directory contents as a range.
    /// This range $(I should) be lazily evaluated when practical.
    /// The entries "." and ".." are skipped.
    InputRange!DirEntry contents();
}

/// A file system limited to read access.
interface ReadOnlyFileSystem {
    /** Get file or directory stats.
        Example:
        ---
        void printFileInfo(ReadOnlyFileSystem fs, string filename) {
            FileStat stat;
            
            writef("'%s'\t", filename);
            
            if (!fs.stat(filename, stat)) {
                writeln("ERROR");
                return;
            }
            
            if (stat.isFile)
                writefln("%u", stat.sizeInBytes);
            else if (stat.isDirectory)
                writeln("DIR");
            
            writefln("  created: %s", to!string(stat.creationTimestamp));
            writefln("  modified: %s", to!string(stat.modificationTimestamp));
        }
        ---
    */
    bool stat(string filename, out FileStat stat);
    
    /** Open a file for input.
        Returns: a valid InputStream on success, null on failure
    */
    InputStream openForInput(string filename);
    
    /** Open a directory.
    */
    Directory openDir(string path);
    
    /**
        Find files in the specified directory, conforming to the specified filter. (if any)
        Params:
        baseDir = path to the base directory (if empty, defaults to current working directory)
        recursive = if true, the search will recurse into subdirectories
        filter = a delegate to be called for each entry found to decide whether it should be returned as part of the collection (optional)
    
        Examples:
        ---
        void listImagesInDirectory(ReadOnlyFileSystem fs, string baseDir = "") {
            foreach (entry; fs.findFiles(baseDir, true)
                    .filter!(entry => entry.isFile)
                    .filter!(entry => !matchFirst(entry.name, `.*\.(gif|jpg|png)$`).empty)) {
                writefln("%s", entry.name);
            }
        }
        ---
    */
    InputRange!DirEntry findFiles(string baseDir, bool recursive);
}

// TODO: Use exceptions or not?
/// A file system with read/write access.
interface FileSystem: ReadOnlyFileSystem {
    /// File access flags.
    enum {
        read = 1,
        write = 2,
    }
    
    /// File creation flags.
    enum {
        create = 1,
        truncate = 2,
    }
    
    // TODO: Keep it this way? (strongly-typed)
    
    /** Open a file for output.
        Returns: a valid OutputStream on success, null on failure
    */
    OutputStream openForOutput(string filename, uint creationFlags);
    
    /** Open a file for input & output.
        Returns: a valid IOStream on success, null on failure
    */
    IOStream openForIO(string filename, uint creationFlags);
    
    //IOStream openFile(string filename, uint accessFlags, uint creationFlags);
    
    /** Create a new directory.
        Returns: true if a new directory was created
        Examples:
        ---
        fs.createDir("New Directory", false);
        fs.createDir("nested/directories/are/easy", true);
        ---
    */
    bool createDir(string path, bool recursive);
    
    // BROKEN API. Must define semantics for non-atomic move cases (e.g. moving a file to a different drive)
    /** Rename or move a file.
    */
    //bool move(string path, string newPath);
    
    /** Permanently delete a file or directory.
    */
    bool remove(string path, bool recursive);
}
