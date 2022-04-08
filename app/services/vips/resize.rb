# #!/usr/bin/ruby
#
# require 'vips'
#
# image = Vips::Image.new_from_file ARGV[0], access: :sequential, n: -1
#
# target_size = ARGV[2].to_i
#
# # image.height will be for all frames -- we want the height of one page. If
# # page-height is missing, default to image height
# page_height = if image.get_typeof("page-height") != 0
#                 image.get("page-height")
#               else
#                 image.height
#               end
#
# # we now know the number of pages in the animation
# n_loaded_pages = image.height / page_height
#
# # resize to fit a inside target_size by target_size box
# scale = [target_size.to_f / image.width, target_size.to_f / page_height].min
#
# # adjust the scale so that we hit the image.height exactly, or we'll hae frames
# # that vary in size
# target_height = (page_height * scale).round
# scale = (target_height.to_f * n_loaded_pages) / image.height
#
# # normally you'd need to premultiply around resize, but :nearest does not mix
# # pixels, so there's no need
# image = image.resize scale, kernel: :nearest
#
# # we need to set the new page_height
# image = image.copy
# image.set "page-height", target_height
#
# image.write_to_file ARGV[1],
#   optimize_gif_frames: true, optimize_gif_transparency: true
####################################################################
# # load all frames from file using n=-1
# image = pyvips.Image.new_from_file(sys.argv[1], n=-1)
# outfile = sys.argv[2]
# left = int(sys.argv[3])
# top = int(sys.argv[4])
# width = int(sys.argv[5])
# height = int(sys.argv[6])
#
# # the image will be a very tall, thin strip, with "page-height" being the height
# # of each frame
# page_height = image.get("page-height")
# n_frames = image.height / page_height
#
# # make a list of new frames
# frames = [image.crop(left, i * page_height + top, width, height)
#           for i in range(0, n_frames)]
#
# # assemble the frames back into a tall, thin image
# new_image = pyvips.Image.arrayjoin(frames, across=1)
#
# # set the new page-height ... you must copy() before modifying
# # image metadata
# new_image.copy().set("page-height", height)
#
# # and save back again
# new_image.write_to_file(outfile)
module Vips
  class Resize

  end
end
