require "json"
require "pp"
require 'time'

def import_data(data)
  begin
    file = File.read(data)
  rescue
    raise ArgumentError.new("No data loaded, don't forget to load a file") if !file
  end
  JSON.parse(file)
end

class Hospital_shifts

  def initialize
    @data = import_data("data.json")
    @shifts = @data["shifts"]
    @workers = @data["workers"]
    @status = { medic: 270, interne: 126, interim: 480 }
  end

  def perform
    check_data_validity
    @night_shift = calculate_night_shift_prices
    define_commission
    File.open("night_shifts.json", 'w+'){ |json| json.write(JSON.pretty_generate(@night_shift)) }
  end

  private

  def calculate_night_shift_prices
    @workers.each_with_object({"workers" => []}) do |worker, shift|
      shift_number = define_shift_number(worker)
      total_price = shift_number * @status[worker["status"].to_sym]
      shift["workers"] << { "id": worker["id"], "price": total_price }
    end
  end

  def define_commission
    interim_fee = define_interim_hours * 80
    variable_pdg_fee = @night_shift["workers"].sum { |array| array[:price] * 0.05 }
    pdg_fee = interim_fee + variable_pdg_fee
    @night_shift["commission"] = { "pdg_fee": pdg_fee, "interim": define_interim_hours }
  end

  def define_interim_hours
    interims =  @workers.select { |worker| worker["status"] == "interim" }
    interims.map! { |interim| interim["id"] }
    @shifts.count { |shift| interims.include?(shift["user_id"])  }
  end

  def define_shift_number(worker)
    worker_shifts = @shifts.select { |shift| shift["user_id"] == worker["id"] }
    shift_number = worker_shifts.count
    double_pay_shifts = worker_shifts.select do |shift|
      shift_time = Time.parse(shift["start_date"])
      shift_time.saturday? || shift_time.sunday?
    end.count
    shift_number += double_pay_shifts
  end

  def check_data_validity
    raise ShiftsError.new('No shifts data') if !@shifts || @shifts.empty?
    raise ShiftsError.new('No workers data') if !@workers || @workers.empty?

    check_if_wrong_class
    check_if_time_values_ok
    check_if_overlap
  end

  def check_if_overlap
    overlaps = @shifts.group_by{ |shift| shift["start_date"] }
    overlaps = overlaps.select { |date,values| overlaps[date].size > 1 }.flatten
    overlap_message = "Detected overlapping : #{overlaps.size} shifts cannot happen the same day."
    raise ShiftsError.new(overlap_message) if !overlaps.empty?
  end


  def check_if_wrong_class
    worker_classes = ["Integer","String","String"]
    shifts_classes = ["Integer","Integer","Integer","String"]
    check_classes(@workers,worker_classes,"Workers")
    check_classes(@shifts,shifts_classes,"Shifts")
  end

  def check_classes(list,valid_classes,list_name)
    list.each do |list_data|
      counter = 0
      list_data.each do |key,value|
        wrong_class = "#{list_name} ##{list_data["id"]} : Value #{key}:#{value} should be #{valid_classes[counter]} but is #{value.class}"
        raise ShiftsError.new(wrong_class) if value.class.to_s != valid_classes[counter]
        counter += 1
      end
    end
  end

  def check_if_time_values_ok
    @shifts.each do |shift|
      begin
        Time.parse(shift["start_date"])
      rescue => e
        raise ShiftsError.new("Incorrect date : #{shift["start_date"]} in shift n° #{shift["id"]}")
      end
    end
  end

end

class Hospital_shifts::ShiftsError < StandardError
  def initialize(msg="Shifts data seems to be invalid. Please check.")
    super
  end
end

Hospital_shifts.new.perform
