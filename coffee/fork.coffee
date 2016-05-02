# combinators
# support <cmd> & <cmd>, ;, &&, ||, !, |

# TODO: use Object.create and prototypes, don't modify the original object!

{spawn} = require 'child_process'

connectors = [
  'then'
  'and'
  'or'
  'pipe'
]

prototypeMacro = (that, f) -> (args...) ->
  ret = Object.create(that)
  f.apply(ret, args)
  ret

class ChildProcess
  constructor: (@cmd, @args, @opts, @inF, @outF, @errF) ->
    @next = null
    @negate = no
    @async = null

  for connector in connectors
    do (connector) => @prototype[connector] = (proc) -> do prototypeMacro @, ->
      @next =
        if @next?
          proc: @next.proc[connector] proc
          type: @next.type
        else
          proc: proc
          type: connector

  not: -> do prototypeMacro @, -> @negate = not @negate

  async: (asyncCmd) -> do prototypeMacro @, -> @async = asyncCmd

  setInStream: (strF) -> do prototypeMacro @, -> -> @inF = strF

  # a series of && will all fail to start if a preceding command ends with a
  # non-zero exit code. a series of || will run all commands until one
  # succeeds. this finds the next appropriate command to spawn.
  findNextAfterErrorCode: (code) ->
    switch @next?.type
      when 'and'
        if code is 0 then @next.proc
        else @next.proc.findNextAfterErrorCode code
      when 'or'
        if code isnt 0 then @next.proc
        else @next.proc.findNextAfterErrorCode code
      when 'then' then @next.proc
      when 'async' then @next.proc
      when 'pipe' then @next.proc.findNextAfterErrorCode code
      else null

  spawn: (asyncRegistry, cb) ->
    inStream = @inF()
    outStream = @outF()
    errStream = @errF()
    proc = spawn @cmd, @args, @opts
    inStream.pipe proc.stdin if inStream?
    shouldPipeOut = outStream?
    proc.stdout.pipe outStream if shouldPipeOut
    proc.stderr.pipe errStream if errStream?
    if @async?
      asyncRegistry.register @
      switch @async
        when yes then process.nextTick cb
        else @async.spawn asyncRegistry, cb
    switch @next?.type
      when 'pipe'
        proc.stdout.unpipe outStream if shouldPipeOut
        np = @next.proc.setInStream proc.stdout
        np.spawn asyncRegistry, cb
      when 'and', 'or', 'then'
        proc.on 'exit', (code) =>
          code = if not @negate then code else switch code
            when 0 then 1
            else 0
          next = @findNextAfterErrorCode code
          if next? then next?.spawn(asyncRegistry, cb)
          else process.nextTick -> cb code
      else proc.on 'exit', (code) -> process.nextTick -> cb code
