require 'rubygems'
require 'bundler/setup'
Bundler.require
require 'json'
require './janky_parser'

settings = JSON.parse IO.read("settings.json")

# Open a database
db = SQLite3::Database.new settings['db']
rows = db.execute <<-SQL
  create table if not exists downloads (
    guid varchar(50),
    title varchar(4096),
    url varchar(2048)
  );
SQL

Feedjira::Feed.add_feed_class Feedjira::Parser::Versa::JankyPublisher
feed = Feedjira::Feed.fetch_and_parse settings['feed_url']

feed.entries.each do |entry|
  if db.execute('SELECT guid from downloads WHERE guid = ?', entry.guid).length == 0
    puts "Adding #{entry.title}"
    system "transmission-remote -a \"#{entry.url}\" -n \"#{settings['username']}:#{settings['password']}\""
    db.execute('INSERT INTO downloads (guid, title, url) VALUES(?, ?, ?)', entry.guid, entry.title, entry.url)
  end
end

db.close
