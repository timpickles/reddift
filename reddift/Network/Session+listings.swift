//
//  Session+listings.swift
//  reddift
//
//  Created by sonson on 2015/05/19.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import Foundation

/**
The sort method for listing Link object, "/r/[subreddit]/[sort]" or "/[sort]".
*/
enum PrivateLinkSortBy {
    case Controversial
    case Top
    
    var path:String {
        switch self{
        case .Controversial:
            return "/controversial"
        case .Top:
            return "/hot"
        }
    }
}

func redditAny2Tuple(redditAny:RedditAny) -> Result<(Listing, Listing)> {
    if let array = redditAny as? [RedditAny] {
        if array.count == 2 {
            if let listing0 = array[0] as? Listing, let listing1 = array[1] as? Listing {
                return Result(value: (listing0, listing1))
            }
        }
    }
    return Result(error: ReddiftError.Malformed.error)
}

func redditAny2Listing(redditAny:RedditAny) -> Result<Listing> {
    if let listing = redditAny as? Listing {
        return Result(value: listing)
    }
    return Result(error: ReddiftError.Malformed.error)
}

extension Session {

    /**
    Get the comment tree for a given Link article.
    If supplied, comment is the ID36 of a comment in the comment tree for article. This comment will be the (highlighted) focal point of the returned view and context will be the number of parents shown.
    
    - parameter link: Link from which comment will be got.
    - parameter sort: The type of sorting.
    - parameter comments: If supplied, comment is the ID36 of a comment in the comment tree for article.
    - parameter depth: The maximum depth of subtrees in the thread. Default is 4.
    - parameter limit: The maximum number of comments to return. Default is 100.
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    public func getArticles(link:Link, sort:CommentSort, comments:[String]? = nil, depth:Int = 4, limit:Int = 100, completion:(Result<(Listing, Listing)>) -> Void) -> NSURLSessionDataTask? {
        var parameter:[String:String] = ["sort":sort.type, "depth":"\(depth)", "showmore":"True", "limit":"\(limit)"]
        if let comments = comments {
            let commaSeparatedIDString = commaSeparatedStringFromList(comments)
            parameter["comment"] = commaSeparatedIDString
        }
        let request = NSMutableURLRequest.mutableOAuthRequestWithBaseURL(Session.baseURL, path:"/comments/" + link.id, parameter:parameter, method:"GET", token:token)
        
        if let task = URLSession.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.updateRateLimitWithURLResponse(response)
            
            let result = resultFromOptionalError(Response(data: data, urlResponse: response), optionalError:error)
                .flatMap(parseResponse)
                .flatMap(decodeJSON)
                .flatMap(parseListFromJSON)
                .flatMap(redditAny2Tuple)
            completion(result)
        }) {
            task.resume()
            return task
        }
        return nil
    }
    
    /**
    Get Links from all subreddits or user specified subreddit.
    
    - parameter paginator: Paginator object for paging contents.
    - parameter subreddit: Subreddit from which Links will be gotten.
    - parameter integratedSort: The original type of sorting a list, .Controversial, .Top, .Hot, or .New.
    - parameter TimeFilterWithin: The type of filtering contents. When integratedSort is .Hot or .New, this parameter is ignored.
    - parameter limit: The maximum number of comments to return. Default is 25.
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    public func getList(paginator:Paginator, subreddit:SubredditURLPath?, sort:LinkSortType, timeFilterWithin:TimeFilterWithin, limit:Int = 25, completion:(Result<Listing>) -> Void) -> NSURLSessionDataTask? {
        switch sort {
        case .Controversial:
            return getList(paginator, subreddit: subreddit, privateSortType: PrivateLinkSortBy.Controversial, timeFilterWithin: timeFilterWithin, limit: limit, completion: completion)
        case .Top:
            return getList(paginator, subreddit: subreddit, privateSortType: PrivateLinkSortBy.Top, timeFilterWithin: timeFilterWithin, limit: limit, completion: completion)
        case .New:
            return getNewOrHotList(paginator, subreddit: subreddit, type: "new", limit:limit, completion: completion)
        case .Hot:
            return getNewOrHotList(paginator, subreddit: subreddit, type: "hot", limit:limit, completion: completion)
        }
    }
    
    /**
    Get Links from all subreddits or user specified subreddit.
    
    - parameter paginator: Paginator object for paging contents.
    - parameter subreddit: Subreddit from which Links will be gotten.
    - parameter sort: The type of sorting a list.
    - parameter TimeFilterWithin: The type of filtering contents.
    - parameter limit: The maximum number of comments to return. Default is 25.
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    func getList(paginator:Paginator, subreddit:SubredditURLPath?, privateSortType:PrivateLinkSortBy, timeFilterWithin:TimeFilterWithin, limit:Int = 25, completion:(Result<Listing>) -> Void) -> NSURLSessionDataTask? {
        var parameter = ["t":timeFilterWithin.param];
        parameter["limit"] = "\(limit)"
        parameter["show"] = "all"
        // parameter["sr_detail"] = "true"
        parameter.update(paginator.parameters())
        
        var path = privateSortType.path
        if let subreddit = subreddit {
            path = "\(subreddit.path)\(privateSortType.path).json"
        }
        let request = NSMutableURLRequest.mutableOAuthRequestWithBaseURL(Session.baseURL, path:path, parameter:parameter, method:"GET", token:token)
        if let task = URLSession.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.updateRateLimitWithURLResponse(response)
            let result = resultFromOptionalError(Response(data: data, urlResponse: response), optionalError:error)
                .flatMap(parseResponse)
                .flatMap(decodeJSON)
                .flatMap(parseListFromJSON)
                .flatMap(redditAny2Listing)
            completion(result)
        }) {
            task.resume()
            return task
        }
        return nil
    }
    
    /**
    Get hot Links from all subreddits or user specified subreddit.
    
    - parameter paginator: Paginator object for paging contents.
    - parameter subreddit: Subreddit from which Links will be gotten.
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    func getHotList(paginator:Paginator, subreddit:SubredditURLPath?, limit:Int = 25, completion:(Result<Listing>) -> Void) -> NSURLSessionDataTask? {
        return getNewOrHotList(paginator, subreddit: subreddit, type: "hot", limit:limit, completion: completion)
    }
    
    /**
    Get new Links from all subreddits or user specified subreddit.
    
    - parameter paginator: Paginator object for paging contents.
    - parameter subreddit: Subreddit from which Links will be gotten.
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    func getNewList(paginator:Paginator, subreddit:SubredditURLPath?, limit:Int = 25, completion:(Result<Listing>) -> Void) -> NSURLSessionDataTask? {
        return getNewOrHotList(paginator, subreddit: subreddit, type: "new", limit:limit, completion: completion)
    }
    
    /**
    Get hot or new Links from all subreddits or user specified subreddit.
    
    - parameter paginator: Paginator object for paging contents.
    - parameter subreddit: Subreddit from which Links will be gotten.
    - parameter type: "new" or "hot" as type.
    - parameter limit: The maximum number of comments to return. Default is 25.
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    func getNewOrHotList(paginator:Paginator, subreddit:SubredditURLPath?, type:String, limit:Int = 25, completion:(Result<Listing>) -> Void) -> NSURLSessionDataTask? {
        var parameter:[String:String] = [:]
        parameter["limit"] = "\(limit)"
        parameter["show"] = "all"
        // parameter["sr_detail"] = "true"
        parameter.update(paginator.parameters())
        
        var path = type
        if let subreddit = subreddit {
            path = "\(subreddit.path)/\(type).json"
        }
        let request = NSMutableURLRequest.mutableOAuthRequestWithBaseURL(Session.baseURL, path:path, parameter:parameter, method:"GET", token:token)
        if let task = URLSession.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.updateRateLimitWithURLResponse(response)
            let result = resultFromOptionalError(Response(data: data, urlResponse: response), optionalError:error)
                .flatMap(parseResponse)
                .flatMap(decodeJSON)
                .flatMap(parseListFromJSON)
                .flatMap(redditAny2Listing)
            completion(result)
        }) {
            task.resume()
            return task
        }
        return nil
    }
    
    /**
    The Serendipity content.
    But this endpoints return invalid redirect URL...
    I don't know how this URL should be handled....
    
    - parameter subreddit: Specified subreddit to which you would like to get random link
    - returns: Data task which requests search to reddit.com.
    */
    public func getRandom(subreddit:Subreddit? = nil, completion:(Result<(Listing, Listing)>) -> Void) -> NSURLSessionDataTask? {
        let path:String = (subreddit == nil) ? "/random" : subreddit!.url + "/random"
        let request = NSMutableURLRequest.mutableOAuthRequestWithBaseURL(Session.baseURL, path:path, method:"GET", token:token)
        if let task = URLSession.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.updateRateLimitWithURLResponse(response)
            let result = resultFromOptionalError(Response(data: data, urlResponse: response), optionalError:error)
                .flatMap(parseResponse)
                .flatMap(decodeJSON)
                .flatMap(parseListFromJSON)
                .flatMap(redditAny2Tuple)
            completion(result)
        }) {
            task.resume()
            return task
        }
        return nil
    }
    
    // MARK: BDT does not cover following methods.
    
    /**
    Related page: performs a search using title of article as the search query.
    
    - parameter paginator: Paginator object for paging contents.
    - parameter thing:  Thing object to which you want to obtain the contents that are related.
    - parameter limit: The maximum number of comments to return. Default is 25.
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    public func getRelatedArticles(paginator:Paginator, thing:Thing, limit:Int = 25, completion:(Result<(Listing, Listing)>) -> Void) -> NSURLSessionDataTask? {
        var parameter:[String:String] = [:]
        parameter["limit"] = "\(limit)"
        parameter["show"] = "all"
        // parameter["sr_detail"] = "true"
        parameter.update(paginator.parameters())
        
        let request = NSMutableURLRequest.mutableOAuthRequestWithBaseURL(Session.baseURL, path:"/related/" + thing.id, parameter:parameter, method:"GET", token:token)
        if let task = URLSession.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.updateRateLimitWithURLResponse(response)
            
            let result = resultFromOptionalError(Response(data: data, urlResponse: response), optionalError:error)
                .flatMap(parseResponse)
                .flatMap(decodeJSON)
                .flatMap(parseListFromJSON)
                .flatMap(redditAny2Tuple)
            completion(result)
        }) {
            task.resume()
            return task
        }
        return nil
    }
    
    /**
    Return a list of other submissions of the same URL.
    
    - parameter paginator: Paginator object for paging contents.
    - parameter thing:  Thing object by which you want to obtain the same URL is mentioned.
    - parameter limit: The maximum number of comments to return. Default is 25.
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    public func getDuplicatedArticles(paginator:Paginator, thing:Thing, limit:Int = 25, completion:(Result<(Listing, Listing)>) -> Void) -> NSURLSessionDataTask? {
        var parameter:[String:String] = [:]
        parameter["limit"] = "\(limit)"
        parameter["show"] = "all"
        // parameter["sr_detail"] = "true"
        parameter.update(paginator.parameters())
        
        let request = NSMutableURLRequest.mutableOAuthRequestWithBaseURL(Session.baseURL, path:"/duplicates/" + thing.id, parameter:parameter, method:"GET", token:token)
        if let task = URLSession.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.updateRateLimitWithURLResponse(response)
            let result = resultFromOptionalError(Response(data: data, urlResponse: response), optionalError:error)
                .flatMap(parseResponse)
                .flatMap(decodeJSON)
                .flatMap(parseListFromJSON)
                .flatMap(redditAny2Tuple)
            completion(result)
        }) {
            task.resume()
            return task
        }
        return nil
    }
    
    /**
    Get a listing of links by fullname.
    
    :params: links A list of Links
    - parameter completion: The completion handler to call when the load request is complete.
    - returns: Data task which requests search to reddit.com.
    */
    public func getLinksById(links:[Link], completion:(Result<Listing>) -> Void) -> NSURLSessionDataTask? {
        let fullnameList = links.map({ (link: Link) -> String in link.name })
        let request = NSMutableURLRequest.mutableOAuthRequestWithBaseURL(Session.baseURL, path:"/by_id/" + commaSeparatedStringFromList(fullnameList), method:"GET", token:token)
        
        if let task = URLSession.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.updateRateLimitWithURLResponse(response)
            let result = resultFromOptionalError(Response(data: data, urlResponse: response), optionalError:error)
                .flatMap(parseResponse)
                .flatMap(decodeJSON)
                .flatMap(parseListFromJSON)
                .flatMap(redditAny2Listing)
            completion(result)
        
        }) {
            task.resume()
            return task
        }
        return nil
    }
}