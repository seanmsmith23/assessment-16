class DashboardData

  def initialize(parsed_metrics)
    @parsed_metrics = parsed_metrics
  end

  def container_averages
    containers = group_by_container
    @container_averages = {}
    containers.each do |container, records|
      @container_averages[container.to_sym] = averages_for_each_metric(records)
    end
    @container_averages
  end

  def averages_for_all_containers
    averages_for_each_metric(@parsed_metrics)
  end

  def highest_water_container
    @parsed_metrics.max_by{|record| record[:water_level]}[:container]
  end

  def highest_average_temperature
    track_highest = container_and_value_tracker
    @container_averages.each do |k,v|
      if v[:temperature] > track_highest[:value]
        track_highest[:value] = v[:temperature]
        track_highest[:container] = k.to_s
      end
    end
    track_highest[:container]
  end

  def highest_ph_by_date(start, finish)
    track_highest = container_and_value_tracker
    start_date = Date.parse(start)
    end_date = Date.parse(finish)
    @parsed_metrics.each do |record|
      ph = record[:ph].to_f
      timestamp = Date.parse(record[:timestamp])
      if ph > track_highest[:value] && timestamp > start_date && timestamp < end_date
        track_highest[:value] = ph
        track_highest[:container] = record[:container]
      end
    end
    track_highest[:container]
  end

  private

  def group_by_container
    @parsed_metrics.group_by{ |record| record[:container] }
  end

  def averages_for(key, container_records)
    total = 0
    count = 0
    container_records.each do |record|
      total += record[key].to_f
      count += 1
    end
    (total/count).round(2)
  end

  def averages_for_each_metric(records)
    {
      ph: averages_for(:ph, records),
      nutrient_solution_level: averages_for(:nutrient_solution_level, records),
      temperature: averages_for(:temperature, records),
      water_level: averages_for(:water_level, records),
    }
  end

  def container_and_value_tracker
    {container: "none", value: 0}
  end

end