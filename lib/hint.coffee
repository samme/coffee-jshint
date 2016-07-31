fs = require 'fs'
CoffeeScript = require 'coffee-script'
_ = require 'underscore'
jshint = require('jshint').JSHINT

defaultOptions = [
             # ADD warnings
             # http://jshint.com/docs/options/#enforcing-options
  'undef'
             # REMOVE warnings
             # http://jshint.com/docs/options/#relaxing-options
  'eqnull'   # Normal CS output
  'expr'     # Normal CS output?
  'shadow'   # Normal CS output; triggered by `function ClassName()`
             # REMOVE more warnings
             # https://github.com/jshint/jshint/blob/master/src/messages.js
  '-W018'    # "Confusing use of '!'"
             # Triggered by `switch !(false)`
  '-W040'    # 'Possible strict violation'
             # Triggered by `this.constructor = child;`?
  '-W055'    # 'A constructor name should start with an uppercase letter'
             # Triggered by `new ctor` etc.?
  '-W058'    # 'Missing '()' invoking a constructor.'
             # Cf. coffeelint `non_empty_constructor_needs_parens`
  '-W093'    # 'Did you mean to return a conditional instead of an assignment?'
]
errorsToSkip = [
  "Confusing use of '!'." # W018? Normal CS output
  # "Wrap the /regexp/ literal in parens to disambiguate the slash operator."
  # Obsolete?
  # Cf. E014 "A regular expression literal can be confused with '/='."
]

# If log is true, prints out results after processing each file
hintFiles = (paths, config, log) ->
  options = buildTrueObj(
    if config.withDefaults
    then _.union config.options, defaultOptions
    else config.options)
  _.map paths, (path) ->
    try
      source = fs.readFileSync(path)
    catch err
      if config.verbose then console.log "Error reading #{path}"
      return []
    errors = hint source, options, buildTrueObj config.globals
    if log and errors.length > 0
      console.log "--------------------------------"
      console.log formatErrors path, errors
    errors

hint = (coffeeSource, options, globals) ->
  csOptions = sourceMap: true, filename: "doesn't matter"
  {js, v3SourceMap, sourceMap} = CoffeeScript.compile coffeeSource.toString(), csOptions
  if jshint js, options, globals
    []
  else if not jshint.errors?
    console.log "jshint didn't pass but returned no errors"
    []
  else
    _.chain(jshint.errors)
      # Last jshint.errors item could be null if it bailed because too many errors
      .compact()
      # Convert errors to use coffee source locations instead of js locations
      .map (error) ->
        try [line, col] = sourceMap.sourceLocation [error.line - 1, error.character - 1]
        _.extend error,
          line: if line? then line + 1 else '?'
          character: if col? then col + 1 else '?'
      # Get rid of errors that don't apply to coffee very well
      .filter (error) ->
        not _.any errorsToSkip, (to_skip) -> error.reason.indexOf(to_skip) >= 0
      .value()

formatErrors = (path, errors) ->
  "#{path}\n" +
  _(errors)
    .map (error) ->
      "#{error.line}:#{error.character}: #{error.reason}"
    .join('\n')

buildTrueObj = (keys) ->
  _.object keys, (true for i in [0..keys.length])

module.exports = hintFiles
