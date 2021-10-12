#!/usr/bin/ruby

require 'rmagick'

def showRandom(files)
  filename = files[rand(files.length)]
  images = Magick::Image.read(filename)
  image = images[0]

  text = Magick::Draw.new
  text.font_family = 'helvetica'
  text.pointsize = 52
  text.gravity = Magick::NorthGravity

  text.annotate(image, 0,0,0,0, "show name here") {
     self.fill = 'darkred'
  }
  image.display
end

files = Dir.glob("./faces/*.jpg")

5.times { showRandom(files) }
