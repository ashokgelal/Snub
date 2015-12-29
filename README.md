# [Snub](http://snub.ashokgelal.com/)
Snub makes managing gitignore files hassle free. Managing gitignore files doesn’t get any easier than this.

**[Snub](http://snub.ashokgelal.com/)** is a Cocoa + Command line tool to manage your gitignore files. The cocoa app sits in the menu bar so that you can quickly access it to perform tasks such as adding, removing, searching gitignore files etc.

**[Snub](http://snub.ashokgelal.com/)** written in Swift 2.0 and can only run on OS X 10.10 or higher. For more details visit: http://snub.ashokgelal.com/

### HOW TO ...

#### ... build this project?
1. Clone this repo
2. Run `$ pod install` from within `code` folder (from the terminal)

#### ... get the binary files?
1. Visit http://snub.ashokgelal.com/
2. Download and copy it to `/Applications` folder

You must run the Cocoa app at least once before you can access it from the command line. Once it is loaded, you can close the app from the system menu bar if you just want the command line version.

#### ... use the command line version?

1. Download the app and copy it to `/Applications` folder.
2. Open your terminal and add a symbolic links as:

  `ln -s /Applications/Snub.app/Contents/Frameworks/snub /usr/local/bin`
  
3. As long as `/usr/local/bin` has been added to your `$PATH` you should be able to now access [Snub](http://snub.ashokgelal.com) by just typing `snub` in your terminal.

### [SNUB](http://snub.ashokgelal.com) AS A COMMAND:

Usage:

    $ snub COMMAND

Commands:

    + list
    + add <type1+type2+...> [target]           e.g. $ snub add xcode+osx .
    + append <type1+type2+...> [target]        e.g. $ snub append xcode+osx .
    + suggest [target]                         e.g. $ snub suggest .
    + lucky [target]                           e.g. $ snub lucky .
    + cat <type1+type2+...>                    e.g. $ snub cat xcode+osx
    + help <command>                           e.g. $ snub help add

Options:

    (-v | --version)        Show the version and licensing info
    (-h | --help)           Print this help
