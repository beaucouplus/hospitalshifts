class DatesValidator

  def initialize(array,hash_key)
    @array = array
    @hash_key = hash_key
  end

  def perform
    validates_dates_values
    validates_overlap
    true
  end

  def validates_dates_values
    @array.each do |hash_|
      begin
        Time.parse(hash_[@hash_key])
      rescue => e
        raise ArgumentError.new("Incorrect date : #{hash_[@hash_key]}")
    end; end;
  end

  def validates_overlap
    overlaps = @array.group_by{ |hash_| hash_[@hash_key] }
    overlaps = overlaps.select { |date,v| overlaps[date].size > 1 }.flatten
    overlap_message = "Detected overlapping : #{overlaps.size} events cannot happen the same day."
    raise ArgumentError.new(overlap_message) if !overlaps.empty?
  end

end
