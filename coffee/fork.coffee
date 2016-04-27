# combinators
# support <cmd> & <cmd>, ;, &&, ||, !, |

class ChildProcess
  constructor: (@cmd, @args, @opts) ->
    @next = null
    @negate = no
    @pipeProc = null
  semicolon: (proc) ->
    if @next? then @next.proc.semicolon proc
    else
      @next = {proc}
      @
  doubleAmp: (proc) ->
    if @next? then @next.proc.doubleAmp proc
    else
      @next =
        proc: proc
        cond: (code) -> code is 0
      @
  doublePipe: (proc) ->
    if @next? then @next.proc.doublePipe proc
    else
      @next =
        proc: proc
        cond: (code) -> code isnt 0
      @
  exclamationPoint: ->
    @negate = not @negate
    @
  pipe: (proc) ->
    if @pipeProc? then @pipeProc.pipe proc
    else
      @pipeProc = proc
      @
  spawn: (inStream, outStream, cb) -> @proc.on 'exit', cb
