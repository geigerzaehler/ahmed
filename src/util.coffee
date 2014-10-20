module.exports = exports = {}

# Take a function that is called with a definition and return a
# function that can be called like an AMD define. It converts the
# values and passes it to the original function.
#
# @type (definition -> any) -> (id? -> [string]? -> factory -> void)
exports. normalizeDefine = (fn)->
  (args...)->
    factoryOrValue = args.pop()
    if typeof factoryOrValue == 'function'
      baseFactory = factoryOrValue
    else
      baseFactory = -> factoryOrValue

    deps = args.pop() || []
    if typeof deps == 'string'
      id = deps
      deps = []
    else
      id = args.pop()

    factory = (args)-> baseFactory(args...)
    fn({id, deps, factory})



# Resolve an AMD ID `b` with respect to `a`.
#
#   resolveAmdId(x, 'absolute/id') == 'absolute/id')
#   resolveAmdId('base/x', './relative/id') == 'base/relative/id'
#   resolveAmdId('base/x/y', '../up/id') == 'base/up/id'
#
exports.resolveAmdId = (a, b)->
  b = b.split('/')
  r = a.split('/')
  if b[0] == '.'
    r.pop()
  else if b[0] == '..'
    r.pop()
    r.pop()
  else
    r = []

  for x in b
    if x == '.'
      continue
    else if x == '..'
      r.pop()
    else
      r.push(x)

  return r.join('/')


# Higher order function utilities

exports.apply = (xs...)->
  (fn)-> fn(xs...)


exports.partial = (fn, xs...)->
  (ys...)-> fn(xs.concat(ys)...)


exports.memoize = (fn)->
  cache = {}
  (args...)->
    cache[args.join()] ||= fn(args...)


exports.curry = (fn)->
  (args...)->
    if args.length < fn.length
      return partial(fn, args...)
    else
      return fn(args...)
