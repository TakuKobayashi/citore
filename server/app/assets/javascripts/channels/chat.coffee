App.chat = App.cable.subscriptions.create "ChatChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log(data)

  send_message: (message) ->
    @perform 'send_message', message: message

$(document).on 'keypress',
  '[data-behavior~=message_sender]', (event) ->
     if event.keyCode is 13
       App.chat.send_message event.target.value
       event.target.value = ''
       event.preventDefault()