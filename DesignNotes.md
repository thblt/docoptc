This document is a notebook/todo list on the design of docoptc, including notes on syntax extensions, extra features and code generation.

# Syntax extensions

## Runtime customization

## Error messages customization

Not planned yet.

Only one thing: since DocOpt can't (and shouldn't) perform a full validation of input parameters, the program must have a way to report errors in these parameters. It should be able to do this in a way independant of the interface, that is, without knowledge of the actual command-line parameters. We should then provide an interface (a function) which can be called with a) the incorrect value and b) an error message, and which would automatically locate the erroneous parameter, and print the message.
In C, that could be implemented by having the program provide a pointer to the erroneous value to the error function, and docoptc code will use the pointer itself to identify the erroneous flag. In Python, classes extending native types can be used. In Haskell,  

## Subcommands management

It is common for complex command-line applications to be invoked with subcommands, and even sometimes nested subcommands. Package managers and version control systems have been doing this for a long time.

DocOpt intrinsically distinguishes three types of parameters that can be provided on a command-line:

  1. Options, in the form of flags (-a, --all)
  2. Arguments (positionals)
  3. Commands (literal positionals)

Subcommands can be implemented as literal positionals, but this has a few limitations:

  1. Subcommands having their own parameters, usage patterns and help messages must be handled manually.
  2. Leads to duplication between code an usage strings: subcommands are defined in code, then defined again in docopt.
  2. Subcommands may be nested, e.g. `git remote <name> add-url`.
  3. Some subcommands may need access to the subcommand tree. `help`" is a good example.

