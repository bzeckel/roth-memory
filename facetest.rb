#!/usr/bin/ruby

require 'rmagick'

def showRandom(files, fnames, lnames)
  filename = files[rand(files.length)]
  images = Magick::Image.read(filename)
  image = images[0]

  text = Magick::Draw.new
  text.font_family = 'helvetica'
  text.pointsize = 52
  text.gravity = Magick::NorthGravity

  name = fnames[rand(fnames.length)] + " " + lnames[rand(lnames.length)]
  text.annotate(image, 0,0,0,0, name) {
     self.fill = 'darkred'
  }
  image.display
end

fnames = IO.readlines("fnames.txt").map { |x| x.chop }
lnames = IO.readlines("lnames.txt").map { |x| x.chop }
facefiles = Dir.glob("./faces/*.jpg")

5.times { showRandom(facefiles, fnames, lnames) }
