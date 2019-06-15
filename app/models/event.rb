# frozen_string_literal: true
class Event
  attr_accessor(:id, :name, :short_name, :rank, :limit, :cutoff)

  def initialize(attributes={})
    @id = attributes[:id]
    @name = attributes[:name]
    @short_name = attributes[:short_name]
    @rank = attributes[:rank]
    @limit = attributes[:limit]
    @cutoff = attributes[:cutoff]
  end

  def self.find(id)
    ALL_EVENTS_BY_ID[id] or raise ActiveRecord::RecordNotFound
  end

  def self.find_or_nil(id)
    ALL_EVENTS_BY_ID[id]
  end

  def self.all
    ALL_EVENTS
  end

  def self.all_real
    Event.all.reject { |e| e.id == "magic" }
  end

  ALL_EVENTS = [
    {
      # haha
      id: "magic",
      name: "Registration",
      short_name: "",
      rank: 0,
      limit: SolveTime.new('333', :single, -1),
    },
    {
      id: "333",
      name: "3x3x3 Cube",
      short_name: "3x3",
      rank: 10,
      limit: SolveTime.new('333', :single, -1),
    },
    {
      id: "222",
      name: "2x2x2 Cube",
      short_name: "2x2",
      rank: 20,
      limit: SolveTime.new('222', :single, -1),
    },
    {
      id: "444",
      name: "4x4x4 Cube",
      short_name: "4x4",
      rank: 30,
      limit: SolveTime.new('444', :average, 7000),
    },
    {
      id: "555",
      name: "5x5x5 Cube",
      short_name: "5x5",
      rank: 40,
      limit: SolveTime.new('555', :average, 12000),
    },
    {
      id: "666",
      name: "6x6x6 Cube",
      short_name: "6x6",
      rank: 50,
      limit: SolveTime.new('666', :average, 21000),
      cutoff: SolveTime.new('666', :average, 18000),
    },
    {
      id: "777",
      name: "7x7x7 Cube",
      short_name: "7x7",
      rank: 60,
      limit: SolveTime.new('777', :average, 30000),
      cutoff: SolveTime.new('666', :average, 24000),
    },
    {
      id: "333bf",
      name: "3x3x3 Blindfolded",
      short_name: "3x3-BF",
      rank: 70,
      limit: SolveTime.new('333bf', :single, 18000),
    },
    {
      id: "333fm",
      name: "3x3x3 Fewest moves",
      short_name: "3x3-FM",
      rank: 80,
      limit: SolveTime.new('333fm', :single, 4000),
    },
    {
      id: "333oh",
      name: "3x3x3 One-handed",
      short_name: "3x3-OH",
      rank: 90,
      limit: SolveTime.new('333oh', :average, 3000),
    },
    {
      id: "333ft",
      name: "3x3x3 With feet",
      short_name: "3x3-FT",
      rank: 100,
      limit: SolveTime.new('333ft', :average, 10500),
    },
    {
      id: "minx",
      name: "Megaminx",
      short_name: "Mega",
      rank: 110,
      limit: SolveTime.new('minx', :average, 11000),
    },
    {
      id: "pyram",
      name: "Pyraminx",
      short_name: "Pyra",
      rank: 120,
      limit: SolveTime.new('pyram', :single, -1),
    },
    {
      id: "clock",
      name: "Clock",
      short_name: "Clock",
      rank: 130,
      limit: SolveTime.new('clock', :average, 1500),
    },
    {
      id: "skewb",
      name: "Skewb",
      short_name: "Skewb",
      rank: 140,
      limit: SolveTime.new('skewb', :average, 1200),
    },
    {
      id: "sq1",
      name: "Square-1",
      short_name: "Sq-1",
      rank: 150,
      limit: SolveTime.new('sq1', :average, 3000),
    },
    {
      id: "444bf",
      name: "4x4x4 Blindfolded",
      short_name: "4x4-BF",
      rank: 500,
      limit: SolveTime.new('444bf', :single, 120000),
    },
    {
      id: "555bf",
      name: "5x5x5 Blindfolded",
      short_name: "5x5-BF",
      rank: 510,
      limit: SolveTime.new('555bf', :single, 180000),
    },
    {
      id: "333mbf",
      name: "3x3x3 Multi-Blind",
      short_name: "3x3-MBF",
      rank: 520,
      # 940366000 is 5/5 in 61 minutes (to be safe wrt eventual penalties)
      limit: SolveTime.new('333mbf', :single, 940366000),
    },
  ].map { |e| Event.new(e) }.freeze

  ALL_EVENTS_BY_ID = Hash[ALL_EVENTS.map { |e| [e.id, e] }]
end
