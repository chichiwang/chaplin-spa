Controller = require 'base/controller'

module.exports = class HeaderController extends Controller
	autoRender: true
	template: require './templates/header'
	className: 'site-header'