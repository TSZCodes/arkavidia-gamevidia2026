extends Control

@export var author : Label
@export var author_repost : Label
@export var account : Label
@export var account_repost : Label
@export var content : Label
@export var content_repost : Label
@export var repost_control : Control

func _ready():
	# 1. Get the converted list
	var all_tweets = PostJsonReader.load_tweets_as_resources()
	var rand_tweet = all_tweets[randi_range(0, all_tweets.size() - 1)]
	create_post(rand_tweet)

func create_post(data: TweetData):
	if data.is_repost:
		repost_control.visible = true
		author.text = data.user_handle
		author_repost.text = data.original_author
		account.text = data.timestamp
		account_repost.text = data.timestamp
		content.text = data.original_text
		content_repost.text = data.content_text
	else:
		repost_control.visible = false
		author_repost.text = data.user_handle
		account_repost.text = data.timestamp
		content_repost.text = data.content_text
