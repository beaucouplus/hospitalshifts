class ImportData

  def initialize(filename)
    begin
      @filename = filename
      @content = File.read(filename)
    rescue
      raise ArgumentError.new("No data loaded, don't forget to load a file") if !@content
    end

  end

  def perform
    JSON.parse(@content)
  end

end
