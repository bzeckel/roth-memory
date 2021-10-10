#!/usr/bin/ruby

def correctAnswer(words, ir)
   return words[-2..-1] if ir == words.length-1
   return words[0..1] if ir == 0
   return words[(ir-1)..(ir+1)]
end

def singleTest(words)
  ir = rand(words.length)
  puts "____ #{words[ir]} ____"
  while(ans = gets.chop.split(" "))
    break if ans.map(&:downcase) == correctAnswer(words, ir).map(&:downcase)
    puts "wrong"
  end

  puts "got it!"
end


filename = "codewords.txt"
words = IO.readlines(filename).map { |x| x.chop }
puts "loaded #{words.length} words from #{filename}"
3.times do singleTest(words) end
