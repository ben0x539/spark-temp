# encoding: utf-8

class Hist
  SPARKS = [" "] + %w[▁ ▂ ▃ ▄ ▅ ▆ ▇ █]

  def initialize(label, lo = 50, hi = 90)
    @label = label
    @history = ""
    raise "hi <= lo" if hi <= lo
    @lo, @hi = lo, hi
    @last = nil
  end

  def <<(val)
    @history = translate(val.to_f) + @history
    @history = @history[0, (80 - @label.size - 6)]
    @last = val
  end

  def to_s
    val = @last.to_s
    history = @history[0, (80 - @label.size - val.size - 3)]
    sprintf "%s: %3s %s", @label, val, history
  end

  private
  def translate(val)
    lo, hi = @lo, @hi
    i = if val < lo
          0
        elsif val > hi
          -1
        else
          (val - lo) / (hi - lo) * (SPARKS.size - 2) + 1
        end
    SPARKS[i]
  end
end

cpu, gpu = Hist.new("cpu"), Hist.new("gpu")
last = Time.now

loop do
  cpu_temp_str = File.read("/sys/class/thermal/thermal_zone0/temp")
  gpu_temp_str = `nvidia-settings --query :0.0/GPUCoreTemp`
  cpu_temp = cpu_temp_str.chomp[0...-3].to_i
  m = gpu_temp_str.match(/Attribute 'GPUCoreTemp' .*?: (\d+)\.$/)
  gpu_temp = if m then m[1].to_i else 0 end

  now = Time.now
  cpu << cpu_temp
  gpu << gpu_temp
  puts cpu
  puts gpu

  last += 2
  delay = last - now
  sleep(delay) if delay > 0
end
