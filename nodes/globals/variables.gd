extends Node

var room_positions_available : Array[Vector2i]= []
var room_positions_taken : Array[Vector2i] = []
var rooms : Array[GameRoom] = []

var player : GamePlayer
