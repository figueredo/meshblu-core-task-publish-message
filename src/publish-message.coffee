_ = require 'lodash'
http = require 'http'

class PublishMessage
  constructor: (options={}) ->
    {
      @firehoseClient
      @uuidAliasResolver
    } = options

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {toUuid, messageType} = request.metadata

    @uuidAliasResolver.resolve toUuid, (error, toUuid) =>
      return callback error if error?

      message = request.rawData
      @_send {toUuid, messageType, message}, (error) =>
        return callback error if error?
        return @_doCallback request, 204, callback

  _send: ({toUuid,messageType,message}, callback=->) =>
    @firehoseClient.publish "#{messageType}:#{toUuid}", message, callback

module.exports = PublishMessage
