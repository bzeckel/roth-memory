#!/usr/bin/ruby

require 'string_to_ipa'

$vpa = "\u02A4"  # ʤ  Voiced postalveolar affricate , j sound in jump

$vlpa = "\u02A7" # ʧ Voiceless postalveolar affricate, ch sound in chip 

def lookup(c)
   return case c  
     when "d","t","θ" then "1"
     when "n" then "2"
     when "m" then "3"
     # r or r colored vowel 
     when "r","ɝ" then "4" 
     when "l","ɫ" then "5"
     # ʃ like sh in fish
     # ʒ kind of zj sound is found in rouge/abrasion/garage according to CMU , 
     #   a little iffy for me vs z sound which would be equal to 0
     when "ʃ",$vpa,$vlpa,"ʒ" then "6" 
     # k or hard g
     when "k","g","ŋ" then "7"
     when "v","f" then "8"
     when "p","b" then "9"
     when "z","s" then "0"
     else c
   end
end

def ipa_to_i(wi)
   r = wi.dup
   # Roth says ending in ing gives 7 
   #      but ing sound in ink is supposed to give 2 according to codework example where ink=27
   #      both cases has sound in IPA of ŋ
   # for now, special case ink which was probably an oversight by Roth but we might instead special
   # case ending with ŋ = 7...
   r.gsub!("ŋk","27")
   0.upto(r.length-1) do |i|
       #puts "#{i}: #{r[i]} -> #{lookup(r[i])}"
       r[i] = lookup(r[i])
   end

   return r.to_i
end

def arrowif(b)
  return b ?  " <----" : ""
end

class WordNotFoundException < StandardError
  def initialize(msg="This is a custom exception", exception_type="custom")
    @exception_type = exception_type
    super(msg)
  end
end

def ipa(w)
   r = w.to_ipa
   raise WordNotFoundException.new("string_to_ipa doesn't appear to recognize #{w}") if(r==w)
   return r
end

def CMUMissingOverride(vi,w)
   return vi, w, w
end

def calc_word_value(w)

  # handle ones not in CMU list
  return 29 if w.casecmp?("Nobby")
  return 76 if w.casecmp?("Hoggish")
  return 89 if w.casecmp?("Foppy")

  wi = w.split.map { |x| ipa(x) }.join
  wip = wi.gsub(/[ˈˌwhyjæɔɑəɛʊɪʌaeiou]/,"")
  wip.gsub!("dʒ",$vpa) 
  wip.gsub!("tʃ",$vlpa) 
  return ipa_to_i(wip)
end


class WordEntry
  attr_accessor :word, :expected

  def initialize(word, expected)
    @word = word
    @expected = expected
  end
end

def loadWordEntries
  filename = "codewords.txt"
  entries = []
  IO.readlines(filename).each do |input|
    clean = input.gsub(/\#.*$/,"").strip
    next if clean == ""
    i,word = clean.split(' ',2)

    entries << WordEntry.new(word, i.to_i)
  end

  return entries
end

def verify_word_entries(wordEntries)
  wordEntries.each do |entry|
     vc = calc_word_value(entry.word)
     mismatch = entry.expected != vc
     puts "#{entry.expected} #{entry.word} #{vc}#{arrowif(mismatch)}" if mismatch
  end
end

def no_repeat_random(used)
   n = 100

   raise "Used is full in no_repeat_random" if used.length == n

   r = -1 
   loop do 
       r = rand(n) + 1
       break if used.include?(r) == false
   end 

   used << r

   return r
end

def clearScreen
  puts "\e[H\e[2J"
end

def test_user(count)
  used = []
  count.times do |i|
     clearScreen if i > 0
     r = no_repeat_random(used)
     yield r
  end
end

def meat(r)
end

def test_user_int_to_word
   test_user(3) do |r| 
     puts "enter any word for #{r}" 
     while(ans = gets.chop)
       begin
         wv = calc_word_value(ans)
         break if wv.to_i == r
         puts "wrong. #{ans} has word value of #{wv} not #{r}"
       rescue WordNotFoundException => wnfe
         puts wnfe
       end
     end
   end
end


def test_user_int_to_codeword(codewordEntries)
   raise "too many codewords. expected 100 got #{codewordEntries.length}" if codewordEntries.length != 100
   
end

def main
  wordEntries = loadWordEntries()
  #verify_word_entries(wordEntries)
  puts
  test_user_int_to_word
  test_user_int_to_codeword(wordEntries[0..99])
end

main
