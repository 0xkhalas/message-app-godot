extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var args = Array(OS.get_cmdline_args())
	print(args)
	
	if args.has("-s"):
		print("loading server...")
		startServer()
	else:
		print("loading client...")
		startClient()

# When Server Start
func startServer():
	print("Starting server...")
	
	# Create Callback Events
	multiplayer.peer_connected.connect(self._on_client_connected)
	multiplayer.peer_disconnected.connect(self._on_client_disconnected)
	
	# Create server
	var server = ENetMultiplayerPeer.new()
	server.create_server(8080, 2)
	multiplayer.multiplayer_peer = server
	
# When Client Start
func startClient():
	print("Starting client...")
	
	multiplayer.connected_to_server.connect(self.connected_to_server)
	multiplayer.server_disconnected.connect(self.server_from_disconnected)
	
	var client = ENetMultiplayerPeer.new()
	client.create_client("localhost", 8080)
	multiplayer.multiplayer_peer = client

# Call From Client to Server
@rpc("any_peer")
func send_message_to_server(id: int, message: String):
	if multiplayer.is_server():
		print("Message received on server: " + message)
		send_message_to_client.rpc(id, message)

# Call From Server to Clients
@rpc("authority")
func send_message_to_client(id: int, message: String):
	print("Message received on client" + message)
	var message_label = Label.new()
	message_label.text = "[" + str(id) + "]: " + message
	$Panel/AppContainer/AppMessageScroll/AppMessages.add_child(message_label)
	
# Client Callbacks
func connected_to_server():
	print("connect to server...")
	
func server_from_disconnected():
	print("disconnect to server...")

# Server Callbacks
func _on_client_connected(client_id):
	print("Client connected: " + str(client_id))
	
func _on_client_disconnected(client_id):
	print("Client disconnected: " + str(client_id))

func _on_app_button_pressed():
	send_message_to_server.rpc(multiplayer.get_unique_id(), $Panel/AppContainer/AppInput/AppText.text)
