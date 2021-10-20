#!/usr/bin/ruby

require 'string_to_ipa'

$vpa = "\u02A4"  # ʤ  Voiced postalveolar affricate , j sound in jump

$vlpa = "\u02A7" # ʧ Voiceless postalveolar affricate, ch sound in chip 

def lookup(c)
   return case c  
     when "d","t" then "1"
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

