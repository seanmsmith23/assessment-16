class DashboardData

  def initialize(parsed_metrics)
    @parsed_metrics = parsed_metrics
  end

  def container_averages
    containers = group_by_container
    @container_averages = {}
    containers.each do |container, records|
      @container_averages[container.to_sym] = {
        ph: averages_for(:ph, records),
        nutrient_solution_level: averages_for(:nutrient_solution_level, records),
        temperature: averages_for(:temperature, records),
        water_level: averages_for(:water_level, records),
      }
    end
    @container_averages
  end

  def averages_for_all_containers
    {
      ph: averages_for(:ph, @parsed_metrics),
      nutrient_solution_level: averages_for(:nutrient_solution_level, @parsed_metrics),
      temperature: averages_for(:temperature, @parsed_metrics),
      water_level: averages_for(:water_level, @parsed_metrics),
    }
  end

  def highest_water_container
    highest_container = "none"
    highest_water = 0
    @parsed_metrics.each do |record|
      water = record[:water_level].to_f
      if water > highest_water
        highest_water = water
        highest_container = record[:container]
      end
    end
    highest_container
  end

  def highest_average_temperature
    highest_container = "none"
    highest_temp = 0
    @container_averages.each do |k,v|
      if v[:temperature] > highest_temp
        highest_temp = v[:temperature]
        highest_container = k.to_s
      end
    end
    highest_container
  end

  def highest_ph_by_date(start, finish)
    highest_container = "none"
    highest_ph = 0
    start_date = Date.parse(start)
    end_date = Date.parse(finish)
    @parsed_metrics.each do |record|
      ph = record[:ph].to_f
      timestamp = Date.parse(record[:timestamp])
      if ph > highest_ph && timestamp > start_date && timestamp < end_date
        highest_ph = ph
        highest_container = record[:container]
      end
    end
    highest_container
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

end