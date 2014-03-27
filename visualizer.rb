class BlobVisualizer < Processing::App

  load_library "minim"
  import "ddf.minim"
  import "ddf.minim.analysis"

  def setup
    smooth
    size 1280, 800
    background 20
    setup_sound
  end

  def draw
    background 20
    draw_human
    update_sound
    animate_sound
  end


  def draw_human
    stroke 204, 102, 0
    stroke_weight 10
    line 700,500,800,700 # leg
    line 700,500,600,700 # leg
    line 700,500,700,280 # chest
    line 700,300,800,400 # arm
    ellipse 700, 240, 100, 100 # head
  end

  def animate_sound
    size = @scaled_ffts[1]*height
    size *= 1.25 if @beat.is_onset

    line(700,300,600, size + 50)
    stroke_weight size
    stroke 255
    line 100, 100, size, size
  end

  def setup_sound
    @minim = Minim.new(self)
    @input = @minim.load_file("/Users/chg/Code/processing/test.mp3")

    @input.play
    @fft = FFT.new(@input.left.size, 44100)
    @beat = BeatDetect.new

    @freqs = [60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000]

    @current_ffts   = Array.new(@freqs.size, 0.001)
    @previous_ffts  = Array.new(@freqs.size, 0.001)
    @max_ffts       = Array.new(@freqs.size, 0.001)
    @scaled_ffts    = Array.new(@freqs.size, 0.001)

    @fft_smoothing = 0.8
  end

  def update_sound
    @fft.forward @input.left
    @previous_ffts = @current_ffts
    @freqs.each_with_index do |freq, i|
      new_fft = @fft.get_freq(freq)

      @max_ffts[i] = new_fft if new_fft > @max_ffts[i]
      @current_ffts[i] = ((1 - @fft_smoothing) * new_fft) + (@fft_smoothing * @previous_ffts[i])
      @scaled_ffts[i] = (@current_ffts[i]/@max_ffts[i])
    end

    @beat.detect(@input.left)
  end
end

BlobVisualizer.new title: "BlobVisualizer"

