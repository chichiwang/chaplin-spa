Controller = require 'base/controller'

module.exports = class SiteController extends Controller
	autoRender: true
	container: 'body'
	id: 'Site-Container'
	regions:
		header: '#Site-Header'
		main: '#Page-Container .page-wrapper'
	template: require './templates/site'

	resize: ->
		headerH = @$('#Site-Header').outerHeight()
		winH = $(window).height()

		contentH = winH - headerH

		@$('#Page-Container').css 'height', contentH