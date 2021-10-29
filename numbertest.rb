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
  attr_accessor :word, :number

  def initialize(word, number)
    @word = word
    @number = number
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
  # check that calculated value according to Roths system and what we have recorded in file match
  wordEntries.each do |entry|
     vc = calc_word_value(entry.word)
     mismatch = entry.number != vc
     puts "#{entry.number} #{entry.word} #{vc}#{arrowif(mismatch)}" if mismatch
  end
end

def clearScreen
  puts "\e[H\e[2J"
end

def test_user(count, minVal, maxVal)
  # random on range minVal to maxVal inclusive with no repeats
  randList = (minVal..maxVal).to_a.shuffle[0,count]
  randList.each_with_index do |r,i|
     clearScreen if i > 0
     yield r
  end
end

def test_user_int_to_word(trials)
   test_user(trials, 0, 100) do |r| 
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

def quiz_codeword(ce)
  puts q = "enter codeword for #{ce.number}" 
  while(ans = $stdin.gets.chop)
     break if ans.casecmp?(ce.word)
     puts "wrong. try again. #{q}"
  end
end

def test_user_int_to_codeword(codewordEntries, trials)
   test_user(trials,0,100) do |r| 
     quiz_codeword(codewordEntries[r-1])
   end
end

def test_user_int_to_codeword_method_one(codewordEntries, firstDigit)
   test_user(10, 0, 9) do |secondDigit|
     num = firstDigit.to_i * 10 + secondDigit.to_i
     next if num == 0 # special case skip 00 which doesn't exist
     cw = codewordEntries[num-1]
     quiz_codeword(cw)
   end

   # special case, tack on last entry on group 9
   if firstDigit == 9
     clearScreen 
     quiz_codeword(codewordEntries[99]) 
   end
end

def lookForFirstDigit(args)
   if args.length > 0
     return args[0].to_i.clamp(0,9) 
   else
     return rand(0..9)
   end
end

def main
  wordEntries = loadWordEntries()
  #verify_word_entries(wordEntries)
  #test_user_int_to_word(3)
  codewordOnlyEntries = wordEntries[0..99]
  #clearScreen
  #test_user_int_to_codeword(codewordOnlyEntries,3)
  clearScreen
  test_user_int_to_codeword_method_one(codewordOnlyEntries, lookForFirstDigit(ARGV))
end

main
