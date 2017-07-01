# frozen_string_literal: true
class Event
  attr_accessor(:id, :name, :rank, :limit)

  def initialize(attributes={})
    @id = attributes[:id]
    @name = attributes[:name]
    @rank = attributes[:rank]
    @limit = attributes[:limit]
  end

  def self.find(id)
    ALL_EVENTS_BY_ID[id] or raise ActiveRecord::RecordNotFound
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
      rank: 0,
      limit: SolveTime.new('333', :single, -1),
    },
    {
      id: "333",
      name: "Rubik's Cube",
      rank: 10,
      limit: SolveTime.new('333', :single, -1),
    },
    {
      id: "222",
      name: "2x2x2 Cube",
      rank: 20,
      limit: SolveTime.new('222', :single, -1),
    },
    {
      id: "444",
      name: "4x4x4 Cube",
      rank: 30,
      limit: SolveTime.new('444', :average, 7000),
    },
    {
      id: "555",
      name: "5x5x5 Cube",
      rank: 40,
      limit: SolveTime.new('555', :average, 12000),
    },
    {
      id: "666",
      name: "6x6x6 Cube",
      rank: 50,
      limit: SolveTime.new('666', :average, 21000),
    },
    {
      id: "777",
      name: "7x7x7 Cube",
      rank: 60,
      limit: SolveTime.new('777', :average, 30000),
    },
    {
      id: "333bf",
      name: "3x3x3 Blindfolded",
      rank: 70,
      limit: SolveTime.new('333bf', :single, 18000),
    },
    {
      id: "333fm",
      name: "3x3x3 Fewest moves",
      rank: 80,
      limit: SolveTime.new('333fm', :single, 4000),
    },
    {
      id: "333oh",
      name: "3x3x3 One-handed",
      rank: 90,
      limit: SolveTime.new('333oh', :average, 3000),
    },
    {
      id: "333ft",
      name: "3x3x3 With feet",
      rank: 100,
      limit: SolveTime.new('333ft', :average, 10500),
    },
    {
      id: "minx",
      name: "Megaminx",
      rank: 110,
      limit: SolveTime.new('minx', :average, 11000),
    },
    {
      id: "pyram",
      name: "Pyraminx",
      rank: 120,
      limit: SolveTime.new('pyram', :single, -1),
    },
    {
      id: "clock",
      name: "Rubik's Clock",
      rank: 130,
      limit: SolveTime.new('clock', :average, 1500),
    },
    {
      id: "skewb",
      name: "Skewb",
      rank: 140,
      limit: SolveTime.new('skewb', :average, 1200),
    },
    {
      id: "sq1",
      name: "Square-1",
      rank: 150,
      limit: SolveTime.new('sq1', :average, 3000),
    },
    {
      id: "444bf",
      name: "4x4x4 Blindfolded",
      rank: 500,
      limit: SolveTime.new('444bf', :single, 120000),
    },
    {
      id: "555bf",
      name: "5x5x5 Blindfolded",
      rank: 510,
      limit: SolveTime.new('555bf', :single, 180000),
    },
    {
      id: "333mbf",
      name: "3x3x3 Multi-Blind",
      rank: 520,
      # 940366000 is 5/5 in 61 minutes (to be safe wrt eventual penalties)
      limit: SolveTime.new('333mbf', :single, 940366000),
    },
  ].map { |e| Event.new(e) }.freeze

  ALL_EVENTS_BY_ID = Hash[ALL_EVENTS.map { |e| [e.id, e] }]
end
