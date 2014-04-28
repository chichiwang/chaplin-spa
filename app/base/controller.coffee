ev = require 'util/events'
# db = require 'util/debouncer'

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
	containerMethod: null
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

	constructor: (options = {})->
		@controllerId = _.uniqueId()
		options = _.cloneDeep options

		# Copy some options to instance properties
		_.forOwn options, (val, key)->
				this[key] = _.cloneDeep val
		, @

		@__initResizeOrientation()
		# Fire the attached method once view has been attached
		@subscribeEvent ev.mediator.view.appended, (cId)->
			if cId is @controllerId
				setTimeout =>
					@attached.call @
				, 20
		
		# Begin execution
		Chaplin.mediator.execute 'region:register', this if @regions?
		@options = _.cloneDeep options
		@initialize()

	initialize: ->
		if !@view and !@template
			throw new Error 'Controller must be passed a view or a template'

		if @collection
			if !@itemController
				throw new Error 'Collection Controllers must be passed an itemController'
			if !@itemController.prototype.view or !@itemController.prototype.template
				throw new Error 'itemController must have a view or template property defined'
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
			if not _.contains @viewOptions, value
				@viewOptions[value] = _.cloneDeep(this[value]) if this[value] isnt null

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
			if not _.contains @viewOptions, value
				@viewOptions[value] = this[value] if not _.isNull(this[value])

		if @itemController.prototype.model
			@model = _.cloneDeep(@itemController.prototype.model)
			@itemController.prototype.model = null

		@viewOptions.itemView = _.cloneDeep(@itemController)

	__initModel: ->
		model_is_class = _.isFunction(@model) and typeof @model.prototype.constructor is 'function'
		model_is_instance = @model instanceof window.Backbone.Model
		model_is_options = _.isObject(@model) and !model_is_instance and not _.isNull(@model)

		if model_is_class
			modelOptions = if @modelOptions then _.cloneDeep(@modelOptions) else {}
			@model = new @model modelOptions
		else if model_is_options
			@model = new BaseModel @model
		else if @modelOptions and !@model
			@model = new BaseModel _.cloneDeep(@modelOptions)
		@viewOptions.model = @model if not _.isNull(@model)
	__initCollection: ->
		@collectionOptions = {} if _.isNull(@collectionOptions)
		@collectionOptions.model = _.cloneDeep(@model) if @model and _.isFunction @model
		if @collection and _.isFunction @collection
			@collection = new @collection _.cloneDeep(@collectionOptions)
		else if @collectionOptions and !@collection
			@collection = new BaseCollection _.cloneDeep(@collectionOptions)
		@viewOptions.collection = @collection if not _.isNull(@collection)

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
		@$ = @view.$

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
		@resize()

	# Orientation-change handlers
	__initResizeOrientation: ->
		@subscribeEvent ev.mediator.view.appended, (cId)->
			if cId is @controllerId
				setTimeout @__onceAttached, 20

		if @debounceDuration > 0
			@resize = _.throttle @resize, @debounceDuration

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
		@$('*').off()
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