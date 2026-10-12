extends Node

const IP_ADDRESS : String = "89.22.103.127"
const PORT : int = 42069

var peer : ENetMultiplayerPeer

func start_server() ->void:

    peer = ENetMultiplayerPeer.new()
    peer.create_server(PORT)
    multiplayer.multiplayer_peer = peer
    print("Start Server - peer: ", peer.get_unique_id())
func start_client() ->void:

    peer  = ENetMultiplayerPeer.new()
    peer.create_client( IP_ADDRESS,PORT)
    multiplayer.multiplayer_peer = peer
    print("Start Client - peer: ", peer.get_unique_id())