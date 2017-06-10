# frozen_string_literal: true
class Event
  attr_accessor(:id, :name, :rank)

  def initialize(attributes={})
    @id = attributes[:id]
    @name = attributes[:name]
    @rank = attributes[:rank]
  end

  def self.find(id)
    ALL_EVENTS_BY_ID[id] or raise ActiveRecord::RecordNotFound
  end

  def self.all
    ALL_EVENTS
  end

  ALL_EVENTS = [
    {
      id: "333",
      name: "Rubik's Cube",
      rank: 10,
    },
    {
      id: "222",
      name: "2x2x2 Cube",
      rank: 20,
    },
    {
      id: "444",
      name: "4x4x4 Cube",
      rank: 30,
    },
    {
      id: "555",
      name: "5x5x5 Cube",
      rank: 40,
    },
    {
      id: "666",
      name: "6x6x6 Cube",
      rank: 50,
    },
    {
      id: "777",
      name: "7x7x7 Cube",
      rank: 60,
    },
    {
      id: "333bf",
      name: "3x3x3 Blindfolded",
      rank: 70,
    },
    {
      id: "333fm",
      name: "3x3x3 Fewest moves",
      rank: 80,
    },
    {
      id: "333oh",
      name: "3x3x3 One-handed",
      rank: 90,
    },
    {
      id: "333ft",
      name: "3x3x3 With feet",
      rank: 100,
    },
    {
      id: "minx",
      name: "Megaminx",
      rank: 110,
    },
    {
      id: "pyram",
      name: "Pyraminx",
      rank: 120,
    },
    {
      id: "clock",
      name: "Rubik's Clock",
      rank: 130,
    },
    {
      id: "skewb",
      name: "Skewb",
      rank: 140,
    },
    {
      id: "sq1",
      name: "Square-1",
      rank: 150,
    },
    {
      id: "444bf",
      name: "4x4x4 Blindfolded",
      rank: 500,
    },
    {
      id: "555bf",
      name: "5x5x5 Blindfolded",
      rank: 510,
    },
    {
      id: "333mbf",
      name: "3x3x3 Multi-Blind",
      rank: 520,
    },
  ].map { |e| Event.new(e) }.freeze

  ALL_EVENTS_BY_ID = Hash[ALL_EVENTS.map { |e| [e.id, e] }]
end
