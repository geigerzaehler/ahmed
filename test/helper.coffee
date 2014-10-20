fs = require('fs.extra')
{resolve, dirname} = require('path')

exports = module.exports = {}


exports.writeModule = (path, deps, factory)->
  if not factory?
    factory = deps
    deps = []
  if deps.length
    depsString = "['" + deps.join("', '") + "'], "
  else
    depsString = ""

  content = "define(#{depsString}#{factory.toString()});"
  p = fixtureDir(path) + '.js'
  fs.mkdirpSync(dirname(p))
  fs.writeFileSync p, content
  return content


exports.createFixtureDir = ->
  fs.mkdirSync(fixtureDir())


exports.deleteFixtures = ->
  fs.rmrfSync(fixtureDir())


exports.fixtureDir = fixtureDir = (path = '')->
  resolve('test/fixtures', path)


