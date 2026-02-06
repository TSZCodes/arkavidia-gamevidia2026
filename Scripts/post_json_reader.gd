extends Node

const JSON_FILE = "res://data/tweets.json"

func load_tweets_as_resources() -> Array[TweetData]:
	var repo_list: Array[TweetData] = []
	
	# 1. Load the raw text
	if not FileAccess.file_exists(JSON_FILE):
		printerr("JSON file missing!")
		return []
		
	var file = FileAccess.open(JSON_FILE, FileAccess.READ)
	var text_content = file.get_as_text()
	
	# 2. Parse JSON
	var json = JSON.new()
	var error = json.parse(text_content)
	
	if error != OK:
		printerr("JSON Error: ", json.get_error_message())
		return []

	var raw_array = json.data
	
	# 3. Convert Dictionary -> Resource
	for item in raw_array:
		var new_tweet = TweetData.new()
		
		# --- Common Data ---
		new_tweet.is_repost = item["is_repost"]
		new_tweet.timestamp = item["timestamp"]
		new_tweet.likes = item["likes"]
		new_tweet.retweets = item["retweets"]
		new_tweet.comments = item["comments"]
		new_tweet.views = item["views"]
		new_tweet.bookmarks = item["bookmarks"]
		
		# --- Specific Data logic ---
		if new_tweet.is_repost:
			# Map the "Repost" fields
			new_tweet.user_handle = item["repost_author"]
			new_tweet.content_text = item["repost_content"]
			
			# Map the nested Original Tweet
			var orig = item["original_tweet"]
			new_tweet.original_author = orig["author"]
			new_tweet.original_text = orig["content"]
		else:
			# Map the "Normal" fields
			new_tweet.user_handle = item["author"]
			new_tweet.content_text = item["content"]
			
		repo_list.append(new_tweet)
		
	return repo_list
