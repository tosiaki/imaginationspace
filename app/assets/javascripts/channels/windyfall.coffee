jQuery(document).on 'turbolinks:load', ->
	windyfallPane = $("#windyfall-pane")
	resourcesPane = undefined
	preparationsPane = undefined
	things = {}
	createResourcesPane = ->
		if $('#resources-pane').length == 0
			$('<div/>', id: 'resources-pane').
				insertBefore(windyfallPane)
		resourcesPane = $("#resources-pane")
		return
	addResource = (resource) ->
		identifier = resource.replace(/\s+/g, '-').toLowerCase()
		if $('#resource-display-' + identifier).length == 0
			return $('<div/>', id: 'resource-display-' +
				identifier).appendTo(resourcesPane)
	setResource = (resource, amount) ->
		identifier = resource.replace(/\s+/g, '-').toLowerCase()
		$('#resource-display-' + identifier).text(resource + " " +
			amount)
		things[resource] = amount
	addPreparation = (display, identifier, preparation) ->
		if $('#preparations-pane').length == 0
			$('<div/>', id: 'preparations-pane').
				insertBefore(windyfallPane)
			preparationsPane = $("#preparations-pane")
		if $('button#preparation-display-' + identifier).length == 0
			button =  $('<button/>', id: 'preparation-display-' + identifier).appendTo(preparationsPane)
			button.text(display)
			button.on 'click', (event) ->
				App.windyfall.prepare preparation
	checkPreparations = ->
		if things['Green onion'] > 0 && things['Tuna'] > 0
			addPreparation("Make negitoro", "negitoro", "Negitoro")
	addExploring = ->
		if $('#exploring-pane').length == 0
			$('<div/>', id: 'exploring-pane').insertBefore(windyfallPane)
			exploringPane = $("#exploring-pane")
			button = $('<button/>', id: 'exploring-display').appendTo(exploringPane)
			button.text("Explore")
			button.on 'click', (event) ->
				App.windyfall.explore()
	checkExploring = ->
		if things['Negitoro'] > 0
			addExploring()

	App.windyfall = App.cable.subscriptions.create {
		channel: "UserChannel"
	},
	connected: ->

	disconnected: ->

	received: (data) ->
		if data['action'] == 'gather' || data['action'] == 'setup'
			createResourcesPane()
			addResource(data['thing'])
			setResource(data['thing'], data['amount'])
			checkPreparations()
			checkExploring()

		if data['action'] == 'prepare'
			addResource(data['thing'])
			setResource(data['thing'], data['amount'])
			addExploring()

		if data['action'] == 'expend'
			setResource(data['thing'], data['amount'])

		if data['action'] == 'show_preparation'
			addPreparation(data['preparation'])

	gather: (gathering) ->
		@perform 'gather', gathering: gathering
	
	prepare: (preparation) ->
		@perform 'prepare', prepare: preparation
	
	explore: ->
		@perform 'explore'
	
	$('.gather-button').on 'click', (event) ->
		App.windyfall.gather jQuery(this).data('gathering')
