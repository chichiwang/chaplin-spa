View = require './view'
ev = require 'util/events'

module.exports = class CollectionView extends Chaplin.CollectionView
	# This class doesn’t inherit from the application-specific View class,
	# so we need to borrow the method from the View prototype:
	getTemplateFunction: View::getTemplateFunction
	keepElement: true
	constructor: (options) ->
		_.extend @prototype, Chaplin.EventBroker
		@controllerId = options.controllerId or null
		@keepElement = options.keepElement if options.hasOwnProperty 'keepElement'
		@listSelector = if options.listSelector then options.listSelector else undefined
		@itemSelector = if options.itemSelector then options.itemSelector else undefined
		super

	render: ->
		super
		@publishEvent ev.mediator.view.appended, @controllerId

	dispose: ->
		return if @disposed
		@$el?.off()
		@stopListening()
		@unsubscribeAllEvents()
		@undelegateEvents()
		super