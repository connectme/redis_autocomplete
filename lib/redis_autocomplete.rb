require 'redis'

class RedisAutocomplete
  DEFAULT_DISALLOWED_CHARS = /[^a-zA-Z0-9_-]/
  DEFAULT_TERMINAL = '+'
  DEFAULT_CASE_SENSITIVITY = true

  attr_reader :redis, :terminal

  def initialize(opts = {})
    @set_name = opts[:set_name] # optional
    @redis = Redis.new
    @disallowed_chars = opts[:disallowed_chars] || DEFAULT_DISALLOWED_CHARS
    @terminal = opts[:terminal] || DEFAULT_TERMINAL
    @case_sensitive = opts[:case_sensitive].nil? ? DEFAULT_CASE_SENSITIVITY : opts[:case_sensitive]
  end

  def add_word(word, set_name = nil)
    set_name ||= @set_name
    w = word.gsub(@disallowed_chars, '')
    w.downcase! if !@case_sensitive
    (1..(w.length)).each { |i| @redis.zadd(set_name, 0, w.slice(0, i)) }
    @redis.zadd(set_name, 0, "#{w}#{@terminal}")
  end

  def add_words(words, set_name = nil)
    words.flatten.compact.uniq.each { |word| add_word word, set_name }
  end

  def suggest(prefix, count = 10, set_name = nil)
    set_name ||= @set_name
    results = []
    rangelen = 50 # This is not random, try to get replies < MTU size
    start = @redis.zrank(set_name, prefix)
    return [] if !start
    while results.length != count
      range = @redis.zrange(set_name, start, start+rangelen-1)
      start += rangelen
      break if !range || range.length == 0
      range.each do |entry|
        minlen = [entry.length, prefix.length].min
        if entry.slice(0, minlen) != prefix.slice(0, minlen)
          count = results.count
          break
        end
        if entry[-1] == @terminal and results.length != count
          results << entry.chomp(@terminal)
        end
      end
    end
    return results
  end
end