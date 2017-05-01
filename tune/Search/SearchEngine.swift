//
//  SearchEngine.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class SearchEngine
{
	private var searchQueue = DispatchQueue(label: "Search Queue", qos: .background)

	var delegate: SearchEngineDelegate? = nil
	var mediaPlayer: MediaPlayer? = nil

	func search(forTracks text: String)
	{
		if let delegate = self.delegate
		{
			// This forces one search to be executed at a time, without blocking the main queue (thread(s))
			searchQueue.sync
			{
				if let result = mediaPlayer?.search(forTracks: text)
				{
					delegate.searchEngine(self, gotSearchResult: result)
				}
				else
				{
					delegate.searchEngine(self, getErrorForSearchWithQuery: text)
				}
			}
		}
	}

	func search(forAlbums text: String)
	{
		if let delegate = self.delegate
		{
			// This forces one search to be executed at a time, without blocking the main queue (thread(s))
			searchQueue.sync
			{
				if let result = self.mediaPlayer?.search(forAlbums: text)
				{
					delegate.searchEngine(self, gotSearchResult: result)
				}
				else
				{
					delegate.searchEngine(self, getErrorForSearchWithQuery: text)
				}
			}
		}
	}

	func search(forPlaylists text: String)
	{
		if let delegate = self.delegate
		{
			// This forces one search to be executed at a time, without blocking the main queue (thread(s))
			searchQueue.sync
			{
				if let result = mediaPlayer?.search(forPlaylists: text)
				{
					delegate.searchEngine(self, gotSearchResult: result)
				}
				else
				{
					delegate.searchEngine(self, getErrorForSearchWithQuery: text)
				}
			}
		}
	}
}

protocol MediaSearchable
{
	func search(forTracks text: String) -> SearchResult
	func search(forAlbums text: String) -> SearchResult
	func search(forPlaylists text: String) -> SearchResult
}

protocol SearchEngineDelegate
{
	func searchEngine(_ searchEngine: SearchEngine, gotSearchResult: SearchResult)
	func searchEngine(_ searchEngine: SearchEngine, getErrorForSearchWithQuery text: String)
}

class SearchResult
{
	let resultItems: [SearchResultItem]
	let query: String

	init(withItems items: [SearchResultItem], forQuery query: String)
	{
		self.resultItems = items
		self.query = query
	}
}

protocol SearchResultItem
{
	var name: String { get }
	var artist: String { get }
	var album: String { get }
	var time: String { get }
}
