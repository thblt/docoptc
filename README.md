# DocoptC

Docoptc will be a compiler for the [Docopt syntax](http://docopt.org/). Unlike most Docopt implementations, Docoptc is meant to be used during a build to generate command-line arguments parsing code in (potentially) any target language. 

I'm writing DocOptC to learn Haskell, so don't expect any seriously usable code anytime soon.

I'm currently planning the following features, in possible order of implementation:

 1. Full support for the DocOpt syntax.

 2. Target Haskell, Python and C

 3. [Syntax extensions](https://github.com/thblt/docoptc/blob/master/doc/DesignNotes.org)
