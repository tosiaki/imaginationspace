jQuery(document).on 'turbolinks:load', ->
	windyfallPane = $("#windyfall-pane")
	resourcesPane = undefined
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

	App.windyfall = App.cable.subscriptions.create {
		channel: "UserChannel"
	},
	connected: ->

	disconnected: ->

	received: (data) ->
		createResourcesPane()
		addResource(data['thing'])
		setResource(data['thing'], data['amount'])

	gather: (gathering, identifier) ->
		@perform 'gather', gathering: gathering
	
	$('.gather-button').on 'click', (event) ->
		App.windyfall.gather jQuery(this).data('gathering')
