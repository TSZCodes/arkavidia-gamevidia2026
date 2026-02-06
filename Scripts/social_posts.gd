class_name TweetData extends Resource

# SECTION 1: Metadata
@export var is_repost: bool = false
@export var timestamp: String = ""

# SECTION 2: The Reposter / Main Author
# If it's a normal tweet: This is the author.
# If it's a repost: This is the person Reposting/Quoting.
@export var user_handle: String = ""
@export var content_text: String = ""

# SECTION 3: The Original Tweet (Only valid if is_repost = true)
@export var original_author: String = ""
@export var original_text: String = ""

# SECTION 4: Engagement Metrics
# We keep these as Strings because your JSON uses "K" and "M" (e.g., "20K")
@export var likes: String = "0"
@export var retweets: String = "0"
@export var comments: String = "0"
@export var views: String = "0"
@export var bookmarks: String = "0"
