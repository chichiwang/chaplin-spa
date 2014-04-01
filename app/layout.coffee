# Layout modified to allow tansitions between pages
transition = require "util/transition"

module.exports = class Layout extends Chaplin.Layout
	initialize: ->
		super
		@subscribeEvent 'beforeControllerDispose', @beforeDisposeHandler
		@subscribeEvent 'dispatcher:dispatch', @dispatchHandler
		@subscribeEvent 'PageTransitionEnd', @removeAllDisposedViews

	removeAllDisposedViews: (views)->
		$('.garbage').each (index, el) ->
			$(el).remove()

	beforeDisposeHandler: (assembler)->
		@oldViewEl = assembler.presenter?.currentUnit?.el?
	dispatchHandler: (assembler)->
		upcomingEl = assembler.presenter?.currentUnit?.el?
		if @oldViewEl
			options =
				current: @oldViewEl
				upcoming: upcomingEl
			transitionMethod = assembler.presenter.currentUnit.transition
			# flag the old view for collection
			$(@oldViewEl).addClass 'garbage'
			if _.isFunction transitionMethod
				fn = transitionMethod
			else if _.isString transitionMethod
				fn = transition[transitionMethod]
			if fn?
				fn options
		else
			$(upcomingEl).addClass 'current'