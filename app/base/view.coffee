require 'lib/view-helper' # Just load the view helpers, no return value
ev = require 'util/events'

module.exports = class View extends Chaplin.View
	# Auto-save `template` option passed to any view as `@template`.
	optionNames: Chaplin.View::optionNames.concat ['template']
	keepElement: true

	constructor: (options)->
		_.extend @prototype, Chaplin.EventBroker
		@controllerId = options.controllerId or null
		@keepElement = options.keepElement if options.hasOwnProperty 'keepElement'
		super

	attach: ->
		super
		@publishEvent ev.mediator.view.appended, @controllerId

	# Precompiled templates function initializer.
	getTemplateFunction: ->
		@template

	dispose: ->
		@$el?.off()
		@unsubscribeAllEvents()
		super