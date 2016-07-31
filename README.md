# Coffee->JSHint

Runs your CoffeeScript source through [JSHint](http://www.jshint.com/) to check for errors.

## Installation

    npm install coffee-script -g // See package.json for supported versions (most)
    npm install coffee-jshint -g

## Usage

To check some files:

    coffee-jshint file1.coffee file2.coffee ...

### Options

JSHint takes [a bunch of options](http://www.jshint.com/docs/#options) that tell it various rules to enforce or relax. The default options relax (ignore) some rules that don't make much sense to check for JS generated by the CoffeeScript compiler.

- `eqnull`: suppresses warnings about `== null`, which CoffeeScript uses in its generated JS
- `expr` suppresses warnings about expressions in unexpected positions, which can only occur in generated JS when the CoffeeScript compiler does it on purpose
- `shadow` suppresses warnings about variable shadowing, which is fine since CoffeeScript has sane scoping rules and generates safely scoped JS that uses shadowed variables
- `-W018`: suppresses "Confusing use of '!'" (normal in compiled `switch` statements)
- `-W040`: suppresses 'Possible strict violation' (normal in compiled `Class`?)
- '-W055': suppresses 'A constructor name should start with an uppercase letter' (normal in compiled `Class`?)
- '-W058': suppresses 'Missing '()' invoking a constructor' (my preference I guess)
- '-W093': suppresses 'Did you mean to return a conditional instead of an assignment?'

To turn on more options, you can use the `--options` or `-o` flag:

    coffee-jshint -o trailing,browser,sub file1.coffee file2.coffee ...

If you really must turn off some of the default options, use the `--default-options-off` flag (you can always use `--options` to turn some back on):

    coffee-jshint --default-options-off --options undef,eqnull ...

### Globals

You'll probably get a lot of complaints from Coffee->JSHint about undefined global variables like `console`, `$`, or `require`. Depending on where you're running your code, you might want to allow a few global variables. One easy way to handle this is to use JSHint's built in [environment options](http://www.jshint.com/docs/#environments).

For instance, if you're running your code using Node.js, then you'll want to turn on the `node` option. It works like any other option:

    coffee-jshint -o node ...

If you have some globals that aren't covered by any of environments, well then you should probably check yo'self before you wreck yo'self. But if you really want to turn off warnings for some global variables, Coffee->JSHint supports it using the `--globals` or `-g` option. One use case is when using [Mocha](http://visionmedia.github.io/mocha/), a testing library:

    coffee-jshint -o node --globals describe,it ...

### Shell scripting

Coffee->JSHint plays nicely with your favorite Unix utilities. If you want to recursively search all the files in a directory, try piping in the results of a `find`. Here's an example that also uses `grep` to filter out files in `node_modules/`:

    find . -type f -path "*.coffee" | grep -v "node_modules/" | xargs coffee-jshint

### Git hook

To use Coffee->JSHint as a git pre-commit hook to check changed files before you commit, put something like this in `.git/hooks/pre-commit`:

```bash
git diff --staged --name-only | xargs coffee-jshint
if [[ $? -ne 0 ]]; then
    echo 'WARNING: You are about to commit files with coffee-jshint warnings'
    exit 1
fi
```

This will take all the files you plan to commit changes to, run them through `coffee-jshint`, and exit with status code `1` if there are any warnings (which it will also print out). If there are warnings, the commit will be aborted, but you can always do `git commit --no-verify` to bypass the hook.

## Releasing

To release a new version:

    git checkout master
    npm version <major|minor|patch>
    git push && git push --tags
    npm publish
