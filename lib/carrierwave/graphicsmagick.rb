module CarrierWave

	# Much of this is has been shamelessly taken from the CarrierWave::MiniMagick module
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

      def auto_orient
      	process :auto_orient
      end

      def strip
      	process :strip
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
      manipulate! do |img|
      	@format = format
        img.convert
        img = yield(img) if block_given?
        img
      end
    end

    ##
    # Auto rotates the file (useful for images taken with a digital camera)
    #
    def auto_orient
    	manipulate! do |img|
        img.auto_orient
        img = yield(img) if block_given?
        img
      end
    end

    ##
    # Remove all profiles and text attributes from the image
    #
    def strip
    	manipulate! do |img|
        img.strip
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
    # Manipulate the image with GraphicsMagick. This method will pass the image
    # to the supplied block. It will NOT save the image to disk by default. Override
    # this by passing true as the only argument. Note: by default, the image is only
    # saved after all processes have been run. If you are using this method to utilize
    # Graphicsmagick utilities other than mogrify, then make sure all processes have
    # been explicitly written to disk first, or call manipulate(true) before using
    # built in convenience methods.
    #
    # === Gotcha
    #
    # This method assumes that the object responds to +current_path+.
    # Any class that this module is mixed into must have a +current_path+ method.
    # CarrierWave::Uploader does, so you won't need to worry about this in
    # most cases.
    #
    #
    # === Yields
    #
    # [GraphicsMagick::Image] manipulations to perform
    #
    #
    def manipulate!(save_image = false)
      cache_stored_file! if !cached?
      @_gimage ||= ::GraphicsMagick::Image.new(current_path)
      @_gimage = yield(@_gimage)
      @_image.write(current_path) if save_image
      @_gimage
    rescue => e
      raise CarrierWave::ProcessingError.new("Failed to manipulate file! #{e}")
    end


    def process!(*)
    	result = super
    	Rails.logger.debug 'GraphicsMagick - Processing image'
    	Rails.logger.dubug "GraphicsMagick - Image is at #{file.path}"
    	if @_gimage
    		if @format
    			Rails.logger.debug "GraphicsMagick - Changing formats to #{@format.to_s}"
    			Rails.logger.debug "GraphicsMagick - New file should be at #{file.basename}.#{@format.to_s.downcase}"
    			new_file = @_gimage.write("#{file.basename}.#{@format.to_s.downcase}")
    			file = new_file.file
    		else
	    		@_gimage.write!
	    	end
    		@_gimage = nil
    	end
    	result
    end
  end
end