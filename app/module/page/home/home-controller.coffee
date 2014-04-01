Controller = require 'base/controller'

module.exports = class HomeController extends Controller
	autoRender: true
	className: 'home page'
	template: require './templates/home'