module CarrierWave

	# Most of this is has been shamelessly taken from the CarrierWave::MiniMagick module
	# https://github.com/carrierwaveuploader/carrierwave

  module GraphicsMagick
    extend ActiveSupport::Concern

    included do
      begin
        require "graphicsmagick"
      rescue LoadError => e
        e.message << " (You may need to install the graphicsmagick gem)"
        raise e
      end
    end

    module ClassMethods
      def convert(format)
        process :convert => format
      end

      def resize_to_limit(width, height)
        process :resize_to_limit => [width, height]
      end

      def resize_to_fit(width, height)
        process :resize_to_fit => [width, height]
      end

      def resize_to_fill(width, height, gravity='Center')
        process :resize_to_fill => [width, height, gravity]
      end
    end

    ##
    # Changes the image encoding format to the given format
    #
    # See http://www.graphicsmagick.org/mogrify.html
    #
    # === Parameters
    #
    # [format (#to_s)] an abreviation of the format
    #
    # === Yields
    #
    # [GraphicsMagick::Image] additional manipulations to perform
    #
    # === Examples
    #
    #     image.convert(:png)
    #
    def convert(format)
      @format = format
      manipulate! do |img|
        img.format(format.to_s.downcase)
        img = yield(img) if block_given?
        img
      end
    end

    ##
    # Resize the image to fit within the specified dimensions while retaining
    # the original aspect ratio. Will only resize the image if it is larger than the
    # specified dimensions. The resulting image may be shorter or narrower than specified
    # in the smaller dimension but will not be larger than the specified values.
    #
    # === Parameters
    #
    # [width (Integer)] the width to scale the image to
    # [height (Integer)] the height to scale the image to
    #
    # === Yields
    #
    # [GraphicsMagick::Image] additional manipulations to perform
    #
    def resize_to_limit(width, height)
      manipulate! do |img|
        img.resize "#{width}x#{height}>"
        img = yield(img) if block_given?
        img
      end
    end

    ##
    # Resize the image to fit within the specified dimensions while retaining
    # the original aspect ratio. The image may be shorter or narrower than
    # specified in the smaller dimension but will not be larger than the specified values.
    #
    # === Parameters
    #
    # [width (Integer)] the width to scale the image to
    # [height (Integer)] the height to scale the image to
    #
    # === Yields
    #
    # [GraphicsMagick::Image] additional manipulations to perform
    #
    def resize_to_fit(width, height)
      manipulate! do |img|
        img.resize "#{width}x#{height}"
        img = yield(img) if block_given?
        img
      end
    end

    ##
    # Resize the image to fit within the specified dimensions while retaining
    # the aspect ratio of the original image. If necessary, crop the image in the
    # larger dimension.
    #
    # === Parameters
    #
    # [width (Integer)] the width to scale the image to
    # [height (Integer)] the height to scale the image to
    # [gravity (String)] the current gravity suggestion (default: 'Center'; options: 'NorthWest', 'North', 'NorthEast', 'West', 'Center', 'East', 'SouthWest', 'South', 'SouthEast')
    #
    # === Yields
    #
    # [GraphicsMagick::Image] additional manipulations to perform
    #
    def resize_to_fill(width, height, gravity = 'Center')
      manipulate! do |img|
        img.resize("#{width}x#{height}^")
        	.gravity(gravity)
        	.background("rgba(255,255,255,0.0)")
        	.extent("#{width}x#{height}")
        img = yield(img) if block_given?
        img
      end
    end

    ##
    # Manipulate the image with GraphicsMagick. This method will load up an image
    # and then pass each of its frames to the supplied block. It will then
    # save the image to disk.
    #
    # === Gotcha
    #
    # This method assumes that the object responds to +current_path+.
    # Any class that this module is mixed into must have a +current_path+ method.
    # CarrierWave::Uploader does, so you won't need to worry about this in
    # most cases.
    #
    # === Yields
    #
    # [GraphicsMagick::Image] manipulations to perform
    #
    #
    def manipulate!
      cache_stored_file! if !cached?
      image = ::GraphicsMagick::Image.new(current_path)
      image.format(@format.to_s.downcase) if @format
      image = yield(image)
      image.write(current_path)
    end
  end
end