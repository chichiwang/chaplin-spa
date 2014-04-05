ev = require 'util/events'
db = require 'util/debouncer'

BaseView = require 'base/view'
BaseModel = require 'base/model'
BaseCollection = require 'base/collection'

module.exports = class Controller

	_.extend @prototype, Backbone.View.prototype
	_.extend @prototype, Chaplin.EventBroker

	$: Backbone.$

	transition: 'slide'
	autoResize: true

	view: null
	keepElement: null
	viewOptions: null

	events: null
	autoRender: null
	el: null
	region: null
	regions: null
	container: null
	id: null
	className: null
	tagName: null
	template: null
	stale: null

	model: null
	modelOptions: null

	collection: null
	collectionOptions: null

	itemController: null
	renderItems: null
	animationDuration: null
	listSelector: null
	itemSelector: null
	loadingSelector: null
	fallbackSelector: null
	useCssAnimation: null
	animationStartClass: null
	animationEndClass: null

	__optionNames: [
		'view', 'viewOptions',
		'model', 'modelOptions',
		'collection', 'collectionOptions',

		'events', 'autoRender',
		'el', 'region',
		'container', 'id',
		'className', 'tagName',
		'transition', 'keepElement',
		'autoResize', 'template',
		'regions',

		'itemController', 'renderItems',
		'animationDuration', 'listSelector',
		'itemSelector', 'loadingSelector',
		'fallbackSelector', 'useCssAnimation',
		'animationStartClass', 'animationEndClass'
	]

	constructor: (options = {})->
		@controllerId = new Date().getTime()
		options = _.extend {}, options

		# Copy some options to instance properties
		if options
			for optName, optValue of options when optName in @__optionNames
				this[optName] = optValue
		# Remove instance properties from options parameter
		for optName in @__optionNames
			delete options[optName]

		@__initResizeOrientation()

		# Fire the attached method once view has been attached
		@subscribeEvent ev.mediator.view.appended, (cId)->
			if cId is @controllerId
				setTimeout =>
					@attached.call @
				, 20
		
		# Begin execution
		Chaplin.mediator.execute 'region:register', this if @regions?
		@options = options
		@initialize()

	initialize: ->
		if !@view and !@template
			throw new Error 'Controller must be passed a view or a template'

		if @model
			if typeof @model isnt 'function'
				if !@model.get and typeof @model.get isnt 'function'
					throw new Error 'Model must be a class definition or class instance'

		if @collection
			if !@itemController
				throw new Error 'Collection Controllers must be passed an itemController'
			if !@itemController.prototype.view
				throw new Error 'itemController must have a view property defined'
			if @itemController.prototype.view and typeof @itemController.prototype.view isnt 'function'
				throw new Error 'itemController\'s view property must be a class definition'
			if @model and typeof @model isnt 'function'
				throw new Error 'itemController\'s model property must be a class definition'


		@render()

	__initViewOptions: =>
		viewValues = [
			'region', 'autoRender',
			'container', 'id',
			'className', 'tagName',
			'controllerId', 'keepElement',
			'animationStartClass', 'animationEndClass',
			'el', 'template'
		]

		@viewOptions = {} if !@viewOptions
		for value in viewValues
			if !@viewOptions.hasOwnProperty value
				@viewOptions[value] = this[value] if this[value] isnt null

		if @itemController
			@__initCollectionViewOptions()
	__initCollectionViewOptions: ->
		collectionViewValues = [
			'renderItems', 'animationDuration',
			'listSelector', 'itemSelector',
			'loadingSelector', 'fallbackSelector',
			'useCssAnimation'
		]

		for value in collectionViewValues
			if !@viewOptions.hasOwnProperty value
				@viewOptions[value] = this[value] if this[value] isnt null

		if @itemController.prototype.model
			@model = @itemController.prototype.model
			@itemController.prototype.model = null

		@viewOptions.itemView = @itemController

	__initModel: ->
		if typeof @model is 'function'
			modelOptions = if @modelOptions then @modelOptions else {}
			@model = new @model modelOptions
		else if @modelOptions and !@model
			@model = new BaseModel @modelOptions
		@viewOptions.model = @model if @model
	__initCollection: ->
		@collectionOptions = {} if !@collectionOptions
		@collectionOptions.model = @model if @model and typeof @model is 'function'
		if @collection and typeof @collection is "function"
			@collection = new @collection @collectionOptions
		else if @collectionOptions and !@collection
			@collection = new BaseCollection @collectionOptions
		@viewOptions.collection = @collection if @collection

	rendered: false
	render: ->
		# Gate against multiple calls to render
		return false if @rendered is true

		@__initViewOptions()
		@view = BaseView if !@view

		if (@model or @modelOptions) and not @collection
			@__initModel()
		if @collection or @collectionOptions
			@__initCollection()

		View = @view
		@view = new View @viewOptions
		@el = @view.el
		@$el = @view.$el

		if @collection or @collectionOptions
			if @model and typeof @model is 'function'
				@view.collection.model = @model

		@rendered = true

		@__reassignRender()

	__reassignRender: ->
		@render = @view.render

	attached: ->
		# Executes once view has been attached to DOM

	# Composer Methods
	reuse: (name)->
		method = if arguments.length is 1 then 'retrieve' else 'compose'
		Chaplin.mediator.execute "composer:#{method}", arguments...

	compose: ->
		throw new Error 'Controller#compose was moved to Controller#reuse'

	# Resize handlers
	debounceDuration: 0
	resize: ->
		# Default resize handler for module
	__delegateResize: (e)->
		return false if @autoResize is false
		if @debounceDuration is 0
			@resize()
			return true
		else
			resizeFn = @resize.bind @
			db.gate resizeFn

	# Orientation-change handlers
	__initResizeOrientation: ->
		@subscribeEvent ev.mediator.view.appended, (cId)->
			if cId is @controllerId
				setTimeout @__onceAttached, 20

		if @debounceDuration > 0
			db.init debounceDuration: @debounceDuration

		@subscribeEvent ev.mediator.resize, @__delegateResize
		@subscribeEvent ev.mediator.orientation, @orientation

	orientation: ->
		# Default orientation-change handler

	initialOrientation: false
	__onceAttached: =>
		@resize()
		if @initialOrientation
			$(window).trigger ev.all.orientationchange

	# Disposal Methods
	disposed: false

	dispose: ->
		return if @disposed

		@$el?.off()
		@stopListening()
		@unsubscribeAllEvents()
		@undelegateEvents()

		@el = null

		for own prop, obj of this when obj and typeof obj.dispose is 'function'
			obj.dispose()
			delete this[prop]

		@unsubscribeAllEvents()
		@stopListening()
		@disposed = true

		Object.freeze? this