# Snub
Managing gitignore files doesn’t get any easier than this.

### HOW TO:
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
