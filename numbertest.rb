#!/usr/bin/ruby

require 'string_to_ipa'

$vpa = "\u02A4"  # ʤ  Voiced postalveolar affricate , j sound in jump

$vlpa = "\u02A7" # ʧ Voiceless postalveolar affricate, ch sound in chip 

def lookup(c)
   return case c  
     when "d","t" then "1"
     when "n","ŋ" then "2"
     when "m" then "3"
     # r or r colored vowel 
     when "r","ɝ" then "4" 
     when "l","ɫ" then "5"
     # ʃ like sh in fish
     # ʒ kind of zj sound is found in rouge/abrasion/garage according to CMU , 
     #   a little iffy for me vs z sound which would be equal to 0
     when "ʃ",$vpa,$vlpa,"ʒ" then "6" 
     # k or hard g
     when "k","g" then "7"
     when "v","f" then "8"
     when "p","b" then "9"
     when "z","s" then "0"
     else c
   end
end

def ipa_to_i(wi)
   r = ""
   0.upto(wi.length-1) do |i|
       #puts "#{i}: #{wi[i]} -> #{lookup(wi[i])}"
       r += lookup(wi[i])
   end

   return r
end

def arrowif(b)
  return b ?  " <----" : ""
end

def process(w,i)
  wi = w.to_ipa
  wip = wi.gsub(/[ˈwhyjæɔɑəɛʊɪʌaeiou]/,"")
  wip.gsub!("dʒ",$vpa) 
  wip.gsub!("tʃ",$vlpa) 
  vi = ipa_to_i(wip)
  mismatch = i != vi.to_i
  puts "#{i} #{w} #{wi} #{wip} #{vi}#{arrowif(mismatch)}" if mismatch
end

filename = "codewords.txt"
words = IO.readlines(filename).each_with_index do |input,i|
  i,word = input.chop.split(" ")
  process(word,i.to_i)
end

