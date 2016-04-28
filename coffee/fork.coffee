# combinators
# support <cmd> & <cmd>, ;, &&, ||, !, |

# TODO: use Object.create and prototypes, don't modify the original object!

{spawn} = require 'child_process'

syms =
  then: Symbol()
  and: Symbol()
  or: Symbol()
  async: Symbol()
  pipe: Symbol()

class ChildProcess
  constructor: (@cmd, @args, @opts) ->
    @next = null
    @negate = no

  for k, v of syms
    do (k, v) -> @prototype[k] = (proc) ->
      ret = Object.create @
      ret.next =
        if ret.next?
          proc: ret.next.proc[k] proc
          type: ret.next.type
        else
          proc: proc
          type: v
      ret

  not: ->
    ret = Object.create @
    ret.negate = not ret.negate
    ret

  spawn: (inStream, outStream, cb) ->
    proc = spawn @cmd, @args, @opts
    nextCb = switch @next?.type
      when syms.then then -> @next.proc.spawn inStream, outStream, cb
      when syms.and then (code) ->
        if code is 0 then @next.proc.spawn inStream, outStream, cb
        else
          nextNext = @next.proc.next
          if nextNext?.proc
      when syms.or then
      when syms.async then
      when syms.pipe then
