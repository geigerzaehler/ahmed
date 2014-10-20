{writeModule, deleteFixtures, createFixtureDir, fixtureDir} = require('./helper')
{expect} = require('chai')
vm = require('vm')
fs = require('fs')

amd = require('../src')
loaders = require('../src/loaders')

mockRequire = (path)->
  path = require.resolve(path)
  vm.runInThisContext(fs.readFileSync(path, 'utf8'))

fileLoader = (base = '')->
  loader = loaders.nodeFileLoader(fixtureDir(base), mockRequire)

id = (x)-> x


beforeEach -> createFixtureDir()
afterEach  -> deleteFixtures()


describe 'file loader', ->

  beforeEach ->
    @req = amd(fileLoader())

  it 'loads a single module', ->
    writeModule('a', -> 'this is a')
    @req(['a']).then(([a])-> expect(a).to.equal('this is a'))

  it 'loads a second single module', ->
    writeModule('a', -> 'this is a')
    @req(['a']).then(([a])-> expect(a).to.equal('this is a'))

  it 'loads a nested dependency', ->
    writeModule('a', ['dir/b'], (b)-> b)
    writeModule('dir/b', -> 'this is b')
    @req(['a']).then(([a])-> expect(a).to.equal('this is b'))

  it 'loads a relative module', ->
    writeModule('a', ['dir/b'], (b)-> b)
    writeModule('dir/b', ['./c'], (c)-> c)
    writeModule('dir/c', -> 'this is c')
    @req(['a']).then(([a])-> expect(a).to.equal('this is c'))

  it 'loads a relative parent module', ->
    writeModule('a', ['dir/b'], (b)-> b)
    writeModule('dir/b', ['../c'], (c)-> c)
    writeModule('c', -> 'this is c')
    @req(['a']).then(([a])-> expect(a).to.equal('this is c'))

  it 'loads the top module', ->
    writeModule('', -> 'this is a')
    @req(['']).then(([a])-> expect(a).to.equal('this is a'))


describe 'map loader', ->

  beforeEach ->
    @req = amd loaders.mapLoader
      a: fileLoader('dira')
      b: fileLoader('dirb')
    , fileLoader('default')


  it 'loads from directories', ->
    writeModule('dira/a', ['b/b2'], id)
    writeModule('dirb/b/b2', -> 'this is b')
    @req(['a']).then(([a])-> expect(a).to.equal('this is b'))

  it 'loads default', ->
    writeModule('dira/a', ['c'], id)
    writeModule('default/c', -> 'this is c')
    @req(['a']).then(([a])-> expect(a).to.equal('this is c'))


describe 'node_modules loader', ->

  beforeEach ->
    @req = amd loaders.nodeModuleLoader(fixtureDir(), mockRequire)

  it 'loads single file', ->
    writeModule('a', -> 'this is a')
    @req(['a']).then(([a])-> expect(a).to.equal('this is a'))

  it 'loads from node_modules', ->
    writeModule('a', ['b'], id)
    writeModule('node_modules/b', -> 'this is b')
    @req(['a']).then(([a])-> expect(a).to.equal('this is b'))
