require 'awesome_print'
require 'pry-debugger'
require_relative 'averages'

class MetricsParser

  def initialize(filepath)
    opened = File.open(filepath)
    @raw_data = File.read(opened)
  end

  def parse
    records_array = split_into_records
    @parsed_records = parse_all_records(records_array)
  end

  private

  def split_into_records
    @raw_data.split("\n")
  end

  def split_individual_record(record)
    record.split("\t")
  end

  def parse_record_into_hash(parsed_record)
    {
      timestamp: parsed_record[0],
      container: parsed_record[1],
      ph: parsed_record[2],
      nutrient_solution_level: parsed_record[3],
      temperature: parsed_record[4],
      water_level: parsed_record[5]
    }
  end

  def parse_all_records(records_array)
    parsed_records = []
    records_array.each do |record|
      split_record = split_individual_record(record)
      parsed_records << parse_record_into_hash(split_record)
    end
    parsed_records
  end

end


metrics = MetricsParser.new('/Users/seansmith/gSchoolWork/assessments/g3-assessment-week-16/data/metrics.tsv')
ap parsed = metrics.parse
# binding.pry

dashboard = DashboardData.new(parsed)
ap dashboard.container_averages
ap dashboard.highest_water_container
ap dashboard.highest_average_temperature
ap dashboard.averages_for_all_containers