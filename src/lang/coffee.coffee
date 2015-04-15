# RiveScript.js
#
# This code is released under the MIT License.
# See the "LICENSE" file for more information.
#
# http://www.rivescript.com/
"use strict"

coffee = require "coffee-script"

##
# CoffeeObjectHandler (RiveScript master)
#
# CoffeeScript Language Support for RiveScript Macros. This language is not
# enabled by default; to enable CoffeeScript object macros:
#
#    CoffeeObjectHandler = require "rivescript/lang/coffee"
#    $bot->setHandler("coffee", CoffeeObjectHandler);
##
class CoffeeObjectHandler
  constructor: (master) ->
    @_master  = master
    @_objects = {}

  ##
  # void load (string name, string[] code)
  #
  # Called by the RiveScript object to load CoffeeScript code.
  ##
  load: (name, code) ->
    # We need to make a dynamic JavaScript function.
    console.log "PROCESS COFFEE:"
    console.log code
    source = "this._objects[\"" + name + "\"] = function(rs, args) {\n" \
      + coffee.compile(code.join("\n"), {bare: true}) \
      + "}\n"

    console.log "================="
    console.log source
    console.log "================="

    try
      eval source
    catch e
      @_master.warn "Error evaluating JavaScript object: " + e.message

  ##
  # string call (RiveScript rs, string name, string[] fields)
  #
  # Called by the RiveScript object to execute JavaScript code.
  ##
  call: (rs, name, fields, scope) ->
    # We have it?
    if not @_objects[name]
      return "[ERR: Object Not Found]"

    # Call the dynamic method.
    func = @_objects[name]
    reply = ""
    try
      reply = func.call(scope, rs, fields)
    catch e
      reply = "[ERR: Error when executing JavaScript object: #{e.message}]"

    # Allow undefined responses.
    if reply is undefined
      reply = ""

    return reply

module.exports = CoffeeObjectHandler
