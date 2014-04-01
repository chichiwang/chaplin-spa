Layout = require 'layout'
ev = require './util/events'

# The application object.
module.exports = class Application extends Chaplin.Application
	start: ->
		_.extend @prototype, Chaplin.EventBroker
		# Initialize the Application's resize handler
		$(window).on ev.all.resize, @resize
		$(window).on ev.all.orientationchange, @orientation
		$(window).on 'hashchange', @temporaryreadystate
		$(window).blur @onBlur
		$(window).focus @onFocus
		@temporaryreadystate()
		super
	# Replace the default Chaplin Layout object with our own custom Layout object
	initLayout: (options = {}) ->
		options.title ?= @title
		@layout = new Layout options
	# Publish a window resize event, pass along event object
	resize: (e)=>
		@publishEvent ev.mediator.resize, e
	# Publish a orientation change event, pass along event object and orientation detection
	orientation: (e)=>
		currOrientation = undefined
		winH = $(window).outerHeight()
		winW = $(window).outerWidth()
		currOrientation = if winH > winW then 'portrait' else 'landscape'
		@publishEvent ev.mediator.orientation, e, currOrientation
	onBlur: =>
		@publishEvent ev.mediator.blur
	onFocus: =>
		@publishEvent ev.mediator.focus
	temporaryreadystate: ->
		$('body').removeClass('snapshot_ready')
		setTimeout ->
			$('body').addClass('snapshot_ready')
		, 2000