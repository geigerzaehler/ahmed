# Contains some very basic definition loaders


Path = require('path')

w = require('when')
pmap = w.map
pany = w.any
pall = w.all
ptry = w.try
resolved = w.resolve
rejected = w.reject

{normalizeDefine, resolveAmdId} = require('./util')


module.exports = exports = {}


exports.nodeFileLoader = (baseDir, nodeRequire = require)->
  load = (id, parentLoad = load)->
    ptry ->
      file = Path.resolve(baseDir, id)
      defs = withGlobalDefineRegistry ->
        nodeRequire(file)

      if not defs.length
        throw Error("No module defined in #{file}")
      {deps, factory} = defs.pop()
      loadDeps = -> pmap deps, (d)->
        parentLoad(resolveAmdId(id, d), load)
      def = {loadDeps, factory, id}


exports.mapLoader = (loadMap, defaultLoad)->
  load = (id)->
    ptry ->
      for pattern, mappedLoad of loadMap
        if id.indexOf(pattern) == 0
          return mappedLoad(id, load)
      defaultLoad(id, load)


exports.nodeModuleLoader = (baseDir, nodeRequire = require)->
  baseDir = Path.resolve(baseDir)

  modulePaths = (path)->
    paths = []
    path.split('/').reduce (dir, part)->
      paths.push Path.join('/', dir, part, 'node_modules')
      Path.join(dir, part)
    return paths.reverse()

  load = (id, parentLoad = load)->
    ptry ->
      basePaths = [baseDir].concat(modulePaths(baseDir))
      basePaths.reduce (loaded, basePath)->
        loaded.catch -> exports.nodeFileLoader(basePath, nodeRequire)(id, load)
      , rejected()



# Call the function in a context with a global `define` function that
# registers all calls to it. Return the list of registered defines.
withGlobalDefineRegistry = (fn)->
  originalDefine = global.define

  definitions = []
  global.define = normalizeDefine (def)->
    definitions.push(def)

  fn()

  global.define = originalDefine
  return definitions