A subcommand framework implemented in docopt would be able to:

  1. Handle a tree of subcommands, that could either be loaded from a tree of text files (usage strings) or, much better, from special markers in the code itself (that may be Python's docstrings, or specially formatted comments, or whatever structure the language allows)
  2. Provide at least a default implementation of the `help` subcommand.
  3. Provide at least a default implementation of the `--view-commands` option.
  4. Allow the user to map functions to subcommands, and deal with executing the correct function. 
  5. Allow the subcommand tree to be edited at runtime, to deal with plugins/extensions/etc.
  6. Handle common/shared options, like verbosity or simulate mode, that could be set at a relatively high level and then forwarded to subcommands.
    * or even set separately (using a logic of "partial" files) and called by the subcommands which use them in their docopt file, using a syntax extension.

## Parameters translation

### Names translation

Docopt requires much less code to design a CLI program, but its output may require extra analysis. Parameters translation could avoid this. Constructs like this:

~~~
Usage:
  program [-v... | -q]
~~~ 

Where `-v` stands for verbose (it can be repeated, it increases verbosity rather than just enabling it) and `-q` for quiet (disable all output) should be output to a single variable, that could be called `logLevel`.

The docopt syntax could be extended to handle this by using a construct similar to `[default= (value)]`. Something like:

~~~
Usage:
  program [-v... | -q]

Options:
  -v, --verbose    Increase logLevel [docoptc: target = logLevel]
  -q, --quiet      Disable all output [docoptc: target = logLevel; value = -1]
~~~ 

The generated hashmap/struct/type whatever will then contain a single field named "verbosity" with a directly usable value, instead of two "--verbose" and "--quiet" fields requiring manual handling.

### Values translation

Values can also require some translation. A parameter such as `-d, --depth <depth>` could be exposed as an int to the program instead of a string (this would add rudimentary automatic validation)

## Validation

### Parameters validation

Validation is a complex problem, which should probably be left outside of docoptc core. Still, validation could be *configured* from the input files, using a syntax similar to the one above. docoptc could also provide some basic validation methods, but leave the huge work of implementing validation schemas (if necessary) to the user.

A possible basic implementation could look like:

~~~
Usage:
  program [-i <input_file>] [-o <output_file>]

Options:
  -i, --input <input_file>    The file to read from [docoptc: validate = {fileExists()}]
  -o, --output <output_file>  The file to write to [docoptc: validate = {isPath() && canWrite && pathExists ? isFile : fail()}]
~~~

A list of possible primitive validation functions 

Function name   | Group | Description
----------------| ----- | -----------
`isPath`        | FS    | `true` if a string is a legal path in the filesystem. Does **not** imply `pathExists`
`pathExists`    | FS    | `true` if the path exists (`false` for broken symlinks)
`isFile`        | FS    | `true` if regular file. Implies `pathExists`
`isDir`         | FS    |
`isFile`        | FS    |
`isSymlink`     | FS    | `true` if path is a symbolic link. Does **not** imply `pathExists`
`canWrite`      | FS    |
`canRead`       | FS    |
`canExecute`    | FS    |

Compound functions may also be exposed for sake of simplicity. Eg `inputFile` as `isFile && isReadable` ; `isBrokenLink` as `isSymlink && !pathExists`, etc.

### Schema-based validation and other advanced validation method.

Docoptc's basic validation interface should be able to perform any computable test on every discrete value. That is, any test can be performed, but in isolation. Tests for consistency between two or more values does not fall in docoptc's scope.

Docoptc *may* yet expose an interface for such validations.

# Special features

## i18n with conformity check

Proper internationalization may be hard to achieve in some languages using the default docopt implementation. Docoptc may provide a way to:

  * Extract strings from docopt files to `.po` files (or to a simplified format)
  * Load localizations of a docopt file.

This second option would imply to:

  * give a way to avoid repetitions in translations, or provide a merge tool to automatically inject changes in the master file into translations. 
  * If translations are complete docopt inputs, provide a way to check that they're technically identical to the master file.

**Note**: it is assumed here that internationalization only apply to the documentation, not to the command themselves. Using parameters translation, positional placeholders may be translated as well, but it would probably be a *Very Bad Idea* to translate long command names. This is still technically feasible, using parameters translation. Eg: `-v, --verbose  Be verbose [docoptc: target=logLevel]` may become `-b, --bavard  Sois bavard [docoptc: target=logLevel]`. Yet, this is an horribly bad idea. 

# Code generation

*Use an intermediate, abstract code representation that can be translated into actual codes for different languages.*

Parsing options is a relatively trivial task. We may assume that it can be performed in strikingly similar ways in various languages. Therefore, generating a kind of pseudo-code (in the form of a generic AST) before producing actual code may be a way to limit the complexity of adding a new target language.

Adding a target language would then mean two steps: a) choosing a pseudo-code generator (there may be more than one, at least one for procedural and one for functional languages), and b) writing a series of translations between AST elements and actual code.

The following usage pattern for the imaginary `tig` program:

~~~
Usage:
  tig [-v|-q] (init <dir>|clone <url>|pull|push|help)

Options:
  -v, --verbose    Be verbose.
  -q, --quiet      Be quiet.
~~~

May then produce the following AST:

~~~
DOCOPT_CONTEXT
    DECLARE_TARGET_MAP (T_STRING ; T_BOOL)
        DECLARE_KEY "init" T_BOOL
        DECLARE_KEY "clone" T_BOOL
        DECLARE_KEY "push" T_BOOL
        DECLARE_KEY "pull" T_BOOL
        DECLARE_KEY "help" T_BOOL
        DECLARE_KEY "<dir>" T_STRING
        DECLARE_KEY "<url>" T_STRING
        DECLARE_KEY "--verbose" T_BOOL
        DECLARE_KEY "--quiet" T_BOOL
    PARSE_FUNCTION
        IF NOT_EQUALS (ARGV 0) "tig"
            FAIL ()
        LOOP (ARGV[1:]
~~~

A C generator may translate DECLARE_TARGET_MAP to `typedef struct`, translate names from `<dir>` to `DIR` and `--verbose` to `__verbose`, where a Python translator may init an `object` and a Haskell one either create a `Map` or a new type.

        


