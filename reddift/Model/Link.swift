//
//  Link.swift
//  reddift
//
//  Created by generator.rb via from https://github.com/reddit/reddit/wiki/JSON
//  Created at 2015-04-15 11:23:32 +0900
//

import UIKit

enum ListingSortType {
    case Controversial
    case Hot
    case New
    case Top
    
    func path () -> String {
        switch self{
        case ListingSortType.Controversial:
            return "/controversial"
        case ListingSortType.Hot:
            return "/hot"
        case ListingSortType.New:
            return "/new"
        case ListingSortType.Top:
            return "/top"
        default :
            return ""
        }
    }
}


class Link : Thing {
    /**
    example: self.redditdev
    */
    var domain = ""
    /**
    example:
    */
    var banned_by = ""
    /**
    Used for streaming video. Technical embed specific information is found here.
    example: {}
    */
    var media_embed:MediaEmbed? = nil
    /**
    subreddit of thing excluding the /r/ prefix. "pics"
    example: redditdev
    */
    var subreddit = ""
    /**
    the formatted escaped HTML text.  this is the HTML formatted version of the marked up text.  Items that are boldened by ** or *** will now have &lt;em&gt; or *** tags on them. Additionally, bullets and numbered lists will now be in HTML list format. NOTE: The HTML string will be escaped.  You must unescape to get the raw HTML. Null if not present.
    example: &lt;!-- SC_OFF --&gt;&lt;div class="md"&gt;&lt;p&gt;So this is the code I ran:&lt;/p&gt;
    &lt;pre&gt;&lt;code&gt;r = praw.Reddit(&amp;quot;/u/habnpam sflkajsfowifjsdlkfj test test test&amp;quot;)
    for c in praw.helpers.comment_stream(reddit_session=r, subreddit=&amp;quot;helpmefind&amp;quot;, limit=500, verbosity=1):
    print(c.author)
    &lt;/code&gt;&lt;/pre&gt;
    &lt;hr/&gt;
    &lt;p&gt;From what I understand, comment_stream() gets the most recent comments. So if we specify the limit to be 100, it will initially get the 100 newest comment, and then constantly update to get new comments.  It seems to works appropriately for every subreddit except &lt;a href="/r/helpmefind"&gt;/r/helpmefind&lt;/a&gt;. For &lt;a href="/r/helpmefind"&gt;/r/helpmefind&lt;/a&gt;, it fetches around 30 comments, regardless of the limit.&lt;/p&gt;
    &lt;/div&gt;&lt;!-- SC_ON --&gt;
    */
    var selftext_html = ""
    /**
    the raw text.  this is the unformatted text which includes the raw markup characters such as ** for bold. &lt;, &gt;, and &amp; are escaped. Empty if not present.
    example: So this is the code I ran:
    r = praw.Reddit("/u/habnpam sflkajsfowifjsdlkfj test test test")
    for c in praw.helpers.comment_stream(reddit_session=r, subreddit="helpmefind", limit=500, verbosity=1):
    print(c.author)
    ---
    From what I understand, comment_stream() gets the most recent comments. So if we specify the limit to be 100, it will initially get the 100 newest comment, and then constantly update to get new comments.  It seems to works appropriately for every subreddit except /r/helpmefind. For /r/helpmefind, it fetches around 30 comments, regardless of the limit.
    */
    var selftext = ""
    /**
    how the logged-in user has voted on the link - True = upvoted, False = downvoted, null = no vote
    example:
    */
    var likes:Bool? = nil
    /**
    example: []
    */
    var user_reports:[AnyObject] = []
    /**
    example:
    */
    var secure_media:AnyObject? = nil
    /**
    the text of the link's flair.
    example:
    */
    var link_flair_text = ""
    /**
    example: 0
    */
    var gilded = 0
    /**
    example: false
    */
    var archived = false
    /**
    probably always returns false
    example: false
    */
    var clicked = false
    /**
    example:
    */
    var report_reasons:[AnyObject] = []
    /**
    the account name of the poster. null if this is a promotional link
    example: habnpam
    */
    var author = ""
    /**
    the number of comments that belong to this link. includes removed comments.
    example: 10
    */
    var num_comments = 0
    /**
    the net-score of the link.  note: A submission's score is simply the number of upvotes minus the number of downvotes. If five users like the submission and three users don't it will have a score of 2. Please note that the vote numbers are not "real" numbers, they have been "fuzzed" to prevent spam bots etc. So taking the above example, if five users upvoted the submission, and three users downvote it, the upvote/downvote numbers may say 23 upvotes and 21 downvotes, or 12 upvotes, and 10 downvotes. The points score is correct, but the vote totals are "fuzzed".
    example: 2
    */
    var score = 0
    /**
    example:
    */
    var approved_by = ""
    /**
    true if the post is tagged as NSFW.  False if otherwise
    example: false
    */
    var over_18 = false
    /**
    true if the post is hidden by the logged in user.  false if not logged in or not hidden.
    example: false
    */
    var hidden = false
    /**
    full URL to the thumbnail for this link; "self" if this is a self post; "default" if a thumbnail is not available
    example:
    */
    var thumbnail = ""
    /**
    the id of the subreddit in which the thing is located
    example: t5_2qizd
    */
    var subreddit_id = ""
    /**
    example: false
    */
    var edited = false
    /**
    the CSS class of the link's flair.
    example:
    */
    var link_flair_css_class = ""
    /**
    the CSS class of the author's flair.  subreddit specific
    example:
    */
    var author_flair_css_class = ""
    /**
    example: 0
    */
    var downs = 0
    /**
    example: []
    */
    var mod_reports:[AnyObject] = []
    /**
    example:
    */
    var secure_media_embed:AnyObject? = nil
    /**
    true if this post is saved by the logged in user
    example: false
    */
    var saved = false
    /**
    true if this link is a selfpost
    example: true
    */
    var is_self = false
    /**
    relative URL of the permanent link for this link
    example: /r/redditdev/comments/32wnhw/praw_comment_stream_messes_up_when_getting/
    */
    var permalink = ""
    /**
    true if the post is set as the sticky in its subreddit.
    example: false
    */
    var stickied = false
    /**
    example: 1429292148
    */
    var created = 0
    /**
    the link of this post.  the permalink if this is a self-post
    example: http://www.reddit.com/r/redditdev/comments/32wnhw/praw_comment_stream_messes_up_when_getting/
    */
    var url = ""
    /**
    the text of the author's flair.  subreddit specific
    example:
    */
    var author_flair_text = ""
    /**
    the title of the link. may contain newlines for some reason
    example: [PRAW] comment_stream() messes up when getting comments from a certain subreddit.
    */
    var title = ""
    /**
    example: 1429263348
    */
    var created_utc = 0
    /**
    example: 2
    */
    var ups = 0
    /**
    example: 0.75
    */
    var upvote_ratio = 0.0
    /**
    Used for streaming video. Detailed information about the video and it's origins are placed here
    example:
    */
    var media:Media? = nil
    /**
    example: false
    */
    var visited = false
    /**
    example: 0
    */
    var num_reports = 0
    /**
    example: false
    */
    var distinguished = false
	
	override func toString() -> String {
		var buf = "------------------------------\nid=\(id)\nname=\(name)\nkind=\(kind)\ntitle=\(title)\nurl=\(url)\n"
		if let media = media {
			buf += "media\n"
			buf += media.toString()
		}
		if let media_embed = media_embed {
			buf += "media_embed\n"
			buf += media_embed.toString()
		}
		return buf
	}
}

