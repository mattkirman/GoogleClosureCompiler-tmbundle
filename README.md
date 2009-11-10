The Google Closure Compiler Bundle enables easy validation and compression of Javascript files using the [Google Closure Compiler](http://code.google.com/closure/compiler/), from within TextMate.


# Installation

## Installing From a Release (recommended)

Simply download a copy of the bundle from  <http://github.com/mattkirman/GoogleClosureCompiler-tmbundle/downloads> and double-click to install into TextMate.

## Installing From Source

If really you want to create your own bundle from source you can. Make sure you have [Git](http://git-scm.com/) and [Rake](http://rake.rubyforge.org/) installed correctly on your machine. To get the source and build your bundle simply:

    $ git clone git://github.com/mattkirman/GoogleClosureCompiler-tmbundle.git
    $ cd GoogleClosureCompiler-tmbundle
    $ rake
    $ rake install
    
Rake will install your bundle into `~/Library/Application Support/TextMate/Bundles/Google Closure Compiler.tmbundle`. If you want to install the bundle yourself *do not* run `rake install`. Instead, open the `build` folder in Finder and double-click the bundle.


# Setup

There are 3 steps to getting everything working:

1. [Download the Google Closure Compiler](http://closure-compiler.googlecode.com/files/compiler-latest.zip).

2. Unzip the Google Closure Compiler and copy the `.jar` file from the `***` folder to a location of your choosing (make a note of where you saved it).

3. Open the `Preferences...` item in this bundle and replace the text `/absolute/path/to/google_closure_compiler.jar` with the actual path to your `.jar` file. __It must be an absolute path, `~/` won't work__.


# Usage

Select the files you want to run through the Google Closure Compiler in the Project Drawer and execute the command using &#x21E7;&#8984;G (cmd-shift-G)

The compiled files share the same root as the filename, with the addition of `-compiled` before the file extension. For example:

`my_js_file.js` becomes `my_js_file-compiled.js`.

If you are compiling more than one file then they will be saved into a single file. For example:

`my_js_file.js` and `another_js_file.js` becomes `compiled.js`.

__Existing files with the same name will be overwritten without warning.__

For more information read `Help` in the installed bundle.