module.exports = [

           # ADD warnings
           # http://jshint.com/docs/options/#enforcing-options

  'undef'

           # REMOVE warnings
           # http://jshint.com/docs/options/#relaxing-options

  'eqnull' # Normal CS output
  'expr'   # Normal CS output?
  'shadow' # Normal CS output; triggered by `function ClassName()`

           # REMOVE warnings
           # https://github.com/jshint/jshint/blob/master/src/messages.js

  '-W018'  # "Confusing use of '!'"
           # Triggered by `switch !(false)`
  '-W040'  # 'Possible strict violation'
           # Triggered by `this.constructor = child;`?
  '-W055'  # 'A constructor name should start with an uppercase letter'
           # Triggered by `new ctor` etc.?
  '-W058'  # 'Missing '()' invoking a constructor.'
           # Cf. coffeelint `non_empty_constructor_needs_parens`
  '-W093'  # 'Did you mean to return a conditional instead of an assignment?'

]
