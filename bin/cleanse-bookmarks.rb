#!/usr/bin/env ruby

# USAGE:
#   ./bin/cleanse-bookmarks bookmarkFile output
# 

require 'chrome-tools'

fname = ARGV[0]
output = ARGV[1]

unless fname && output
  puts "usage: ./bin/cleanse-bookmarks bookmarkFile output"
  exit 1
end

data = ChromeTools::BookmarkUtils::read_file(ARGV[0])

ChromeTools::BookmarkUtils::cleanse_and_save(data, ARGV[1])
