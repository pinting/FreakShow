extends Node

var http_request: HTTPRequest

func _ready() -> void:
	http_request = HTTPRequest.new()
	
	add_child(http_request)

# Report scene to the remote analytics service
func report_scene(path) -> void:
	var headers = ["Content-Type: application/json"]
	var user_id = str(OS.get_unique_id()).sha1_text()
	var query = JSON.print({
		"userId": user_id,
		"scenePath": path
	})
	
	var result = http_request.request(
		Config.REPORT_URL,
		headers,
		true,
		HTTPClient.METHOD_POST,
		query
	)
	
	Tools.debug(str("Reporting '", query, 
		"' with result '", result, "'"))
