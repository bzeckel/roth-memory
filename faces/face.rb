#!/usr/bin/ruby
# 
# grab and save off a bunch of fake faces
#

sv = 1
N = 2000
sv.upto(N) do |n|
   fn = "%06d" % n
   puts fn
   `wget -O #{fn}.jpg https://thispersondoesnotexist.com/image`
   sleep(2) # to not DOS site or get banned
end
