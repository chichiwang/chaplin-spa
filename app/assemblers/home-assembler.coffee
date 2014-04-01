Assembler = require 'base/assembler'
Header = require 'module/base/header/header-controller'

Home = require 'module/page/home/home-controller'

module.exports = class HomeAssembler extends Assembler

	beforeAction: ->
		super
		@reuse 'header', Header, region: 'header'

	index: (options)->
		@Page = new Home region: 'main'