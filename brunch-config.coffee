exports.config =
	# See http://brunch.io/#documentation for docs.
	files:
		javascripts:
			joinTo:
				'javascripts/app.js': /^app/
				'javascripts/vendor.js': /^(?!app)/

		stylesheets:
			joinTo: 'stylesheets/app.css'

		templates:
			joinTo: 'javascripts/app.js'

	plugins:
		coffeelint:
			pattern: /^app\/.*\.coffee$/
			options:
				no_empty_param_list:
					level: 'error'
				no_tabs:
					level: 'ignore'
				indentation:
					level: 'ignore'
				max_line_length:
					level: 'ignore'
				no_unnecessary_fat_arrows:
					level: 'error'
				no_backticks:
					level: 'ignore'
