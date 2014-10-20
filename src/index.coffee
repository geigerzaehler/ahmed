pmap = require('when').map


# Create an AMD loader from a definition loader
#
# req = amd(loader)
# req(['a', 'b/x'].then((a, x) -> true)
#
# A *loader* is a function that accepts an AMD ID and returns a *module
# definition*. This is an object with the following keys
#
# * `loadDeps` A function that promises an array of module definitions
#   for the dependencies
# * `factory` A function that accepts an array of evaluated
#   dependencies and returns the export for that module.
#
module.exports = amd = (load)->

  require = ({loadDeps, factory})->
    pmap(loadDeps(), require)
    .then(factory)


  externalRequire = (deps)->
    defs = pmap(deps, (id)-> load(id))
    pmap(defs, require)
