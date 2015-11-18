# DocoptC

Docoptc will be a compiler for the [Docopt syntax](http://docopt.org/). Unlike most Docopt implementations, Docoptc is meant to be used at building time to generate command-line arguments parsing code in virtually any target language. 

I'm currently planning the following features, in possible order of implementation:

 1. Full support for the DocOpt syntax.

 2. Target Haskell, Python and C

 3. Localization of messages, including `--help` screens, with consistency checking (all localized versions must expose exactly the same interface)

Some extra syntax is being considered:

 4. Support for setting defaults at runtime:

 ~~~
 -j, --jobs <int>  Number of parallel jobs to execute [default: {{cpuCount}}]
 --locale <name>   Locale for generated documents [default: {{systemLocale}}]
 ~~~

 5. Dedicated subcommands mechanism

 6. Parameters translation (eg, mapping both `--verbose` and `--quiet` to a single `verbosity` variable)

 7. Validation.
