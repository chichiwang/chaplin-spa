DebounceUtil = class Debouncer
	defaults :
		debounceDuration : 100
		lastTime : undefined
		lastTimeHit : undefined
		buffer: 150

	init : (options)->
		@settings = {}
		_.extend(@settings, @defaults, options)
		@settings.lastTime = new Date().getTime()
	gate : (fn)->
		# Gate the firing of the function passed in
		currentTime = new Date().getTime()
		@settings.lastTimeHit = currentTime
		lastTimeHit = currentTime
		# Line up Final Function Call
		setTimeout =>
			if @settings.lastTimeHit is lastTimeHit
				@settings.lastTime = currentTime
				fn()
		,@settings.debounceDuration + @settings.buffer

		if currentTime - @settings.lastTime < @settings.debounceDuration
			return false
		@settings.lastTime = currentTime
		fn()


module.exports = new DebounceUtil