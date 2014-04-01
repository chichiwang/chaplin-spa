SiteController = require 'module/base/site/site-controller'

module.exports = class Assembler extends Chaplin.Controller
	# Reusabilities persist stuff between controllers.
	# You may also persist models etc.
	beforeAction: ->
		@reuse 'site', SiteController

	dispose: ->
		@unsubscribeAllEvents()
		super