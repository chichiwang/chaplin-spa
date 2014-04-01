#Input strings
device = require './device'
touch = device.supports 'touch'

inputEvents =
	# Mouse-and-Touch Events
	all:
		click  : 'click'
		blur   : 'blur'
		focus  : 'focus'
		resize : 'resize'
		scroll : 'scroll'
		orientationchange : 'orientationchange'
	# Media events
	media:
		videoend : 'ended'
		audioend : 'ended'
	mediator:
		# Events for Chaplin's mediator (pub/sub)
		resize : 'window:resize' # Fires when window level resize occurs
		orientation : 'window:orientation' # Fires when orientation change occurs
		blur : 'window:blur' # Fires when window loses focus
		focus : 'window:focus' # Fires when window gains focus

		view:
			appended: 'view:append' # Fires when a view has been appended to the DOM

module.exports = inputEvents